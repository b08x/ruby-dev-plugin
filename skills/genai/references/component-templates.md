# GenAI Component Templates

## Contents
- Template 1: RAG Pipeline with pgvector (schema, embedder, retriever)
- Template 2: MCP Server with Tools
- Template 3: DSPy-Style Structured Prompting

## Template 1: RAG Pipeline with pgvector

**Structure**:
```
lib/my_app/
├── rag/
│   ├── embedder.rb         # Embedding generation
│   ├── indexer.rb          # Clause indexing
│   ├── retriever.rb        # Hybrid retrieval (RRF)
│   ├── generator.rb        # LLM response generation
│   └── pipeline.rb         # Orchestrator
└── db/
    └── migrations/
        └── 001_create_embeddings.rb
```

**Schema** (`001_create_embeddings.rb`):
```ruby
Sequel.migration do
  up do
    execute "CREATE EXTENSION IF NOT EXISTS vector"

    create_table(:clauses) do
      primary_key :id
      String :text, null: false
      String :source_document
      Integer :position
      jsonb :pos_tags
      jsonb :fine_tags
      jsonb :dependencies
      tsvector :tsv  # Full-text search
      index :tsv, type: :gin
    end

    create_table(:embeddings) do
      foreign_key :clause_id, :clauses, null: false
      column :embedding, "vector(1536)"  # OpenAI ada-002 size
      String :model, null: false
      DateTime :created_at, null: false
      index [:clause_id, :model], unique: true
      index :embedding, type: :ivfflat, opclass: :vector_cosine_ops
    end
  end
end
```

**Embedder** (`embedder.rb`):
```ruby
# frozen_string_literal: true

require "dotenv/load"
require "ruby_llm"
require "circuit_breaker"
require "journald/logger"
require "dry-struct"
require "dry-types"

module Types
  include Dry.Types()
end

module MyApp
  module RAG
    # Type-safe embedding result
    class EmbeddingResult < Dry::Struct
      attribute :embedding, Types::Array.of(Types::Float)
      attribute :model, Types::String
      attribute :tokens_used, Types::Integer
      attribute :latency_ms, Types::Float
      attribute :timestamp, Types::Time
    end

    class Embedder
      include Dry::Monads[:result]

      def initialize(model: "text-embedding-ada-002")
        @llm = RubyLLM::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))
        @model = model
        @circuit = CircuitBreaker.new(threshold: 5, timeout: 30, reevaluate_after: 60)
      end

      def embed(text)
        return Failure([:empty_text, "Text cannot be empty"]) if text.nil? || text.empty?

        tracer.in_span("embedder.embed") do |span|
          start_time = Time.now
          request_id = SecureRandom.uuid

          span.set_attribute("request_id", request_id)
          span.set_attribute("model", @model)
          span.set_attribute("text_length", text.length)

          logger.info("embedding_started", {
            request_id: request_id,
            model: @model,
            text_length: text.length
          })

          # The opentelemetry-instrumentation-ruby_llm gem auto-creates a child
          # span around this call (model, token usage, latency) — no manual
          # span needed for the API call itself, only for this surrounding op.
          embedding = @circuit.call do
            response = @llm.embed(input: text, model: @model)
            response.embedding
          end

          elapsed_ms = ((Time.now - start_time) * 1000).round(2)
          tokens = estimate_tokens(text)
          span.set_attribute("latency_ms", elapsed_ms)
          span.set_attribute("tokens_used", tokens)

          logger.info("embedding_completed", {
            request_id: request_id,
            model: @model,
            latency_ms: elapsed_ms,
            tokens_used: tokens
          })

          Success(EmbeddingResult.new(
            embedding: embedding,
            model: @model,
            tokens_used: tokens,
            latency_ms: elapsed_ms,
            timestamp: Time.now
          ))
        rescue CircuitBreaker::OpenError
          span.status = OpenTelemetry::Trace::Status.error("circuit_open")
          logger.error("embedding_circuit_open", {
            request_id: request_id,
            model: @model,
            reason: "circuit_breaker_open"
          })
          Failure([:circuit_open, "Circuit breaker is open"])
        rescue StandardError => e
          elapsed_ms = ((Time.now - start_time) * 1000).round(2)
          span.record_exception(e)
          span.status = OpenTelemetry::Trace::Status.error(e.message)

          logger.error("embedding_failed", {
            request_id: request_id,
            model: @model,
            error_class: e.class.name,
            error_message: e.message,
            latency_ms: elapsed_ms,
            backtrace: e.backtrace.first(5)
          })
          Failure([:api_error, e.message])
        end
      end

      private

      def logger
        @logger ||= Journald::Logger.new("embedder")
      end

      def tracer
        @tracer ||= OpenTelemetry.tracer_provider.tracer("embedder")
      end

      def estimate_tokens(text)
        # Rough estimate: ~4 characters per token
        (text.length / 4.0).ceil
      end
    end
  end
end
```

**Retriever** (`retriever.rb`):
```ruby
# frozen_string_literal: true

require "sequel"

module MyApp
  module RAG
    class Retriever
      def initialize(db:, embedder:)
        @db = db
        @embedder = embedder
      end

      def retrieve(query, limit: 10)
        query_embedding = @embedder.embed(query)

        # Semantic search
        semantic = @db[:embeddings]
          .join(:clauses, id: :clause_id)
          .order(Sequel.lit("embedding <=> ?", query_embedding))
          .limit(100)
          .select(
            Sequel[:clauses][:id].as(:clause_id),
            Sequel[:clauses][:text],
            Sequel.lit("ROW_NUMBER() OVER (ORDER BY embedding <=> ?) AS semantic_rank", query_embedding)
          )

        # Keyword search
        keyword = @db[:clauses]
          .where(Sequel.lit("tsv @@ plainto_tsquery(?)", query))
          .select(
            :id,
            Sequel.lit("ROW_NUMBER() OVER (ORDER BY ts_rank(tsv, plainto_tsquery(?)) DESC) AS keyword_rank", query)
          )

        # RRF merge
        @db.from(semantic.full_outer_join(keyword, clause_id: :id))
          .select(
            Sequel.lit("COALESCE(semantic.clause_id, keyword.id) AS clause_id"),
            Sequel[:semantic][:text],
            Sequel.lit("(1.0 / (60 + COALESCE(semantic_rank, 100))) + (1.0 / (60 + COALESCE(keyword_rank, 100))) AS rrf_score")
          )
          .order(Sequel.desc(:rrf_score))
          .limit(limit)
          .all
      end
    end
  end
end
```

## Template 2: MCP Server with Tools

**Structure**:
```
lib/my_app/
└── mcp/
    ├── server.rb           # Fast-MCP server
    ├── tools/
    │   ├── search.rb       # Semantic search tool
    │   ├── summarize.rb    # Summarization tool
    │   └── base.rb         # Tool base class
    └── schemas/
        └── tool_schemas.rb # JSON schemas for tools
```

**Server** (`server.rb`):
```ruby
# frozen_string_literal: true

require "fast_mcp"

module MyApp
  module MCP
    class Server
      def initialize(port: 8080)
        @server = FastMCP::Server.new(port: port)
        register_tools
      end

      def start
        @server.start
      end

      private

      def register_tools
        @server.register_tool(Tools::Search.new)
        @server.register_tool(Tools::Summarize.new)
      end
    end
  end
end
```

**Tool** (`tools/search.rb`):
```ruby
# frozen_string_literal: true

module MyApp
  module MCP
    module Tools
      class Search < Base
        def name
          "semantic_search"
        end

        def description
          "Search knowledge base using semantic similarity"
        end

        def parameters
          {
            type: "object",
            properties: {
              query: { type: "string", description: "Search query" },
              limit: { type: "integer", default: 10, description: "Max results" }
            },
            required: ["query"]
          }
        end

        def execute(query:, limit: 10)
          retriever = RAG::Retriever.new(db: DB, embedder: RAG::Embedder.new)
          results = retriever.retrieve(query, limit: limit)

          {
            results: results.map { |r| { text: r[:text], score: r[:rrf_score] } },
            count: results.size
          }
        end
      end
    end
  end
end
```

## Template 3: DSPy-Style Structured Prompting

**Structure**:
```ruby
# frozen_string_literal: true

module MyApp
  module Prompts
    class Signature
      attr_reader :input_fields, :output_fields, :instructions

      def initialize(instructions:, input_fields:, output_fields:)
        @instructions = instructions
        @input_fields = input_fields
        @output_fields = output_fields
      end

      def format(inputs)
        prompt = "#{@instructions}\n\n"

        @input_fields.each do |field, description|
          prompt += "#{field.to_s.capitalize}: #{description}\n"
          prompt += "#{inputs[field]}\n\n"
        end

        prompt += "Output:\n"
        @output_fields.each do |field, description|
          prompt += "#{field.to_s.capitalize}: #{description}\n"
        end

        prompt
      end
    end

    class ChainOfThought
      def initialize(llm:, signature:)
        @llm = llm
        @signature = signature
      end

      def predict(**inputs)
        prompt = @signature.format(inputs)

        circuit_breaker do
          response = @llm.complete(prompt: prompt, max_tokens: 500)
          parse_output(response)
        end
      end

      private

      def parse_output(response)
        # Parse structured output based on signature
        @signature.output_fields.keys.each_with_object({}) do |field, acc|
          acc[field] = extract_field(response, field)
        end
      end
    end
  end
end
```

# Dspy-Ruby_Docs - Building

**Pages:** 5

---

## Examples | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/core-concepts/examples/

**Contents:**
- Examples and Expected Behavior
- Create Evaluation Examples
- Validate Examples Against a Signature
- Read and Evaluate Example Values
  - Accessing Example Data
  - Compare a Prediction with Expected Output
  - Validate a Batch
- Few-Shot Examples
  - Working with FewShotExample
  - Serialization

Examples hold typed inputs and expected outputs for evaluation. FewShotExample also represents demonstrations that a predictor can include in provider-facing prompts.

DSPy.rb validates example values against the signature’s type constraints when the object is created. This validation constrains declared shape and types; a named metric applied to selected examples provides bounded evidence about task behavior and correctness.

Few-shot examples provide demonstrations that a predictor can include in provider-facing prompts. Measure their effect with evaluation examples and a metric:

Use evaluation examples to define acceptable behavior. Use few-shot examples when a predictor or optimizer needs demonstrations; the two roles need not use the same dataset.

**Examples:**

Example 1 (unknown):
```unknown
FewShotExample
```

Example 2 (php):
```php
class ClassifyText < DSPy::Signature
  description "Classify text sentiment"
  
  class Sentiment < T::Enum
    enums do
      Positive = new('positive')
      Negative = new('negative')
      Neutral = new('neutral')
    end
  end
  
  input do
    const :text, String
  end
  
  output do
    const :sentiment, Sentiment
    const :confidence, Float
  end
end

# Create examples with known correct outputs
examples = [
  DSPy::Example.new(
    signature_class: ClassifyText,
    input: { text: "I absolutely love this product!" },
    expected: { 
      sentiment: ClassifyText::Sentiment::Positive, 
      confidence: 0.95 
    }
  ),
  DSPy::Example.new(
    signature_class: ClassifyText,
    input: { text: "This is the worst experience ever." },
    expected: { 
      sentiment: ClassifyText::Sentiment::Negative, 
      confidence: 0.92 
    }
  ),
  DSPy::Example.new(
    signature_class: ClassifyText,
    input: { text: "The weather is okay today." },
    expected: { 
      sentiment: ClassifyText::Sentiment::Neutral, 
      confidence: 0.78 
    }
  )
]
```

Example 3 (php):
```php
class ClassifyText < DSPy::Signature
  description "Classify text sentiment"
  
  class Sentiment < T::Enum
    enums do
      Positive = new('positive')
      Negative = new('negative')
      Neutral = new('neutral')
    end
  end
  
  input do
    const :text, String
  end
  
  output do
    const :sentiment, Sentiment
    const :confidence, Float
  end
end

# Create examples with known correct outputs
examples = [
  DSPy::Example.new(
    signature_class: ClassifyText,
    input: { text: "I absolutely love this product!" },
    expected: { 
      sentiment: ClassifyText::Sentiment::Positive, 
      confidence: 0.95 
    }
  ),
  DSPy::Example.new(
    signature_class: ClassifyText,
    input: { text: "This is the worst experience ever." },
    expected: { 
      sentiment: ClassifyText::Sentiment::Negative, 
      confidence: 0.92 
    }
  ),
  DSPy::Example.new(
    signature_class: ClassifyText,
    input: { text: "The weather is okay today." },
    expected: { 
      sentiment: ClassifyText::Sentiment::Neutral, 
      confidence: 0.78 
    }
  )
]
```

Example 4 (lua):
```lua
# This will raise a validation error
invalid_example = DSPy::Example.new(
  signature_class: ClassifyText,
  input: { text: "Sample text" },
  expected: { 
    sentiment: "positive",  # String instead of Sentiment enum - ERROR!
    confidence: 1.5
  }
)
# => ArgumentError: Type error in expected output for ClassifyText: ...
```

---

## Multimodal Support | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/core-concepts/multimodal/

**Contents:**
- Multimodal Support
- Vision-Capable Models
  - OpenAI Models
  - Anthropic Models
  - Google Gemini Models
- PDF Document Support
  - Creating Documents
  - Using Documents with Raw Chat
  - Using Documents with Predict
  - Using Documents Through RubyLLM

DSPy.rb can pass images and supported PDF documents through raw chat or typed signatures. Provider and input-shape limits differ, so choose the adapter before designing the signature.

PDF document inputs currently have a narrower contract than images:

Predict can attach one top-level DSPy::Document input and preserve a placeholder in the rendered prompt:

DSPy::Image accepts a URL, base64 data, or byte data:

Structured signatures can declare typed outputs for image analysis.

This signature extracts colors, objects, mood, and style:

Use T::Struct for type-safe bounding box detection:

When using Anthropic models, you need to provide images as base64 or raw data:

The Gemini adapter accepts base64 or byte image data:

DSPy.rb raises ArgumentError or DSPy::LM::IncompatibleImageFeatureError for the incompatible model and input combinations below:

Images consume tokens based on their size:

Monitor token usage when working with multiple or large images. raw_chat returns the accumulated text as a String; subscribe to lm.tokens for usage data (see Observability):

Complete working examples are available in the repository:

Both examples include:

**Examples:**

Example 1 (unknown):
```unknown
gpt-4o-mini
```

Example 2 (unknown):
```unknown
gemini-2.5-flash
```

Example 3 (unknown):
```unknown
gemini-2.5-pro
```

Example 4 (yaml):
```yaml
DSPy::Document
```

---

## Pipelines | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/pipelines/

**Contents:**
- Multi-stage Pipelines
- Decide What Ruby Owns
- Compose Pipeline Stages
  - Module-Based Architecture
  - Sequential Pipeline
- Add Branches and Recovery
  - Conditional Processing
  - Pipeline with Error Handling
  - Data Transformation Pipeline
- Separate Parallelizable Stages

A pipeline composes DSPy modules with Ruby control flow. Use one when the application should determine the sequence, branches, and failure handling. Use an agent only when the model has a useful decision to make about the next action.

Pipeline code provides:

**Examples:**

Example 1 (julia):
```julia
class DocumentClassificationSignature < DSPy::Signature
  description "Classify document type"
  input { const :content, String }
  output { const :document_type, String }
end

class DocumentClassifier < DSPy::Module
  def initialize
    super
    @predictor = DSPy::Predict.new(DocumentClassificationSignature)
  end

  def forward(content:)
    @predictor.call(content: content)
  end
end

class SummaryGenerationSignature < DSPy::Signature
  description "Generate document summary"
  input { const :content, String }
  output { const :summary, String }
end

class SummaryGenerator < DSPy::Module
  def initialize
    super
    @predictor = DSPy::Predict.new(SummaryGenerationSignature)
  end

  def forward(content:)
    @predictor.call(content: content)
  end
end
```

Example 2 (julia):
```julia
class DocumentClassificationSignature < DSPy::Signature
  description "Classify document type"
  input { const :content, String }
  output { const :document_type, String }
end

class DocumentClassifier < DSPy::Module
  def initialize
    super
    @predictor = DSPy::Predict.new(DocumentClassificationSignature)
  end

  def forward(content:)
    @predictor.call(content: content)
  end
end

class SummaryGenerationSignature < DSPy::Signature
  description "Generate document summary"
  input { const :content, String }
  output { const :summary, String }
end

class SummaryGenerator < DSPy::Module
  def initialize
    super
    @predictor = DSPy::Predict.new(SummaryGenerationSignature)
  end

  def forward(content:)
    @predictor.call(content: content)
  end
end
```

Example 3 (julia):
```julia
class DocumentProcessor < DSPy::Module
  def initialize
    super
    @classifier = DocumentClassifier.new
    @summarizer = SummaryGenerator.new
  end

  def forward(content:)
    classification = @classifier.call(content: content)
    
    summary = @summarizer.call(content: content)
    
    {
      document_type: classification.document_type,
      summary: summary.summary,
      original_length: content.length,
      summary_length: summary.summary.length
    }
  end
end

processor = DocumentProcessor.new
result = processor.call(content: "Long document content...")

puts "Type: #{result[:document_type]}"
puts "Summary: #{result[:summary]}"
```

Example 4 (julia):
```julia
class DocumentProcessor < DSPy::Module
  def initialize
    super
    @classifier = DocumentClassifier.new
    @summarizer = SummaryGenerator.new
  end

  def forward(content:)
    classification = @classifier.call(content: content)
    
    summary = @summarizer.call(content: content)
    
    {
      document_type: classification.document_type,
      summary: summary.summary,
      original_length: content.length,
      summary_length: summary.summary.length
    }
  end
end

processor = DocumentProcessor.new
result = processor.call(content: "Long document content...")

puts "Type: #{result[:document_type]}"
puts "Summary: #{result[:summary]}"
```

---

## Ruby RAG Tutorial with DSPy.rb | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/rag/

**Contents:**
- Retrieval Augmented Generation (RAG)
- Define the retrieval boundary
- Pass retrieved context to a typed module
- Adapt a real search system
- Filter context before generation
- Evaluate retrieval and answers separately
- Keep retrieval observable
- Decide whether you need a vector store
- Continue by reader task

Retrieval-augmented generation (RAG) has two parts: retrieve relevant material, then ask a model to use it. DSPy.rb supplies the typed signature and module boundary. Your application owns the documents, search system, permissions, freshness policy, and citations.

DSPy.rb does not provide a vector store or an embedding model. Start with the smallest retriever that can answer your evaluation questions. Add a vector or hybrid index only when measurements justify the extra system.

Make the retriever return stable records. Keeping the identifier and source with the text makes citations and debugging possible.

This is a working baseline, not a recommendation to use substring search in production. Replace it with an adapter for your search service when the baseline misses the cases that matter.

Keep retrieval outside the signature. The model should receive the question and selected context; it should not decide which database or tenant to query.

The empty-result branch is deliberate. A retriever can return nothing; the application should choose that behavior rather than letting an empty prompt look like evidence.

Your adapter needs one small contract:

The adapter can call a keyword index, vector database, hosted search API, or hybrid system. Keep these decisions outside DSPy.rb:

Do not copy a vendor client into this page. Its authentication, API version, embedding model, retry policy, and response shape belong to the application that owns the service.

Retrieval quality and answer quality are different measurements. Record retrieved identifiers, scores when the store provides them, and final context length. A simple application-owned policy can look like this:

This cap is not universal. Measure recall, answer correctness, latency, and cost on your own questions before changing it.

Use a held-out set. The questions used to tune retrieval or prompts should not be the only questions used to judge the result.

Track retrieval metrics such as:

Track answer metrics separately:

An answer score cannot tell you whether a failure came from search or generation. Keep those failures visible.

Wrap the application-owned retriever when you need bounded measurements:

Do not log the user’s full query or retrieved text by default. Log stable identifiers and bounded measurements; add redaction and access controls before retaining sensitive content.

Use lexical search when the corpus is small, terminology is stable, or exact terms matter. Consider vector or hybrid retrieval when held-out questions show a repeatable recall problem that better indexing could address.

Changing the index does not prove that answers improved. Compare the old and new retrievers on the same held-out questions, then evaluate the complete program with the same answer metric.

**Examples:**

Example 1 (python):
```python
class LexicalRetriever
  def initialize(documents)
    @documents = documents
  end

  def search(query, limit: 3)
    terms = query.downcase.scan(/[a-z0-9]+/).uniq

    @documents
      .filter_map do |document|
        score = terms.count { |term| document[:text].downcase.include?(term) }
        score.positive? ? [score, document] : nil
      end
      .sort_by { |score, document| [-score, document[:id]] }
      .first(limit)
      .map(&:last)
  end
end
```

Example 2 (python):
```python
class LexicalRetriever
  def initialize(documents)
    @documents = documents
  end

  def search(query, limit: 3)
    terms = query.downcase.scan(/[a-z0-9]+/).uniq

    @documents
      .filter_map do |document|
        score = terms.count { |term| document[:text].downcase.include?(term) }
        score.positive? ? [score, document] : nil
      end
      .sort_by { |score, document| [-score, document[:id]] }
      .first(limit)
      .map(&:last)
  end
end
```

Example 3 (julia):
```julia
class AnswerFromContext < DSPy::Signature
  description "Answer a question using only the supplied context"

  input do
    const :question, String
    const :context, String
  end

  output do
    const :answer, String
    const :citations, T::Array[String]
  end
end

class RetrievedAnswer < DSPy::Module
  def initialize(retriever)
    super
    @retriever = retriever
    @answerer = DSPy::Predict.new(AnswerFromContext)
  end

  def forward(question:, limit: 3)
    documents = @retriever.search(question, limit: limit)
    context = documents.map do |document|
      "[#{document[:id]}] #{document[:text]}"
    end.join("\n\n")

    return {answer: "I could not find relevant context.", citations: []} if context.empty?

    result = @answerer.call(question: question, context: context)
    {answer: result.answer, citations: result.citations}
  end
end

documents = [
  {id: "refunds", text: "Refunds are available within 30 days of purchase."},
  {id: "support", text: "Support is available by email on business days."}
]

program = RetrievedAnswer.new(LexicalRetriever.new(documents))
program.call(question: "How long do I have to request a refund?")
```

Example 4 (julia):
```julia
class AnswerFromContext < DSPy::Signature
  description "Answer a question using only the supplied context"

  input do
    const :question, String
    const :context, String
  end

  output do
    const :answer, String
    const :citations, T::Array[String]
  end
end

class RetrievedAnswer < DSPy::Module
  def initialize(retriever)
    super
    @retriever = retriever
    @answerer = DSPy::Predict.new(AnswerFromContext)
  end

  def forward(question:, limit: 3)
    documents = @retriever.search(question, limit: limit)
    context = documents.map do |document|
      "[#{document[:id]}] #{document[:text]}"
    end.join("\n\n")

    return {answer: "I could not find relevant context.", citations: []} if context.empty?

    result = @answerer.call(question: question, context: context)
    {answer: result.answer, citations: result.citations}
  end
end

documents = [
  {id: "refunds", text: "Refunds are available within 30 days of purchase."},
  {id: "support", text: "Support is available by email on business days."}
]

program = RetrievedAnswer.new(LexicalRetriever.new(documents))
program.call(question: "How long do I have to request a refund?")
```

---

## Stateful Agents | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/stateful-agents/

**Contents:**
- Stateful Agents
- Separate Session State from Durable Memory
  - State vs Memory
- Choose a Persistence Pattern
  - 1. Session-Based Agent
  - 2. Persistent Agent with Custom Storage
  - 3. Multi-Context Agent
  - 4. Adapt from Stored Feedback
- Error Handling and Resilience
  - Failure Recovery

DSPy::ReAct runs a bounded tool-selection loop; it does not persist conversation state between calls. The application must load relevant history and preferences, pass them into the agent, and store approved changes.

Session state is temporary information the application carries between calls:

Durable memory is information the application stores across sessions:

DSPy.rb supplies modules, tools, and the ReAct loop. The application owns persistence in a database, Redis, or another store.

A session-based agent maintains state during a conversation but doesn’t persist information between sessions:

A persistent agent stores information across sessions using application-level storage. Define custom tools that wrap your storage backend:

An agent that maintains different types of context and state:

This pattern stores interaction-derived patterns and uses them to adjust later inputs. Review and approve those patterns before persistence when they affect production behavior:

Keep session state separate from durable memory. Bound the context passed to each call, validate stored values before reuse, and enforce permissions in the tools or services that perform side effects.

**Examples:**

Example 1 (yaml):
```yaml
DSPy::ReAct
```

Example 2 (julia):
```julia
class SessionAgent < DSPy::Module
  class ConversationSignature < DSPy::Signature
    description "Conversational agent that maintains context"

    input do
      const :user_message, String
      const :session_id, String
    end

    output do
      const :response, String
      const :context_summary, String
    end
  end

  def initialize
    super
    @sessions = {}
    @agent = DSPy::ReAct.new(ConversationSignature, tools: [])
  end

  def forward(user_message:, session_id:)
    # Get or create session context
    session = get_session(session_id)

    # Add context to the message
    contextual_message = build_contextual_message(user_message, session)

    # Get response from agent
    result = @agent.call(
      user_message: contextual_message,
      session_id: session_id
    )

    # Update session context
    update_session(session_id, user_message, result)

    result
  end

  private

  def get_session(session_id)
    @sessions[session_id] ||= {
      messages: [],
      context: "",
      started_at: Time.now
    }
  end

  def build_contextual_message(message, session)
    if session[:messages].empty?
      message
    else
      "Previous context: #{session[:context]}\n\nCurrent message: #{message}"
    end
  end

  def update_session(session_id, message, result)
    session = @sessions[session_id]
    session[:messages] << {
      user: message,
      assistant: result.response,
      timestamp: Time.now
    }
    session[:context] = result.context_summary
  end
end
```

Example 3 (julia):
```julia
class SessionAgent < DSPy::Module
  class ConversationSignature < DSPy::Signature
    description "Conversational agent that maintains context"

    input do
      const :user_message, String
      const :session_id, String
    end

    output do
      const :response, String
      const :context_summary, String
    end
  end

  def initialize
    super
    @sessions = {}
    @agent = DSPy::ReAct.new(ConversationSignature, tools: [])
  end

  def forward(user_message:, session_id:)
    # Get or create session context
    session = get_session(session_id)

    # Add context to the message
    contextual_message = build_contextual_message(user_message, session)

    # Get response from agent
    result = @agent.call(
      user_message: contextual_message,
      session_id: session_id
    )

    # Update session context
    update_session(session_id, user_message, result)

    result
  end

  private

  def get_session(session_id)
    @sessions[session_id] ||= {
      messages: [],
      context: "",
      started_at: Time.now
    }
  end

  def build_contextual_message(message, session)
    if session[:messages].empty?
      message
    else
      "Previous context: #{session[:context]}\n\nCurrent message: #{message}"
    end
  end

  def update_session(session_id, message, result)
    session = @sessions[session_id]
    session[:messages] << {
      user: message,
      assistant: result.response,
      timestamp: Time.now
    }
    session[:context] = result.context_summary
  end
end
```

Example 4 (julia):
```julia
# Custom tool for storing and retrieving data
class StorageTool < DSPy::Tools::Base
  tool_name "storage"
  tool_description "Store and retrieve key-value data"

  sig { params(action: String, key: String, value: T.nilable(String)).returns(String) }
  def call(action:, key:, value: nil)
    case action
    when "store"
      @store[key] = value
      "Stored '#{key}'"
    when "retrieve"
      @store.fetch(key, "No data found for '#{key}'")
    when "list"
      @store.keys.join(", ")
    else
      "Unknown action: #{action}"
    end
  end

  def initialize
    @store = {}
  end
end

class PersistentAgent < DSPy::Module
  class MemoryAwareSignature < DSPy::Signature
    description "Agent that stores and retrieves user context"

    input do
      const :user_message, String
      const :user_id, String
    end

    output do
      const :response, String
      const :actions_taken, T::Array[String]
    end
  end

  def initialize
    super
    @storage = StorageTool.new

    @agent = DSPy::ReAct.new(
      MemoryAwareSignature,
      tools: [@storage],
      max_iterations: 5
    )
  end

  def forward(user_message:, user_id:)
    result = @agent.call(
      user_message: user_message,
      user_id: user_id
    )

    # Application-level persistence (e.g., database, Redis)
    store_interaction(user_id, user_message, result.response)

    result
  end

  private

  def store_interaction(user_id, message, response)
    # Replace with your persistence layer (ActiveRecord, Redis, etc.)
    @interactions ||= Hash.new { |h, k| h[k] = [] }
    @interactions[user_id] << {
      user_message: message,
      assistant_response: response,
      timestamp: Time.now.iso8601
    }
  end
end
```

---

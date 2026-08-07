# GenAI Project Setup

## Contents
- Gemfile
- Environment variables
- Application bootstrap

## Gemfile

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

# AI/ML
gem "ruby_llm"
gem "pgvector"
gem "dspy"
gem "ruby-spacy"
gem "pragmatic_segmenter"

# Database
gem "sequel"

# MCP
gem "fast-mcp"

# Resilience
gem "circuit_breaker"

# Logging
gem "journald-logger"

# Tracing
gem "opentelemetry-sdk"
gem "opentelemetry-instrumentation-ruby_llm"
# gem "opentelemetry-exporter-otlp" # add when sending traces to a real collector;
                                     # omit in dev to use the default console/no-op exporter

# Type Safety
gem "dry-struct"
gem "dry-types"
gem "dry-schema"
gem "dry-validation"
gem "dry-monads"

group :development, :test do
  gem "dotenv"
  gem "pry"
  gem "pry-byebug"
  gem "rspec"
  gem "rubocop"
end
```

## Environment Variables

```bash
# .env (NEVER COMMIT)
OPENAI_API_KEY=sk-proj-...
ANTHROPIC_API_KEY=sk-ant-...
DATABASE_URL=postgresql://localhost/myapp_dev
REDIS_URL=redis://localhost:6379/0
```

```bash
# .env.example (COMMIT THIS)
# OpenAI API key - https://platform.openai.com/api-keys
OPENAI_API_KEY=

# Anthropic API key - https://console.anthropic.com/
ANTHROPIC_API_KEY=

# Database connection string
DATABASE_URL=postgresql://localhost/myapp_dev

# Redis connection (optional)
REDIS_URL=redis://localhost:6379/0
```

## Application Bootstrap

```ruby
# frozen_string_literal: true

require "dotenv/load"
require "journald/logger"

module MyApp
  def self.logger
    @logger ||= Journald::Logger.new("myapp")
  end

  def self.config
    @config ||= Config.new
  end

  class Config
    REQUIRED_VARS = %w[
      OPENAI_API_KEY
      DATABASE_URL
    ].freeze

    def validate!
      missing = REQUIRED_VARS.reject { |var| ENV.key?(var) }
      raise "Missing required environment variables: #{missing.join(', ')}" if missing.any?
    end

    def openai_api_key
      ENV.fetch("OPENAI_API_KEY")
    end

    def database_url
      ENV.fetch("DATABASE_URL")
    end
  end
end

# Validate configuration at startup
MyApp.config.validate!
```

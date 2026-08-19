---
title: Ruby Logging Patterns - Structured & Actionable
version: 1.1.0
last_updated: 2026-08-18
maintained_by: Syncopated Context
standard_logger: journald-logger (optional backend — see Overview)
---

# Ruby Logging Patterns - Structured & Actionable

## Overview

**Rule**: Logging/observability is a **required** consideration for every Standard-mode Ruby build in this plugin — not optional to think about, even when the specific backend is left to the specialist. Every external call (LLM, database, Redis, HTTP) MUST be logged with structured context, in whatever backend the build's `CROSS-CUTTING` decision names.

**The backend is a choice, not a mandate.** `journald-logger` is the recommended default when the target host runs systemd and log querying via `journalctl` is valuable (services, daemons, long-running agents). It is **not** required — pick whichever of the patterns below fits the project:

| Backend | Good fit when | Pattern |
|:---|:---|:---|
| `journald-logger` | Host runs systemd; want `journalctl`-queryable structured fields, native tagging | Pattern A below |
| stdlib `Logger` (per-class/method, file-based) | Portable/cross-platform tool, no systemd assumption, simple file rotation is enough | Pattern B below |
| DI'd `Ports::Logger` + `Null::Logger` (hexagonal) | Library/gem code that shouldn't hardcode a concrete logger; testability via `instance_spy` matters | Either backend above, injected — see "Dependency-Injected Logging" |

Whatever backend is chosen, the same principles apply:

**Principles**:
1. **Structured, not strings**: Use key-value pairs, not interpolated messages
2. **Actionable context**: Include request ID, user ID, trace ID
3. **Performance metrics**: Log latency, token count, cost estimates
4. **Error details**: Include error class, message, backtrace (truncated)

---

## Pattern A: journald-logger

**Gem**: `journald-logger` (`/theforeman/journald-logger`)

### Standard Pattern

```ruby
# frozen_string_literal: true

require "journald/logger"

module MyApp
  def self.logger
    @logger ||= Journald::Logger.new("my_app")
  end
end

# Usage
MyApp.logger.info("request_started", {
  request_id: SecureRandom.uuid,
  path: "/api/search",
  method: "POST"
})
```

### Module Mixin Pattern

```ruby
# frozen_string_literal: true

require "journald/logger"

module MyApp
  module Logging
    def logger
      @logger ||= Journald::Logger.new(self.class.name.downcase)
    end
  end
end

class MyService
  include MyApp::Logging
  
  def call
    logger.info("service_called", timestamp: Time.now.to_i)
  end
end
```

### Features

✅ **Native systemd integration**: Logs queryable via `journalctl`  
✅ **Structured fields**: Key-value pairs automatically indexed  
✅ **Tag support**: `logger.tagged("subsystem")` for namespacing  
✅ **Exception handling**: Automatic backtrace logging  
✅ **Trace logging**: Built-in support for request tracing

---

## Pattern B: stdlib Logger (per-class/method, file-based)

No extra gem — `Logger` ships with Ruby. Good default for tools that need to run identically on any host, without assuming systemd, and where `journalctl` querying isn't a requirement. Rotates by file size/count rather than relying on journald's own retention.

**Reference implementation**: `flowbots` (`~/WorkspaceV3/RubyStuff/flowbots/lib/flowbots/core/logging.rb`) — a `module_function`-based `Logging` module that memoizes one `Logger` per calling class, tags each entry's `progname` with `ClassName#method_name` (derived from `caller`), and rotates log files daily by embedding the date in the filename:

```ruby
# frozen_string_literal: true

module Logging
  module_function

  require "logger"

  LOG_DIR = File.expand_path(File.join(__dir__, "../../..", "log"))
  LOG_LEVEL = Logger::INFO
  LOG_MAX_SIZE = 2_145_728
  LOG_MAX_FILES = 100

  @loggers = {}

  def logger
    classname = self.class.name
    methodname = caller(1..1).first[/`([^']*)'/, 1]

    @logger ||= Logging.logger_for(classname, methodname)
    @logger.progname = "#{classname}##{methodname}"
    @logger
  end

  class << self
    def log_level = Logger::DEBUG

    def logger_for(classname, methodname)
      @loggers[classname] ||= configure_logger_for(classname, methodname)
    end

    def configure_logger_for(_classname, _methodname)
      current_date = Time.now.strftime("%Y-%m-%d")
      log_file = File.join(LOG_DIR, "myapp-#{current_date}.log")

      logger = Logger.new(log_file, LOG_MAX_FILES, LOG_MAX_SIZE)
      logger.level = log_level
      logger
    end
  end
end

# Usage: include Logging, then call `logger.info(...)` from any instance method —
# progname is set automatically to "ClassName#method_name" per call site.
```

**Trade-off vs. journald-logger**: stdlib `Logger` gives you free-text/formatted lines by default, not automatically-indexed structured fields — apply the same "structured, not strings" principle from the Overview manually (pass a hash or build a formatter), since `Logger` won't enforce it for you the way `journald-logger`'s field-based API does.

---

## Dependency-Injected Logging (hexagonal / ports pattern)

For library code, gems, or any layer that shouldn't hardcode a concrete logger (so it stays testable and backend-agnostic), inject the logger as a keyword argument defaulting to a no-op implementation, rather than calling a global `MyApp.logger` directly:

```ruby
# frozen_string_literal: true

module Core
  module Ports
    # Duck-type contract: debug/info/warn/error, each accepting a block
    # for lazy message evaluation.
    module Logger
    end

    module Null
      class Logger
        def debug(message = nil) = nil
        def info(message = nil) = nil
        def warn(message = nil) = nil
        def error(message = nil) = nil
      end
    end
  end
end

class ClauseProcessor
  def initialize(logger: Core::Ports::Null::Logger.new)
    @logger = logger
  end

  def call(clause)
    @logger.debug { "processing clause #{clause.id}" }
    # ...
  end
end
```

Either Pattern A (`journald-logger`) or Pattern B (stdlib `Logger`) can sit behind this contract as the real implementation; tests inject the `Null::Logger` default or an `instance_spy` against the port module. This is the pattern to reach for whenever a build's `CROSS-CUTTING` decision needs to apply across multiple independently-built layers (e.g. several parallel-dispatched specialists) without each one hardcoding a different concrete logger.

---

## Logging Patterns

The four patterns below are written against `journald-logger`'s `logger.info("event_name", {hash})` call shape (Pattern A). The underlying principle — structured event name + key-value context, always including latency/error-class/backtrace where relevant — applies identically under Pattern B or the DI'd ports pattern; adapt the call syntax to whichever backend the build's `CROSS-CUTTING` decision named (e.g. stdlib `Logger` typically takes a single formatted string or a block, so build the structured hash yourself and pass it through a custom formatter or interpolate it deliberately, rather than relying on journald's automatic field indexing).

### Pattern 1: LLM API Calls

```ruby
def call_llm(prompt:, model:, max_tokens:)
  start_time = Time.now
  request_id = SecureRandom.uuid
  
  logger.info("llm_request_started", {
    request_id: request_id,
    model: model,
    prompt_length: prompt.length,
    max_tokens: max_tokens
  })
  
  response = llm.complete(prompt: prompt, model: model, max_tokens: max_tokens)
  elapsed_ms = ((Time.now - start_time) * 1000).round(2)
  
  logger.info("llm_request_completed", {
    request_id: request_id,
    model: model,
    tokens_used: response.usage.total_tokens,
    latency_ms: elapsed_ms,
    cost_usd: estimate_cost(model, response.usage.total_tokens)
  })
  
  response
rescue StandardError => e
  elapsed_ms = ((Time.now - start_time) * 1000).round(2)
  
  logger.error("llm_request_failed", {
    request_id: request_id,
    model: model,
    error_class: e.class.name,
    error_message: e.message,
    latency_ms: elapsed_ms,
    backtrace: e.backtrace.first(5)
  })
  
  raise
end
```

**Key Fields**:
- `request_id`: Unique identifier for correlation
- `model`: LLM model name (gpt-4o-mini, claude-sonnet-4)
- `tokens_used`: Total token count (prompt + completion)
- `latency_ms`: Round-trip time in milliseconds
- `cost_usd`: Estimated cost per request

### Pattern 2: Database Queries

```ruby
def query_embeddings(query_embedding:, limit:)
  start_time = Time.now
  query_id = SecureRandom.uuid
  
  logger.info("db_query_started", {
    query_id: query_id,
    operation: "vector_search",
    table: "embeddings",
    limit: limit
  })
  
  results = DB[:embeddings]
    .order(Sequel.lit("embedding <=> ?", query_embedding))
    .limit(limit)
    .all
  
  elapsed_ms = ((Time.now - start_time) * 1000).round(2)
  
  logger.info("db_query_completed", {
    query_id: query_id,
    operation: "vector_search",
    rows_returned: results.size,
    latency_ms: elapsed_ms
  })
  
  results
rescue Sequel::DatabaseError => e
  elapsed_ms = ((Time.now - start_time) * 1000).round(2)
  
  logger.error("db_query_failed", {
    query_id: query_id,
    operation: "vector_search",
    error_class: e.class.name,
    error_message: e.message,
    latency_ms: elapsed_ms
  })
  
  raise
end
```

**Key Fields**:
- `query_id`: Unique identifier
- `operation`: Type of query (vector_search, insert, update)
- `table`: Target table
- `rows_returned`: Result count
- `latency_ms`: Query execution time

### Pattern 3: Circuit Breaker Events

```ruby
require "circuit_breaker"

circuit = CircuitBreaker.new(
  threshold: 5,
  timeout: 30,
  reevaluate_after: 60
)

circuit.on(:open) do
  logger.warn("circuit_breaker_opened", {
    circuit: "llm_api",
    threshold: 5,
    consecutive_failures: circuit.failure_count
  })
end

circuit.on(:close) do
  logger.info("circuit_breaker_closed", {
    circuit: "llm_api"
  })
end

circuit.on(:half_open) do
  logger.info("circuit_breaker_half_open", {
    circuit: "llm_api",
    reevaluate_after: 60
  })
end

begin
  circuit.call do
    call_external_api
  end
rescue CircuitBreaker::OpenError
  logger.error("circuit_breaker_blocked", {
    circuit: "llm_api",
    reason: "circuit_open"
  })
  raise
end
```

**Key Fields**:
- `circuit`: Circuit identifier
- `threshold`: Failure threshold before opening
- `consecutive_failures`: Current failure count
- `reevaluate_after`: Seconds until half-open state

### Pattern 4: Batch Operations

```ruby
def batch_embed(clauses:, batch_size: 10)
  batch_id = SecureRandom.uuid
  total = clauses.size
  
  logger.info("batch_started", {
    batch_id: batch_id,
    operation: "embedding_generation",
    total_items: total,
    batch_size: batch_size
  })
  
  processed = 0
  failures = 0
  
  clauses.each_slice(batch_size) do |batch|
    batch.each do |clause|
      begin
        embed(clause.text)
        processed += 1
      rescue StandardError => e
        failures += 1
        logger.warn("batch_item_failed", {
          batch_id: batch_id,
          clause_id: clause.id,
          error_class: e.class.name,
          error_message: e.message
        })
      end
    end
    
    logger.info("batch_progress", {
      batch_id: batch_id,
      processed: processed,
      total: total,
      failures: failures,
      percent_complete: ((processed.to_f / total) * 100).round(2)
    })
  end
  
  logger.info("batch_completed", {
    batch_id: batch_id,
    processed: processed,
    failures: failures,
    success_rate: ((processed - failures).to_f / processed * 100).round(2)
  })
end
```

**Key Fields**:
- `batch_id`: Unique batch identifier
- `total_items`: Total items to process
- `processed`: Items processed so far
- `failures`: Failed items
- `percent_complete`: Progress percentage

---

## Anti-Patterns

### ❌ Anti-Pattern 1: String Interpolation

```ruby
# Bad
logger.info("User #{user_id} searched for #{query} and got #{results.size} results")
```

**Problem**: Not machine-parseable, no structured queries

```ruby
# Good
logger.info("search_executed", {
  user_id: user_id,
  query: query,
  results_count: results.size
})
```

### ❌ Anti-Pattern 2: Logging Exceptions as Strings

```ruby
# Bad
rescue StandardError => e
  logger.error("Error: #{e.message}")
end
```

**Problem**: Loses backtrace, error class, context

```ruby
# Good
rescue StandardError => e
  logger.error("operation_failed", {
    operation: "embed_generation",
    error_class: e.class.name,
    error_message: e.message,
    backtrace: e.backtrace.first(5)
  })
end
```

### ❌ Anti-Pattern 3: No Performance Metrics

```ruby
# Bad
response = llm.complete(prompt: prompt)
logger.info("LLM call completed")
```

**Problem**: No latency, token count, or cost tracking

```ruby
# Good
start_time = Time.now
response = llm.complete(prompt: prompt)
elapsed_ms = ((Time.now - start_time) * 1000).round(2)

logger.info("llm_completed", {
  model: "gpt-4o-mini",
  tokens: response.usage.total_tokens,
  latency_ms: elapsed_ms,
  cost_usd: estimate_cost("gpt-4o-mini", response.usage.total_tokens)
})
```

### ❌ Anti-Pattern 4: Logging Sensitive Data

```ruby
# Bad
logger.info("user_login", {
  username: username,
  password: password  # NEVER LOG PASSWORDS
})
```

**Problem**: Security breach, compliance violation

```ruby
# Good
logger.info("user_login", {
  username: username,
  auth_method: "password",
  success: true
})
```

---

## Log Levels

| Level | When to Use | Example |
|:------|:------------|:--------|
| **DEBUG** | Development only, verbose | Variable values, control flow |
| **INFO** | Normal operations | Request started, batch progress |
| **WARN** | Degraded but functional | Circuit breaker half-open, fallback used |
| **ERROR** | Operation failed | API call failed, query timeout |
| **FATAL** | System unrecoverable | Database unavailable, config missing |

---

## Querying Logs

### Journald (systemd)

```bash
# All logs for app
journalctl -u my_app.service

# Logs with specific field
journalctl -u my_app.service REQUEST_ID=abc-123

# Logs since timestamp
journalctl -u my_app.service --since "2026-05-25 10:00:00"

# Follow logs in real-time
journalctl -u my_app.service -f
```

### JSON Logs (stdout)

```bash
# Filter by event
cat app.log | jq 'select(.event == "llm_request_completed")'

# Calculate average latency
cat app.log | jq -s 'map(select(.event == "llm_request_completed").latency_ms) | add / length'

# Group by error class
cat app.log | jq -s 'group_by(.error_class) | map({error: .[0].error_class, count: length})'
```

---

## Integration with Skills

### In SKILL.md Procedures

```markdown
## Procedure

1. Initialize logger:
   ```ruby
   logger = MyApp.logger
   ```

2. Log request start:
   ```ruby
   logger.info("operation_started", operation: "rag_query", query: query)
   ```

3. Wrap external calls:
   ```ruby
   start_time = Time.now
   response = llm.complete(prompt: prompt)
   logger.info("llm_completed", latency_ms: (Time.now - start_time) * 1000)
   ```

4. Log errors with context:
   ```ruby
   rescue StandardError => e
     logger.error("operation_failed", error_class: e.class.name, error_message: e.message)
     raise
   end
   ```
```

---

## References

- [Journald Logger](https://github.com/theforeman/journald-logger)
- [Semantic Logger](https://logger.rocketjob.io/)
- [Ruby Logger (stdlib)](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html)

---

**Last Updated**: 2026-05-25  
**Next Review**: After implementing logging in all 5 core skills  
**Status**: Active

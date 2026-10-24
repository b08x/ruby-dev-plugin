# Yardoc Context7 Integration (decode tag style)

## Contents
- decode tag-syntax verification workflow
- The decode library ID
- Verifying method signatures
- Batch verification for multiple gems
- Query patterns table
- Fallback strategy

## decode Tag-Syntax and Gem API Verification

Use Context7 for two lookups before generating documentation: the decode tag syntax (`/socketry/decode`), and the API of each non-stdlib gem whose types appear in `@parameter`, `@returns`, or `@attribute` tags.

**Verification Workflow:**

1. **Query `/socketry/decode`** when a tag or type notation is not covered by [decode-tags.md](decode-tags.md)
2. **Resolve and query each gem's library ID** for the methods and types the documented code uses
3. **Validate gem version compatibility** against project requirements
4. **Cache verified signatures** for offline use with fallback warnings

**Example: Querying the decode library:**

```ruby
# The decode library ID is known; no resolve step is needed
# Library ID: /socketry/decode (docs site index: /websites/socketry_github_io_decode)

# Query Context7 for decode tag syntax
library_id = "/socketry/decode"
query = "@yields pragma with nested @parameter tags for block arguments"

# The Context7 response provides:
# - Verified method signatures
# - Type annotation patterns
# - Version-specific API changes
# - Compatibility notes
```

**Example: Verifying Method Signatures via Context7:**

```ruby
# When documenting a method whose parameters or return values are gem types
# First, verify the gem context via Context7

def verify_gem_api(library_id, method_name, gem_version = nil)
  library_id = "#{library_id}/#{gem_version}" if gem_version

  # Query Context7 for the specific method
  query = "#{method_name} method signature, parameters, and return types"

  # Process Context7 response
  context7_result = mcp_context7_query_docs(
    libraryId: library_id,
    query: query
  )

  if context7_result[:verified]
    # Use verified signature for documentation
    verified_signature = context7_result[:signature]
    type_annotations = context7_result[:types]

    Success({
      signature: verified_signature,
      types: type_annotations,
      source: "context7_verified",
      version: gem_version || "latest"
    })
  else
    # Fallback to cached or conservative types
    Failure[:context7_unavailable,
            "Gem API verification failed: #{context7_result[:error]}"]
  end
end
```

**Example: Batch Verification for Multiple Gems:**

```ruby
# Verify multiple gem dependencies for a Ruby file
def verify_gem_contexts(file_path)
  # Parse file for gem dependencies
  gem_dependencies = extract_gem_dependencies(file_path)

  verification_results = gem_dependencies.map do |gem_name, version_constraint|
    verify_via_context7(gem_name, version_constraint)
  end

  # Collect results
  all_verified = verification_results.all?(&:success?)
  unverified_gems = verification_results.select(&:failure?).map(&:failure)

  if all_verified
    Success(verification_results.map(&:value!))
  else
    # Partial verification - proceed with warnings
    Success({
      verified: verification_results.select(&:success?).map(&:value!),
      unverified: unverified_gems,
      warnings: ["Some gem contexts unverified - using cached signatures"]
    })
  end
end

# Helper to extract gem dependencies from Ruby file
def extract_gem_dependencies(file_path)
  content = File.read(file_path)

  # Find require statements and Gemfile references
  dependencies = {}

  # Match require 'gem_name' patterns
  content.scan(/require\s+["']([^"']+)["']/).each do |gem_name|
    clean_name = gem_name.first.split('/').first
    dependencies[clean_name] ||= "any"
  end

  # Match Gemfile gem entries
  if File.exist?("Gemfile")
    gemfile_content = File.read("Gemfile")
    gemfile_content.scan(/gem\s+["']([^"']+)["']\s*,\s*["']([^"']*)["']/).each do |name, version|
      dependencies[name] = version.empty? ? "any" : version
    end
  end

  dependencies
end
```

## Context7 Query Patterns

| Query Type | Example Query | Use Case |
|------------|---------------|----------|
| Method signature | "Sequel::Dataset#where parameters and return type" (gem library ID) | Verify the type in a `@parameter` or `@returns` tag |
| Type notation | "Hash(Symbol, Array(String)) and Interface(:each) type signatures" (`/socketry/decode`) | Composite and duck-typed type formatting |
| Tag syntax | "@raises and @throws pragma format" (`/socketry/decode`) | Exception and throw documentation |
| RBS output | "@rbs pragma and bake decode:rbs:generate" (`/socketry/decode`) | Explicit RBS signatures in comments |
| Coverage | "bake decode:index:coverage and @namespace" (`/socketry/decode`) | Coverage measurement and namespace-only modules |

## Fallback Strategy

When Context7 is unavailable or returns incomplete results:
1. Use cached signatures from previous sessions (with `# type annotation based on stale cache — verify before publishing`)
2. Apply conservative type inference (String, Object, etc.)
3. Document the uncertainty in the generated decode comments
4. Flag for manual review in the quality assurance phase

# Dspy-Ruby_Docs - Signatures

**Pages:** 3

---

## DSPy Signatures: Type-Safe LLM Interfaces in Ruby | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/core-concepts/signatures/

**Contents:**
- Signatures
- Declare a Signature
- Declare Inputs
  - Choose Sorbet Types
- Date and Time Types
  - Date/Time Format Handling
  - Preserve Time Zones
- Declare Outputs
  - Using Enums for Controlled Outputs
  - Using Structs for Structured Outputs

Signatures define the interface between an application and a language model. They declare inputs, outputs, and task descriptions with Sorbet types; runtime validation rejects values outside the declared shape.

DSPy.rb serializes and deserializes these date and time types:

Following ActiveRecord conventions:

You can use T.any() to specify fields that can accept multiple types:

For more complex union types with structs and automatic type conversion, see the Union Types section in Rich Types.

T.nilable(Type) controls values: the field accepts either Type or nil. It does not make a DSPy::Signature field omittable. Add default: when callers or model responses may omit the field.

The second construction fails because source_note remains in ContentGeneration.input_json_schema[:required]. The base DSPy schema and signature constructor therefore distinguish these cases:

For a standalone T::Struct, Sorbet treats a nilable const or prop as fully optional and initializes omission to nil. DSPy signature structs add declaration-level requiredness on top of that constructor behavior. For nested structs, inspect the generated schema: a Ruby default controls construction, while the schema may still require a non-null array key from the model.

Provider adapters may tighten the base schema. For example, OpenAI strict structured outputs mark every property as required, including fields with DSPy defaults. In that mode, the model must return the key; the default remains useful for non-strict responses and direct Ruby construction. Inspect the adapter schema you deploy instead of assuming every provider preserves base DSPy omission rules.

Defaults supply declared values when construction or a language-model response omits a field:

Input defaults apply when creating the input struct and let callers omit declared fields.

Output defaults supply declared values when a response omits defaulted fields.

DSPy.rb supports two schema formats for communicating with language models: JSON Schema (default) and BAML Schema. The schema format controls how DSPy describes your signature’s structure to the LLM.

Signatures automatically generate JSON schemas for language model integration:

BAML (Basically A Markup Language) is a compact schema format for Enhanced Prompting mode (structured_outputs: false). The TextClassifier comparison below measures its character count against JSON Schema; measure tokens with the tokenizer for the model you deploy.

Configure BAML schema format:

Schema Format Comparison:

For the TextClassifier signature above:

JSON Schema (verbose):

BAML Schema (compact):

For rich signatures with nested types, BAML can reduce the characters used for schema guidance in Enhanced Prompting mode. Compare the generated schemas for your signature, and measure tokens with the tokenizer for the model you deploy.

Note: BAML format applies only to Enhanced Prompting mode (structured_outputs: false). When using Structured Outputs mode (structured_outputs: true), OpenAI’s native API receives the JSON Schema directly and BAML format has no effect.

When to Use JSON Schema:

Requirements: BAML format requires the sorbet-baml gem:

TOON is a table-oriented text format that keeps schemas readable while also shrinking the actual prompt values you send to the model. DSPy.rb exposes it via the new sorbet-toon integration.

(DSPy already requires sorbet/toon internally and auto-enables the struct/enum helpers. Require it yourself only if you need to call Sorbet::Toon.encode directly outside of DSPy.)

Schema vs. data format: schema_format: :toon swaps the JSON/BAML block in the system prompt with a TOON-oriented field summary (ordered props, optional markers, tabular hints). data_format: :toon tells DSPy to render the actual input values and required output template inside toon fences, and to parse the model’s reply back into hashes/structs.

Limitations to call out in your prompts/docs:

TOON uses the same signature metadata as BAML/JSON, so no additional schema definitions are needed—just flip the formats as shown above.

The gem is automatically included as a dependency of dspy-rb.

Need the converter outside of DSPy.rb? Install gem 'dspy-schema', '~> 1.0' and require 'dspy/schema' to reuse DSPy::TypeSystem::SorbetJsonSchema in other Ruby projects (see ADR-012).

DSPy automatically converts LLM JSON responses to the proper Ruby types:

Note: Enum matching is case-insensitive to handle LLMs returning values in different casing (e.g., "POSITIVE" instead of "positive"). With structured_outputs: true, providers enforce exact values. With structured_outputs: false, case-insensitive fallback prevents runtime errors from casing mismatches.

See Rich Types for detailed information.

When using DSPy::ChainOfThought, be aware that it automatically adds a :reasoning field to your signature’s output:

Important: If you define your own :reasoning field in a signature that will be used with ChainOfThought, it may cause conflicts or unexpected behavior.

Signatures declare the task boundary. Modules decide how to execute it, and runtime validation rejects values that cannot be converted to the declared Sorbet types.

**Examples:**

Example 1 (php):
```php
class TaskSignature < DSPy::Signature
  description "Clear description of what this signature accomplishes"
  
  input do
    const :field_name, String
  end
  
  output do
    const :result_field, String
  end
end
```

Example 2 (php):
```php
class TaskSignature < DSPy::Signature
  description "Clear description of what this signature accomplishes"
  
  input do
    const :field_name, String
  end
  
  output do
    const :result_field, String
  end
end
```

Example 3 (php):
```php
class BasicClassifier < DSPy::Signature
  description "Classify text into categories"
  
  input do
    const :text, String                    # Required string
    const :context, T.nilable(String)      # Required key; value may be nil
    const :max_length, Integer             # Required integer
    const :include_score, T::Boolean       # Boolean
    const :created_date, Date              # Date (ISO 8601 format)
    const :updated_at, DateTime            # DateTime with timezone
    const :processed_time, Time            # Time (converted to UTC)
    const :tags, T::Array[String]          # Array of strings
    const :metadata, T::Hash[String, String] # Hash with string keys/values
  end
end
```

Example 4 (php):
```php
class BasicClassifier < DSPy::Signature
  description "Classify text into categories"
  
  input do
    const :text, String                    # Required string
    const :context, T.nilable(String)      # Required key; value may be nil
    const :max_length, Integer             # Required integer
    const :include_score, T::Boolean       # Boolean
    const :created_date, Date              # Date (ISO 8601 format)
    const :updated_at, DateTime            # DateTime with timezone
    const :processed_time, Time            # Time (converted to UTC)
    const :tags, T::Array[String]          # Array of strings
    const :metadata, T::Hash[String, String] # Hash with string keys/values
  end
end
```

---

## Advanced Topics | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/

**Contents:**
- Advanced Topics
- Choose an Extension Task
  - Custom Toolsets
  - Rich Types
  - Package and Adapter Paths
  - Module Runtime Context
  - Reasoning Effort & Temperature
- Continue by task

These guides cover extension points after you can define a signature and run a module. For ordinary composition, retrieval, multimodal inputs, or agents, start from Build. For runtime integration and deployment concerns, use Operate.

Extend the baseline Toolset DSL with bounded application operations.

Work with structured data, nested objects, and rich type hierarchies in your signatures.

Choose the package that owns an adapter or optional subsystem, then keep package-specific setup and caveats in its linked package guide. General provider selection remains in Installation.

Control language-model resolution and propagation when an integration needs call-scoped behavior. Add cross-cutting call behavior in Module Lifecycle Callbacks.

Configure Anthropic extended thinking, effort tiers, and model-aware temperature/max_tokens handling.

The complete generated surface remains available in llms-full.txt when you need a single reference document.

**Examples:**

Example 1 (unknown):
```unknown
temperature
```

---

## Complex Types | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/complex-types/

**Contents:**
- Rich Types
- Choose a Rich Type
- Enum Types
  - Basic Enums
  - String Enum Values
  - Multiple Enum Fields
- Struct Types
  - Basic Structs
  - Nested Structs
- Collection Types

Signatures can use Sorbet enums, structs, unions, arrays, hashes, and nullable fields. DSPy.rb converts those declarations into an output schema and coerces the returned values at runtime.

Arrays can contain custom T::Struct types. When a returned JSON array contains compatible hashes, prediction coercion converts each hash to the declared T::Struct.

You can also use more complex structs with nested types:

In a DSPy::Signature, T.nilable allows nil; it does not remove the field from the schema’s required list. Add a default when omission is valid. See Nullable and Omittable Fields for the canonical rules and the standalone T::Struct boundary.

Use Sorbet’s T.any() syntax when one field may return one of several declared types.

You can use T.any() to specify that a field can be one of several types:

Union types can combine several struct types. DSPy.rb adds a _type discriminator to each struct schema so the returned object can be coerced to the correct type.

When DSPy.rb receives a response from the LLM for a union type field:

Declaring the union in the signature triggers these steps; no separate discriminator configuration is required.

When the LLM returns:

You can also use union types within arrays for heterogeneous collections:

Bound the alternatives: Start with two to four types, then inspect the generated schema and evaluate returned values before adding more.

Meaningful Struct Names: Use clear struct names as they become the _type value:

Tip: Use T::Array[X], default: [] when omission should produce an empty collection and nil is not meaningful. This is a data-modeling choice, not a universal provider requirement. Check the generated schema for nested structs: a Ruby default does not necessarily remove an array property from the schema’s required list.

Since v0.9.0, DSPy::Prediction has used the signature’s output schema to coerce compatible JSON values into declared Ruby types when a DSPy module builds the prediction.

DSPy.rb renders declared rich types in either of two schema formats:

For nested types, BAML can render a shorter schema than JSON Schema. Measure the difference for the signature and provider you use:

Schema length does not establish output quality. Compare token usage, validation failures, and task metrics before choosing a format.

See the Schema Formats section in Signatures for detailed comparison.

DSPy.rb has practical limits on nested struct complexity:

✅ Recommended Nesting (1-2 levels):

⚠️ Deep Nesting (3+ levels) - Use with Caution:

❌ Avoid Excessive Nesting (5+ levels):

Schema Caching: DSPy.rb caches rendered JSON schemas for repeated use:

Provider Optimization: Different providers handle rich types differently:

Type Coercion Issues: If you get Hash objects instead of T::Struct instances:

Schema Validation: Check schema depth warnings:

Alternative Approaches: Instead of deep nesting, consider:

**Examples:**

Example 1 (php):
```php
class Sentiment < T::Enum
  enums do
    Positive = new('positive')
    Negative = new('negative')
    Neutral = new('neutral')
  end
end

class ClassifyText < DSPy::Signature
  description "Classify text sentiment"
  
  input do
    const :text, String
  end
  
  output do
    const :sentiment, Sentiment
    const :confidence, Float
  end
end

# Usage
classifier = DSPy::Predict.new(ClassifyText)
result = classifier.call(text: "I love this product!")
puts result.sentiment.serialize  # => "positive"
```

Example 2 (php):
```php
class Sentiment < T::Enum
  enums do
    Positive = new('positive')
    Negative = new('negative')
    Neutral = new('neutral')
  end
end

class ClassifyText < DSPy::Signature
  description "Classify text sentiment"
  
  input do
    const :text, String
  end
  
  output do
    const :sentiment, Sentiment
    const :confidence, Float
  end
end

# Usage
classifier = DSPy::Predict.new(ClassifyText)
result = classifier.call(text: "I love this product!")
puts result.sentiment.serialize  # => "positive"
```

Example 3 (php):
```php
class Priority < T::Enum
  enums do
    Low = new('low')
    Medium = new('medium')
    High = new('high')
    Critical = new('critical')
  end
end

class TicketClassifier < DSPy::Signature
  description "Classify support ticket priority"
  
  input do
    const :ticket_content, String
  end
  
  output do
    const :priority, Priority
    const :reasoning, String
  end
end
```

Example 4 (php):
```php
class Priority < T::Enum
  enums do
    Low = new('low')
    Medium = new('medium')
    High = new('high')
    Critical = new('critical')
  end
end

class TicketClassifier < DSPy::Signature
  description "Classify support ticket priority"
  
  input do
    const :ticket_content, String
  end
  
  output do
    const :priority, Priority
    const :reasoning, String
  end
end
```

---

# Example: decode Tag Generation for dry-struct Classes

A complete, runnable example that documents a dry-struct class in decode tag style, generates `@attribute` comments from the struct schema, and verifies the result by parsing it with `Decode::Index`. Requires the `dry-struct` and `decode` gems.

decode indexes each dry-struct `attribute :name, Type` call as a definition, so an `@attribute` comment placed directly above the call is attached to that attribute and counts toward `bake decode:index:coverage`.

```ruby
# frozen_string_literal: true

require "dry-struct"
require "decode/index"
require "tempfile"

module Types
  include Dry.Types()
end

module MyApp
  # A user account in the MyApp system, with type-checked attributes.
  #
  # The struct is immutable. Build a changed copy with `new` instead of mutating it.
  #
  # @example Create a user
  #   user = MyApp::User.new(id: 1, name: "Alice", email: "alice@example.com")
  #   user.id # => 1
  #   user.active # => true
  #
  # @example Create a user with optional fields
  #   user = MyApp::User.new(
  #     id: 2,
  #     name: "Bob",
  #     email: "bob@example.com",
  #     metadata: {role: "admin"}
  #   )
  #   user.metadata # => {role: "admin"}
  class User < Dry::Struct
    # @attribute [Integer] The unique identifier of the user.
    attribute :id, Types::Integer

    # @attribute [String] The full name of the user, 2 to 100 characters.
    attribute :name, Types::String

    # @attribute [String] The email address of the user.
    attribute :email, Types::String

    # @attribute [Time | Nil] The creation time, set when the record is persisted.
    attribute :created_at, Types::Time.optional

    # @attribute [bool] Whether the account is active. Defaults to `true`.
    attribute :active, Types::Bool.default(true)

    # @attribute [Hash(Symbol, String) | Nil] Additional metadata, serialized as JSON when persisted.
    attribute :metadata, Types::Hash.map(Types::Symbol, Types::String).optional
  end
end

module MyApp
  module Documentation
    # Generates decode `@attribute` comments from the schema of a dry-struct class.
    class Generator
      # Generate an `@attribute` comment for every attribute of a dry-struct class.
      #
      # @parameter klass [Class] The dry-struct class to document.
      # @returns [Hash(Symbol, String)] A map from attribute name to its comment line.
      # @raises [ArgumentError] If `klass` is not a dry-struct class.
      #
      # @example Generate comments for {MyApp::User}
      #   MyApp::Documentation::Generator.new.generate(MyApp::User)[:id]
      #   # => "# @attribute [Integer] TODO: describe id."
      def generate(klass)
        validate_dry_struct!(klass)

        klass.schema.keys.to_h do |key|
          [key.name, "# @attribute [#{decode_type(key.type)}] TODO: describe #{key.name}."]
        end
      end

      # Parse a Ruby source string with decode and list the tag classes attached to each definition.
      #
      # @parameter source [String] Ruby source code containing decode comments.
      # @returns [Hash(String, Array(String))] A map from qualified definition name to tag class names.
      def verify(source)
        Tempfile.create(["decode-verify", ".rb"]) do |file|
          file.write(source)
          file.flush

          index = Decode::Index.new
          index.update([file.path])

          index.definitions.to_h do |name, definition|
            tags = definition.documentation&.children.to_a.map { |node| node.class.name.split("::").last }
            [name, tags]
          end
        end
      end

      private

      # Check that `klass` is a dry-struct class.
      #
      # @parameter klass [Class] The class to check.
      # @raises [ArgumentError] If `klass` does not inherit from `Dry::Struct`.
      def validate_dry_struct!(klass)
        return if klass.is_a?(Class) && klass < Dry::Struct

        raise ArgumentError, "#{klass} is not a dry-struct class"
      end

      # Convert a dry-types type into decode type notation.
      #
      # @parameter type [Dry::Types::Type] The attribute type.
      # @returns [String] The type in decode notation, such as `Array(String)` or `Time | Nil`.
      def decode_type(type)
        type = type.type if type.default?
        return "#{decode_type(type.right)} | Nil" if type.optional?
        return "bool" if type == Types::Bool

        primitive = type.respond_to?(:primitive) ? type.primitive : Object
        primitive == Array ? "Array(#{decode_type(type.member)})" : primitive.name
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  generator = MyApp::Documentation::Generator.new

  # Generated comment lines, one per attribute:
  generator.generate(MyApp::User).each_value { |line| puts line }

  # Round-trip check: decode must parse the comments into Attribute nodes:
  puts generator.verify(File.read(__FILE__)).select { |name, _| name.start_with?("MyApp::User::") }
end
```

## Expected output

```text
# @attribute [Integer] TODO: describe id.
# @attribute [String] TODO: describe name.
# @attribute [String] TODO: describe email.
# @attribute [Time | Nil] TODO: describe created_at.
# @attribute [bool] TODO: describe active.
# @attribute [Hash | Nil] TODO: describe metadata.
{"MyApp::User::id" => ["Attribute"], ...}
```

The `metadata` line prints `Hash | Nil`, not `Hash(Symbol, String) | Nil`, because `decode_type` does not expand map types. Write the full `Hash(Symbol, String)` notation by hand, as the hand-written comment on the struct does.

## YARD constructs with no decode equivalent

| YARD | decode replacement |
|---|---|
| `@!attribute [r] name` directive block | `# @attribute [Type] Description.` directly above the `attribute` or `attr_*` call |
| Custom tags registered through `YARD::Tags::Library` (`@domain`, `@validation`) | Plain Markdown sentences in the description. decode parses unknown tags as text. |
| `@note`, `@since` | Plain Markdown sentences in the description |
| `YARD::Rake::YardocTask` | `bundle exec bake decode:index:coverage lib` and `bundle exec bake decode:index:documentation lib` |

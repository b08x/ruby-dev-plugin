# decode Documentation Tags and Conventions

The documentation comment format parsed by the [decode](https://github.com/socketry/decode) gem (`Decode::Index`, `bake decode:index:*`, `bake decode:rbs:generate`). decode does not parse YARD tags: `@param`, `@return`, `@raise`, and `@yieldparam` lines are read as plain text, so they produce no structured data and no RBS output.

## Contents
- Tag reference
- Type notation
- YARD to decode conversion table
- Writing rules
- Examples
- Anti-patterns
- Tooling commands

## Tag Reference

Registered tags, from `Decode::Language::Ruby::Generic::TAGS` (decode 0.30.0):

| Tag | Syntax | Use |
|---|---|---|
| `@parameter` | `@parameter name [Type] Description.` | One line per positional, keyword, splat, or block parameter. The name comes first, then the type. |
| `@option` | `@option :key [Type] Description.` | One line per key accepted through `**options` or an options hash. |
| `@returns` | `@returns [Type] Description.` | Return value. Use `[void]` when the return value is not part of the contract. |
| `@raises` | `@raises [ExceptionClass] Condition that raises it.` | One line per exception class the method raises on purpose. |
| `@throws` | `@throws [:symbol] Condition that throws it.` | Symbols thrown for `catch`/`throw` control flow. |
| `@yields` | `@yields {\|a, b\| ...} Description.` | Block contract. Document the block parameters with indented `@parameter` lines under it. |
| `@attribute` | `@attribute [Type] Description.` | Directly above an `attr_reader`/`attr_writer`/`attr_accessor` call, or a dry-struct `attribute` call. One attribute per comment. |
| `@example` | `@example Optional title` followed by indented code lines | Usage example. Several `@example` tags per definition are allowed. |
| `@deprecated` | `@deprecated Use {replacement} instead.` | Marks the definition as deprecated. |
| `@asynchronous` | `@asynchronous` | The method must run inside an Async reactor (an `Async` block or a task). |
| `@public` / `@private` | `@public` / `@private` | Documentation visibility, independent of Ruby visibility. `@private` replaces YARD `@api private`. |
| `@namespace` | `@namespace` | A module that exists only to group constants. Counts as documented for coverage. |
| `@rbs` | `@rbs (String) -> Integer` | An explicit RBS method signature, used by `bake decode:rbs:generate` in place of the inferred one. |

Structural pragmas: `@name custom_name` sets the definition name decode records, and `@scope Module::Name` sets the namespace it records it under. Use them only for metaprogrammed definitions that decode cannot see.

## Type Notation

| Meaning | decode notation |
|---|---|
| Primitive | `String`, `Integer`, `Float`, `Symbol`, `bool` |
| Ordered collection | `Array(String)` |
| Map | `Hash(Symbol, Integer)` |
| Nested | `Hash(String, Array(Integer))` |
| Union | `String \| Symbol` |
| Optional (nilable) | `String \| Nil` |
| Duck type | `Interface(:each, :size)` |
| No meaningful return | `void` |
| Library class | Fully qualified constant: `Async::Task`, `Dry::Monads::Result` |

## YARD to decode Conversion Table

Apply this table when a file in `PATHS` already contains YARD tags. Convert the tags on every definition the task touches. Do not convert files outside `PATHS`.

| YARD | decode |
|---|---|
| `@param [String] name Text` | `@parameter name [String] Text` |
| `@param name [String] Text` | `@parameter name [String] Text` |
| `@option opts [Integer] :timeout Text` | `@option :timeout [Integer] Text` |
| `@return [String] Text` | `@returns [String] Text` |
| `@raise [ArgumentError] Text` | `@raises [ArgumentError] Text` |
| `@yield [x] Text` + `@yieldparam [T] x Text` | `@yields {\|x\| ...} Text` + indented `@parameter x [T] Text` |
| `@yieldreturn [T] Text` | A sentence in the `@yields` description: "The block returns ..." |
| `@!attribute [r] name` + nested `@return [T]` | `@attribute [T] Text` directly above the `attr_*`/`attribute` call |
| `@api private` | `@private` |
| `@see Foo#bar` | `See {Foo#bar}.` in the description |
| `@note`, `@since`, `@todo` | A plain sentence in the description |
| `Array<String>` | `Array(String)` |
| `Hash{Symbol => String}` | `Hash(Symbol, String)` |
| `String, nil` | `String \| Nil` |
| `Boolean` | `bool` |
| `#each` (duck type) | `Interface(:each)` |
| `+code+` | `` `code` `` (backticks; comments are Markdown) |
| Leading `##` comment opener | `#` (decode reads every consecutive `#` line above the definition) |

## Writing Rules

1. **Full sentences.** Every definition comment is one or more complete sentences ending in a period, written in Markdown.
2. **Class comments state what the class is or does.** Data class: "A user account in the system." Functional class: "An HTTP client that keeps connections open between requests."
3. **Method comments state what the method does, not how.** "Normalize the email address to lowercase." not "Calls downcase and strip."
4. **Inline comments inside a method body end with a colon.** `# Validate the format before assignment:`. This separates them from definition documentation.
5. **Links use braces.** `{Decode::Index#lookup}` for an absolute reference, `{lookup}` for a method in the current scope, `{User}` for a class.
6. **Code uses backticks.** Symbols (`:admin`), literal values (`true`, `nil`), method names (`active?`).
7. **Indent nested tags and example code** by one level (two spaces or a tab) after the `#`. decode 0.30.0 accepts both; match the file's indentation.
8. **One tag per line.** Do not combine two parameters on one line.

## Examples

### Method with parameters, options, return value, and exceptions

```ruby
# Fetch the profile data for a user from the remote API.
#
# @parameter user [MyApp::User] The user whose profile is fetched.
# @option :timeout [Integer] Request timeout in seconds. Defaults to 5.
# @option :cached [bool] Whether to return a cached response when one exists.
# @returns [Hash(Symbol, String) | Nil] The profile fields, or `nil` when the user has no profile.
# @raises [MyApp::ApiError] If the API responds with a 5xx status.
def fetch_profile(user, **options)
  # Return the cached copy when allowed:
  return cache[user.id] if options[:cached] && cache.key?(user.id)

  client.get("/profiles/#{user.id}", timeout: options.fetch(:timeout, 5))
end
```

### Block contract

```ruby
# Iterate over the rows of a CSV file without loading the whole file.
#
# @parameter path [String] Absolute path of the CSV file.
# @yields {|row, line_number| ...} Each parsed row. The block's return value is ignored.
#   @parameter row [Hash(String, String)] The row, keyed by header name.
#   @parameter line_number [Integer] The 1-based line number of the row.
# @returns [Integer] The number of rows yielded.
def each_row(path, &block)
  # ...
end
```

### Attributes and examples

```ruby
# A search result page returned by {MyApp::SearchService#search}.
#
# @example Read the first result
#   page = MyApp::SearchService.new.search("ruby")
#   page.items.first.title # => "Ruby Programming Language"
class SearchPage < Dry::Struct
  # @attribute [Array(MyApp::Item)] The items on this page, in rank order.
  attribute :items, Types::Array.of(MyApp::Item)

  # @attribute [Integer] The total number of matches across all pages.
  attribute :total, Types::Integer
end
```

### Result monads

```ruby
# Find a user by id.
#
# @parameter id [Integer] The user id.
# @returns [Dry::Monads::Result] `Success(MyApp::User)` when found, `Failure(:not_found)` otherwise.
#
# @example Pattern-match the result
#   case MyApp::UserService.new.find_user(999)
#   in Dry::Monads::Success(user) then user.email
#   in Dry::Monads::Failure(:not_found) then nil
#   end
def find_user(id)
  # ...
end
```

### Namespace-only module

```ruby
# @namespace
module MyApp
end
```

## Anti-patterns

| Anti-pattern | Correction |
|---|---|
| YARD tags (`@param`, `@return`) in new comments | decode tags. YARD tags parse as plain text. |
| Type before name in `@parameter` (`@parameter [String] name`) | Name before type: `@parameter name [String]` |
| `@returns [Hash] The results` | State the structure: `@returns [Hash(Symbol, Integer)] Counts keyed by status.` |
| `@returns [Hash] User data` when a struct exists | `@returns [MyApp::User] The user.` |
| Vague description ("Processes data") | State the transformation: "Convert CSV rows into `MyApp::Clause` structs." |
| Trivial example (`add(1, 2) # => 3`) | An example that shows a non-obvious argument or return shape |
| Comment on every obvious accessor | `@attribute` lines on struct attributes; no extra prose for trivial readers |
| Mixing terms for one concept ("user", "account", "person") | One term, matching the class name |

## Tooling Commands

Run these in the project root. The orchestrator adds `decode` and `bake` to the project Gemfile before dispatch (`tasks/analysis-gems.md` at the plugin root).

| Command | Output |
|---|---|
| `bundle exec bake decode:index:coverage lib` | "N definitions have documentation, out of M public definitions." followed by each undocumented definition with `path:line`. Exits non-zero when any public definition is undocumented. |
| `bundle exec bake decode:index:documentation lib` | Markdown listing of every documented definition, for review. |
| `bundle exec bake decode:index:symbols lib` | Every indexed symbol, for checking that decode sees a metaprogrammed definition. |
| `bundle exec bake decode:rbs:generate lib` | RBS signatures built from `@parameter`, `@returns`, `@attribute`, and `@rbs` tags, written to stdout. |

To check the tags on one file programmatically:

```ruby
require "decode/index"

index = Decode::Index.new
index.update(["lib/my_app/user.rb"])

index.definitions.each do |name, definition|
  tags = definition.documentation&.children.to_a.map { |node| node.class.name.split("::").last }
  puts "#{name}: #{tags.join(', ')}"
end
# MyApp::User#full_name: Text, Returns
```

A definition whose output lists only `Text` while its comment contains `@` lines has unparsed tags, which usually means YARD syntax or a misspelled tag name.

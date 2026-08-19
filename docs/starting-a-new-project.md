# Starting a New Project

The ruby-dev-plugin uses a **two-tool system** based on whether you're building an application or a gem.

## Decision Tree

```
Will this code be published to rubygems.org?
  Yes → gemsmith
  No  → Does it need a gemspec for private gem server or version pinning?
          Yes → gemsmith
          No  → rubysmith
```

## Archetype → Flag Presets

| Archetype | Tool | Command |
|---|---|---|
| CLI tool (personal) | `rubysmith` | `rubysmith build my_tool --git --rake --console --rspec --readme --license` |
| Data pipeline | `rubysmith` | `rubysmith build my_pipe --git --rake --rspec --readme` |
| Open source app | `rubysmith` | `rubysmith build my_app --max --license --funding --conduct --community` |
| Containerized service | `rubysmith` | `rubysmith build my_svc --git --rake --rspec --readme --docker` |
| Ruby gem (personal) | `gemsmith` | `gemsmith build --name my_gem --rspec --zeitwerk --github` |
| Ruby gem (public) | `gemsmith` | `gemsmith build --name my_gem --rspec --security --zeitwerk --github --circle-ci` |
| Gem with CLI | `gemsmith` | `gemsmith build --name my_gem --cli --rspec --security --zeitwerk --github` |
| Minimal script | `rubysmith` | `rubysmith build my_script --min` |

## Post-Scaffold Convention Pass

After `rubysmith build` or `gemsmith build`, apply these hardening steps:

1. **Frozen string literals** — `# frozen_string_literal: true` on line 1 of all `.rb` files
2. **Zeitwerk loader** — `require "zeitwerk"` + `Zeitwerk::Loader.for_gem.setup` in boot file
3. **Replace `puts`/`p`** — Swap for `journald-logger` structured logging
4. **Type safety** — Add `dry-struct`, `dry-types`, `dry-schema`, `dry-validation`, `dry-monads`
5. **Resilience** — Add `circuit_breaker` for external API calls
6. **Config** — Create `.env.example` with required variables, `dotenv` in Gemfile
7. **Debugging** — Configure `.pryrc` with project name

## Entry Points

- **Agent**: `agents/scaffolder.md` — triggers on "start project", "create gem", "scaffold"
- **Skill**: `skills/scaffold/SKILL.md` — the full procedure
- **Reference**: `references/rubysmith-scaffolding.md` — flag tables, config format, post-gen checklist
- **Patterns**: `skills/scaffold/references/scaffold-patterns.md` — 8-section decision guide

## Common Pitfalls

1. Wrong tool (`rubysmith` for apps, `gemsmith` for gems)
2. Missing config at `~/.config/rubysmith/configuration.yml`
3. Skipping the convention pass (skeleton → production)
4. Not running `ruby -c`, `bundle exec rspec`, `bin/setup` after scaffolding

## Generated Project Structure

### Full Project (Default)

```
my_project/
├── .caliber/                    # RuboCop configuration
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions CI
├── bin/
│   ├── console                  # Pry console
│   ├── docker                   # Docker scripts
│   └── setup                    # Setup script
├── lib/
│   ├── my_project/
│   │   └── .keep
│   └── my_project.rb           # Main entry point
├── spec/
│   ├── support/
│   │   └── shared_contexts/
│   │       └── application_context.rb
│   ├── spec_helper.rb
│   └── my_project_spec.rb
├── .dockerignore
├── .gitignore
├── .reek.yml                   # Reek configuration
├── .rspec                      # RSpec configuration
├── .rubocop.yml               # RuboCop configuration
├── .ruby-version              # Ruby version
├── .versions.yml              # Dependency versions
├── compose.yml                # Docker Compose
├── Dockerfile                 # Docker image
├── Gemfile
├── LICENSE                    # MIT License
├── my_project.gemspec
├── Rakefile
└── README.md
```

### Minimal Project (--min)

```
my_project/
├── lib/
│   ├── my_project/
│   │   └── .keep
│   └── my_project.rb
├── .gitignore
├── .ruby-version
├── Gemfile
└── README.md
```

## Post-Scaffold Checklist

- [ ] `bin/setup` completes without errors
- [ ] `bin/console` opens Pry REPL with project loaded
- [ ] `bundle exec rspec` runs (even if no specs yet)
- [ ] `bundle exec rubocop` passes
- [ ] Gemfile includes type safety gems (dry-struct, dry-types)
- [ ] Gemfile includes journald-logger
- [ ] Gemfile includes circuit_breaker (if calling external APIs)
- [ ] .env.example created with all required variables
- [ ] .env added to .gitignore
- [ ] Config class created with validation
- [ ] Logger singleton set up
- [ ] .pryrc configured with project name

## References

- [Rubysmith Documentation](https://alchemists.io/projects/rubysmith)
- [Rubysmith GitHub](https://github.com/bkuhlmann/rubysmith)
- [Zeitwerk](https://github.com/fxn/zeitwerk)
- [Caliber (RuboCop Config)](https://alchemists.io/projects/caliber)

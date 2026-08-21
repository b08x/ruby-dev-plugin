---
name: scaffold
description: "Use when scaffolding new Ruby projects or gems. Applies rubysmith/gemsmith flag presets by project archetype and runs convention passes for project hardening."
---

# RubyDev Scaffold — Project Scaffolding

## Overview

Starting a new Ruby project or gem requires dozens of decisions: test framework, CI, licensing, container setup, console, and more. The scaffold skill maps project archetypes to rubysmith/gemsmith flag presets, runs the scaffolding command, then applies a convention pass to harden the generated structure.

The full flag reference and decision guide lives in `references/scaffold-patterns.md`. The full approved-gem registry — which gems to reach for once the skeleton exists, and which sibling gem to pick when two overlap — lives in `references/gem-whitelist.md` (and its machine-readable form, `references/gemsets.yaml`).

## When to Use

- User says "start a new Ruby project" or "scaffold a CLI app"
- User says "create a new gem" or "publish a library"
- User provides a project name and type (e.g., "web app", "CLI tool", "gem library")
- A new project needs CI, Docker, testing, and documentation from day one

**Don't use for:**
- One-off scripts (just write a file)
- Rails applications (use Rails generators instead)
- Modifying existing projects (use [refactor/SKILL.md](../refactor/SKILL.md) or the [`rubyist` gateway agent](../../agents/rubyist.md))

## Archetype → Flag Preset

| Archetype | Tool | Key Flags |
|-----------|------|-----------|
| Bare min script | `rubysmith` | `--min` |
| CLI application | `rubysmith` | `--max --no-docker --no-git_hub_ci` |
| Web service | `rubysmith` | `--max` (all features) |
| Ruby gem (library) | `gemsmith` | `--max` (most flags shared with rubysmith) |
| Rails engine | `gemsmith` | `--max --rails` (if supported) |
| OSS project | `rubysmith` or `gemsmith` | `--max --license --funding --conduct --community` |
| Internal library | `gemsmith` | Core flags + `--git --rake --rspec --console` |

See `references/scaffold-patterns.md` sections 1-4 for complete flag tables and the rubysmith-vs-gemsmith decision guide.

## Convention Pass (Post-Scaffold)

After scaffolding, the skill runs a convention pass to harden the generated project. These are documented in `references/scaffold-patterns.md` Section 6:

1. **Ruby version pinning** — Ensure `.ruby-version` matches the active runtime
2. **Frozen string literals** — Add `# frozen_string_literal: true` to all `.rb` files
3. **Gemfile organization** — Group gems by purpose (development, test, runtime)
4. **Rakefile cleanup** — Remove unused tasks
5. **README hardening** — Fill placeholder sections
6. **Guardfile** — Add if using guard for auto-testing
7. **`.gitignore` audit** — Match standard Ruby gitignore

## Gemset Registry (Approved Gems)

Once the skeleton exists, adding dependencies is its own decision surface — this plugin
maintains a curated whitelist rather than letting `bundle add` decide. `references/gem-whitelist.md`
groups the whitelisted gems into **gemsets** (RVM's term for a named cluster of gems solving one
problem) and documents which sibling to pick when two gemsets overlap on the same problem — e.g.
`kreuzberg` vs `inkmark` for document intake, `ohm` vs `sequel` for storage, `async`/`falcon` vs
`concurrent-ruby` vs `parallel` for concurrency. `references/gemsets.yaml` is the same registry as
structured data, for archetype-driven Gemfile assembly or future semantic gem lookup.

Consult it after archetype selection, before finalizing the Gemfile in the convention pass:

1. Identify which gemsets the project's stated purpose touches (e.g. an AI/RAG tool touches
   `llm_client_rubyllm` or `llm_programs_dspy`, `vector_storage_retrieval`, `dry_rb_types`).
2. For any gemset with an overlapping sibling, apply the matching decision rule rather than
   picking arbitrarily or adding both.
3. For gemsets marked `status: gap` in `gemsets.yaml` (no owning skill yet), verify the gem's API
   inline via Context7/DeepWiki before generating code against it — the usual pitfalls/failover
   tables an owned skill would carry haven't been written for these yet.

## Failover

| Dependency | If Unavailable | Fallback |
|------------|---------------|----------|
| `rubysmith` gem | Not installed | `gem install rubysmith` first. If install fails, scaffold manually: create directory structure, Gemfile, Rakefile, and `bin/console` by hand. |
| `gemsmith` gem | Not installed | `gem install gemsmith` first. If install fails, scaffold a gem manually with `bundler`'s `gem` command. |
| `references/scaffold-patterns.md` | Pattern file not found | Use defaults (`--max` for project, `--git --rake --rspec` for gem). Document that flag reference was skipped. |
| `references/gem-whitelist.md` / `references/gemsets.yaml` | Registry file(s) not found | Fall back to the ad hoc gem suggestions in `references/scaffold-patterns.md` Section 8. Note in the output that the fuller gemset registry was skipped and any overlap decisions were made without its decision rules. |

## Common Pitfalls

1. **Wrong tool for the job**: `rubysmith` is for applications/scripts; `gemsmith` is for gems/libraries. Using the wrong tool produces an awkward structure.
2. **Missing config**: Both tools read `~/.config/rubysmith/configuration.yml`. If this file is missing, defaults may not match user preferences.
3. **Overriding existing files**: Never scaffold over an existing project directory without explicit user confirmation.
4. **Skipping the convention pass**: The scaffolding output is a skeleton. The convention pass (frozen strings, README hardening, Gemfile organization) turns it into a production-ready project.
5. **Missing post-scaffold verification**: After scaffolding, verify with `ruby -c`, `bundle exec rspec`, and `bin/setup` (if included).

## Verification Checklist

- [ ] Correct tool selected (rubysmith for app, gemsmith for gem)
- [ ] Scaffold command ran successfully
- [ ] Convention pass applied (frozen strings, ruby-version, Gemfile audit)
- [ ] `ruby -c` passes on generated files
- [ ] `bundle install` or equivalent succeeds
- [ ] Project directory structure matches expected archetype
- [ ] README placeholder sections filled
- [ ] Added gems checked against `references/gem-whitelist.md`; overlapping gemsets resolved via its decision rules, not picked arbitrarily
### Design Pattern References

Scaffolding decisions — directory layout, naming, and archetype selection — are governed by two patterns. Convention Over Configuration justifies the convention pass; Factory governs archetype dispatch.

#### Convention Over Configuration

**Problem**
We want to build an extensible system without carrying the configuration burden.

**Solution**
The **Convention Over Configuration** pattern suggests establishing some conventions based on class, method and file names, as well as a standard directory layout, instead of relying on configuration files.

**Structural constraints**
- Conventions are declared over class names, method names, file names, and directory layout — not config files.
- A name-based convention must be mechanically resolvable (e.g. `<protocol>Adapter` via `const_get`).
- A directory convention must permit dynamic loading of everything in the folder — no central require manifest.
- Extension points that need per-case override get a second, method-name convention rather than a config flag.
- Ship examples or a generator so extenders can discover the conventions.

#### Factory

**Problem**
We need to create objects without having to specify the exact class of the object that will be created.

**Solution**
The **Factory** pattern is a specialization of the Template pattern. We start by creating a generic base class where we don't make the "which class" decision. Instead, whenever it needs to create a new object, it calls a method that is defined in a subclass. So, depending on the subclass we use (**factory**), we create objects of one class or another (**products**).

**Structural constraints**
- The generic base class must not name a concrete product class anywhere.
- Object creation happens through a method defined in the subclass (the factory).
- Subclass choice, and only subclass choice, determines which products are created.
- Inherits Template Method's constraints — it is a specialization of that pattern.

---
name: refactor
description: "Use when applying named refactoring patterns to Ruby code. Matches code issues to known transformations (Zeitwerk, async, frozen strings, etc.) and applies surgical fixes."
---

# RubyDev Refactor — Named Pattern Refactoring

## Overview

Refactoring by hand is error-prone and inconsistent. The refactor skill matches code issues to named transformation patterns, then applies surgical fixes. Each pattern has a defined before/after shape, severity rating, and affected areas.

The pattern catalog lives in `references/refactor-patterns.md` — load it for the full list of available transforms. It covers three families: mechanical fixes (Zeitwerk, frozen strings, async), **OO design refactorings** (extract class, inject dependency, duck types, composition — warrants in [../../references/ood-principles.md](../../references/ood-principles.md)), and **resilience patterns** (backoff with jitter, fail-closed authorization, bang saves).

## When to Use

- `analyse` or `sift` identified a specific code issue (e.g., Zeitwerk mismatch, bare rescue, missing circuit breaker)
- You need to apply a known transformation like `thread_to_async` or `nested_conditionals`
- User says "fix this" with a clear symptom that matches an existing pattern
- Code review flagged a violation that has a mechanical fix

**Don't use for:**
- Exploratory code changes without a diagnosis (run [analyse/SKILL.md](../analyse/SKILL.md) first)
- Large-scale redesigns that change architecture (use the [`rubyist` gateway agent](../../agents/rubyist.md) instead)
- Stylistic formatting that RuboCop handles better

## Pattern Selection

Each pattern in `references/refactor-patterns.md` has:

| Field | Description |
|-------|-------------|
| `pattern` | Machine key (e.g., `zeitwerk_mismatch`) — also the YAML report key |
| `severity` | CRITICAL, MAJOR, MINOR |
| `area` | Affected concern (async, config, naming, resilience, etc.) |
| `before` | Code before transformation |
| `after` | Code after transformation |
| `conditions` | Optional pre-conditions (Ruby version, gem availability) |

### Selection Heuristic

Match code smell → pattern name → load the exact transform. Fall back to a custom fix only when no named pattern covers the issue.

1. Read the error or symptom from analyse/sift output
2. Check the pattern name in `references/refactor-patterns.md` table of contents
3. Load the matching pattern
4. Apply the before→after transformation
5. Run `ruby -c` and tests to verify

## Failover

| Dependency | If Unavailable | Fallback |
|------------|---------------|----------|
| `references/refactor-patterns.md` | Pattern file not found | Apply the fix manually based on general Ruby best practices. Note the missing pattern file in the output. |
| [analyse/SKILL.md](../analyse/SKILL.md) | Precursor diagnosis missing | Ask the user or the `rubyist` gateway for the specific issue. If none available, inspect the code for common issues (Zeitwerk, rescue, frozen_string_literal). |
| `ruby -c` / tests | Verification tools missing | Provide the transformed code and note that syntax/tests were not verified. |

## Common Pitfalls

1. **Applying a pattern without diagnosis**: A pattern fixes one thing; if you don't know the root cause, you might fix a symptom. Always run [analyse/SKILL.md](../analyse/SKILL.md) first.
2. **Pattern mismatch**: A `zeitwerk_mismatch` fix might look similar to a `hardcoded_config` fix. Verify the exact issue before applying.
3. **Forgetting verification**: Always run `ruby -c` after refactoring. Patterns can introduce syntax errors if the match was inexact.
4. **Over-applying `--max` patterns**: Not every pattern applies to every codebase. Pick the pattern that matches the specific issue.
5. **Ignoring context lines**: The before/after in refactor-patterns.md shows minimal context. Real code may need surrounding structure preserved.

## Verification Checklist

- [ ] Issue identified by analyse or user matches a named pattern
- [ ] Pattern loaded and before/after understood
- [ ] Surgical fix applied (not a blanket transformation)
- [ ] `ruby -c` passes on all modified files
- [ ] Tests pass (if available)
- [ ] Result reported back to the caller (analyse/sift/rubyist gateway)
### Design Pattern References

Named refactorings in this skill resolve to three canonical Ruby patterns. Match the diagnosed issue to the pattern's Problem statement before selecting a transformation.

#### Template Method

**Problem**
We have a complex bit of code, but somewhere in the middle there is a bit that needs to vary.

**Solution**
The general idea of the Template Method pattern is to build an abstract base class with a skeletal method, which drives the bit of processing that needs to vary by making calls to abstract methods, which are then supplied by the concrete subclasses. The abstract base class controls the higher-level processing and the sub-classes simply fill in the details.

**Structural constraints**
- The skeletal method lives on the abstract base class and is the only caller of the varying steps.
- Varying steps are abstract methods on the base class; concrete subclasses supply the details.
- The base class owns higher-level control flow — subclasses never reorder or duplicate it.
- Built around inheritance: each variation costs a subclass. Prefer Strategy when variations combine.

#### Strategy

**Problem**
We need to vary part of an algorithm — something we previously solved using the Template Method pattern — although we want to avoid its drawbacks, introduced by the fact that it's built around inheritance.

**Solution**
To avoid problems introduced by inheritance we should use delegation. Instead of creating subclasses (like in the Template Method pattern), we tear out the varying part of the code and isolate it in its own class and create one of them for each variation. The key idea of the Strategy pattern is to define a family of objects (strategies), which all do (almost) the same thing and support the same interface. Then, the user of the strategy (context) can treat the strategies as interchangeable parts.

**Structural constraints**
- Delegation, not inheritance: the context holds a strategy, it does not subclass one.
- Every strategy in the family supports the same interface and does (almost) the same thing.
- The varying code is torn out into its own class — one class per variation.
- The context must treat strategies as interchangeable; no strategy-specific branching in the context.

#### Decorator

**Problem**
We need to vary the responsibilities of an object, adding some features.

**Solution**
In the **Decorator** pattern we create an object that wraps the real one, and implements the same interface and forwarding method calls. However, before delegating to the real object, it performs the additional feature. Since all decorators implement the same core interface, we can build chains of decorators and assemble a combination of features at runtime.

**Structural constraints**
- The decorator implements the same interface as the object it wraps and forwards method calls.
- The added feature runs *before* delegation to the real object.
- All decorators share the core interface — this is what makes chaining legal.
- Feature combinations are assembled at runtime, not encoded as subclasses.

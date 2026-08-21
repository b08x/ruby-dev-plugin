# Step 2: File the Route in Trackboi (Hard Gate)

## Context
You are the trackboi-filing stage of the `/ruby-development` workflow. This mirrors
Step 2.5 of the `rubyist` gateway agent's protocol. **This is a hard gate, not optional
bookkeeping.** If filing fails, the workflow does not proceed to dispatch.

## Goal
Ensure the dispatch plan produced in Step 1 exists as exactly one trackboi card, in the
right project, filed under a topically matching (or newly created) track — before any
specialist is dispatched.

## Input
- The full dispatch plan from Step 1 (the `ROUTE:` ... `SCOPE-FLAG:` block).
- The target repo's root path.

## Instructions

1. **Target the right project.** Call `get_active_project`. If it is not the trackboi
   project for this repo, call `switch_project` to the correct one. If no trackboi project
   exists yet for this repo, create one (or its board) rather than filing under an
   unrelated active project.

2. **Find or create the track.** Call `list_tracks` and match by topic against the
   `ROUTE` line. Reuse a matching track. Only call `create_track` if nothing fits.

3. **Create one card per ROUTE** — not one per stage. Title it from the `ROUTE:` line;
   put the full plan block in the description; set `trackId` to the track from step 2;
   column = `todo`.

4. **Move the card to `doing`** now, since dispatch is about to begin (the orchestrator
   will do the actual dispatch in Step 3 — but the card should already reflect that
   filing succeeded and work is starting).

## Failure Handling — Hard Gate

If `switch_project` fails, no board exists and creating one fails, or the track/card
calls error:
- **Do not report success.** Do not let the workflow continue to Step 3.
- First, attempt to resolve it yourself: create the missing board, retry the call once.
- If it still fails, stop and report the exact blocker back to the orchestrator so it can
  surface it to the user. Do not guess a workaround that skips filing.

**One narrow exception**: if trackboi's MCP tools are not available in this session at
all (genuinely absent from the tool list — not merely erroring), report that as a
session-capability gap. The orchestrator will then note in the final synthesis that this
run proceeded without trackboi tracking, and Step 3 may proceed.

## Constraints
- Do NOT create more than one card for this route.
- Do NOT file under an unrelated active project to save time.
- Do NOT silently skip filing because it "seems like just bookkeeping" — it isn't.

## Expected Output

On success:
```
TRACKBOI-STATUS: filed
PROJECT: <project name/id used>
TRACK: <track title/id — reused or created>
CARD: <card id/title>
COLUMN: doing
```

On hard-gate failure:
```
TRACKBOI-STATUS: blocked
BLOCKER: <exact error or missing precondition>
ATTEMPTED-FIX: <what you tried>
```

On the tools-absent exception:
```
TRACKBOI-STATUS: unavailable
REASON: trackboi MCP tools not present in this session
```

## Success Criteria
- [ ] Exactly one card exists for this route, or a clear blocker/absence is reported
- [ ] The card is under the correct per-repo project, not a stale active project
- [ ] The track was reused if a topical match existed

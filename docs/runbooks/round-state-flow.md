# Round State Flow

## Goal

Provide one compact reference for how round state, fallback state, and change state move across the main OhMyPm loop.

## Core Rules

- `loop_state.round_result` only uses:
  - `continue_alignment`
  - `need_materials`
  - `need_internal_repair`
  - `ready_for_preflight`
- `fallback_state.fallback_type` only uses:
  - `internal_repair`
  - `need_materials`
  - `reopen_alignment`
- `reopen_alignment` is a fallback action, not a round result
- `round_number` only increments when a new formal alignment round starts

## Main Flow

### 1. Respond

Use when the current request needs the first credible answer.

Typical output:

- a current version plan
- open questions
- rough module estimate
- optional alignment prototype suggestion

Typical state write:

- `RoundResult=continue_alignment`
- `FallbackType` empty

Reference:

- `docs/examples/respond-status.sample.json`

### 2. Align

Use when new feedback, screenshots, or clarifications arrive.

Typical output:

- updated change points
- updated module list
- updated estimate and schedule impact
- updated round history summary

Possible state write:

- keep aligning:
  - `RoundResult=continue_alignment`
- wait for materials:
  - `RoundResult=need_materials`
  - `FallbackType=need_materials`
- do internal repair:
  - `RoundResult=need_internal_repair`
  - `FallbackType=internal_repair`
- ready for preflight:
  - `RoundResult=ready_for_preflight`
  - `FallbackType` empty

Reference:

- `docs/examples/align-status.sample.json`
- `docs/examples/fallback-status.sample.json`

### 3. Preflight

Use only when the current round is stable enough for formal delivery check.

Entry rule:

- `RoundResult` must already be `ready_for_preflight`

If preflight passes:

- move to formal delivery

If preflight fails:

- choose one fallback:
  - `internal_repair`
  - `need_materials`
  - `reopen_alignment`

Important:

- do not rewrite `RoundResult` to `reopen_alignment`
- if fallback is `reopen_alignment`, the next formal alignment start creates the next `RoundNumber`

Reference:

- `docs/examples/preflight-status.sample.json`
- `docs/examples/reopen-alignment.sample.json`

### 4. Change Control

Use after formal delivery when new scope enters.

Classify first:

- `minor_patch`
- `within_module`
- `new_module`
- `structural_change`

Decision rule:

- `new_module` and `structural_change` require PM confirmation
- if structure is overturned, prefer `reopen_alignment` instead of silent merge

Reference:

- `docs/examples/change-status.sample.json`

## Quick Checks

### Can I increase the round number?

Only if a new formal alignment round is starting.

### Can I use `reopen_alignment` as round result?

No. It only belongs to `fallback_state.fallback_type`.

### When should I update `loop_state.history_summary`?

Update it when:

- 2-3 formal rounds have accumulated
- a structural change happened
- preflight is about to start
- a later session needs quick takeover

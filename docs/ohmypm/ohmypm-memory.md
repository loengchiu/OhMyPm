# Project Memory

## 1. Project Overview
- Project Name: Oh My PM
- Current Demand Task: Use the approval-path expansion only as a mechanism-validation sample to verify the minimum OhMyPm chain.
- Current Mode: alignment_loop
- Current Version: v0.6

## 1.1 Collaboration Boundary
- The current approval-path expansion chain is a sample for mechanism validation, not a real project collaboration thread.
- The current sample exists to verify routing, gates, preflight, delivery split, review, and state writeback.
- PM is not expected to answer virtual sample business questions such as thresholds, risk conditions, or reviewer-role mapping.
- If a later thread turns into real project collaboration, that real demand must be reopened under its own context instead of inheriting sample assumptions as real facts.

## 2. Confirmed Facts
- The current approval-path expansion is a sample scenario used to validate mechanism behavior.
- A real HTML prototype body and a real PRD V1 already exist as the current sample delivery pair.
- The current sample pair has passed preflight and has now received a `pass` review result.
- The current blocker is not a real-project business gap to be answered by PM.
- The earlier virtual business gaps have already been converted into explicit placeholders and mechanism-validation-only notes.

## 3. Unconfirmed Facts
- None

## 4. Open Questions
- None

## 5. Why Still Unclear
- The sample boundary is now clear.
- There is no longer a blocking unclear item inside the current sample chain.

## 6. Current Version Plan
- Keep the current approval-path expansion only as a sample validation story.
- Keep the current HTML prototype and PRD V1 as the present sample baseline.
- The current sample now uses explicit placeholders for thresholds, risk tags, and reviewer-role mapping.
- Do not ask PM to provide virtual business answers for this sample chain.

## 7. This Round Changes
- Explicitly separated mechanism-validation sample work from real project collaboration.
- Marked the current approval-path expansion chain as a sample validation path rather than a real demand thread.
- Replaced the previously open virtual business gaps with explicit sample placeholders in the current prototype and PRD.
- Produced a real HTML prototype body.
- Produced a real PRD V1.
- Passed preflight with the current prototype and PRD pair.
- Produced the first real review record at `docs/ohmypm/cache/review-v1.json`.

## 8. Current Recommendation
- Use the current sample chain as the baseline for later mechanism replay, or open a separate real-project context if collaboration should move beyond sample validation.

## 9. Current Module List
- Approval capability
  - Existing approval flow
  - Approval-path expansion
- Notification module

## 10. Current Estimate
- The current estimate should be explained as added work inside the existing approval capability rather than as workload from a newly created module.
- The extra work mainly comes from additional approval branches, rule clarification, edge-case handling, and linked verification impact.

## 11. Schedule Impact
- The current schedule impact should be explained as a consequence of higher complexity inside the existing approval capability, not as a consequence of adding a new standalone module.
- A stable outward-facing schedule statement still needs one internal consolidation round.

## 11.1 Interface Boundary Progress
- A first human-readable boundary note has been drafted for approval-path definition, status sync, notification linkage, trace records, and exception fallback handling.
- The current boundary note still serves as a product-side clarification layer before later formal delivery details are written.

## 11.2 Acceptance Coverage Progress
- A first acceptance note has been drafted for main flow, branch flow, exception flow, linkage impact, and compatibility coverage.
- The current acceptance note clarifies that both "new path works" and "old path is not broken" must be covered together.

## 12. System Memory References
- None

## 13. New Material Records
- Added `docs/current-response-note.md`
- Added `docs/interface-boundary-note.md`
- Added `docs/acceptance-coverage-note.md`
- Added `docs/stable-alignment-package.md`
- Added `docs/delivery-inheritance-note.md`
- Added `docs/preflight-handoff-checklist.md`
- Added `docs/formal-interface-spec.md`
- Added `docs/formal-acceptance-spec.md`
- Added `docs/prototype-handoff-note.md`
- Added `docs/prototype-v1-draft.md`
- Added `docs/prototype-v1-structure.md`
- Added `docs/ohmypm/deliverables/prototype-v1/index.html`
- Added `docs/ohmypm/deliverables/prd-v1/PRD-v1.md`

## 14. Review Summary
- Review concluded as `pass`
- Fact issues: none
- Risk issues: none that block the current sample chain
- Must fix: none
- Suggestions remain non-blocking: later add a clearer implementation checklist for fields/actions/states and more detailed notification exception cases for testing.

## 15. Overwrite Records
- None

## 16. Delivery Inheritance Progress
- A dedicated inheritance note now defines how prototype, PRD, and review materials should inherit the stable alignment package.
- The current intent is to prevent downstream materials from reinterpreting scope or module ownership on their own.

## 17. Preflight Handoff Progress
- A dedicated preflight handoff checklist now maps the stable alignment package into the six preflight checks.
- The current checklist says module closure is already stable, but downstream prototype/PRD carry-through still blocks formal delivery.

## 18. Formalization Progress
- A formal interface carry-through draft is now available for later PRD use.
- A formal acceptance carry-through draft is now available for later PRD use.
- The remaining gap is no longer missing formal wording itself, but that downstream prototype and PRD artifacts have not yet been produced from these drafts.

## 19. Prototype Handoff Progress
- A first delivery-prototype handoff note is now available.
- The current prototype handoff defines what the prototype should show, how it should inherit the aligned conclusions, and what must stay in PRD instead of prototype.

## 20. Prototype Draft Progress
- A first prototype draft is now available.
- The current draft defines the minimum page coverage and flow coverage for the approval-path expansion.
- The minimum page coverage is: entry/list, detail/handling, flow history, and notification touchpoints.
- The minimum flow coverage is: main flow, key branch flow, exception flow, and linkage flow.

## 21. Prototype Structure Progress
- A first prototype structure file is now available.
- The current structure connects page layout, numbered annotations, and flow relationships into one review-oriented outline.

## 22. Prototype Body Progress
- A real HTML prototype body is now available.
- The current prototype body already covers four pages and the minimum main, branch, exception, and linkage flows for the approval-path expansion.

## 23. PRD Skeleton Progress
- A first real PRD skeleton is now available.
- The current skeleton already covers document info, background, scope, overall approach, page explanation, business rules, exceptions and boundaries, roles and data impact, and acceptance and delivery notes.
- The current PRD now also includes the minimum interface agreement, linkage rules, role-action matrix, exception rules, and executable acceptance checks needed for preflight.
- The current PRD now uses explicit sample placeholders for amount threshold, risk tag, and reviewer-role mapping instead of leaving them as PM-facing open questions.

## 24. Review Record Progress
- A first real review record is now available at `docs/ohmypm/cache/review-v1.json`.
- The current review conclusion is `pass`.
- The current sample chain no longer carries a review-stage hard blocker.


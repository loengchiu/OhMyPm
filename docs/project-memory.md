# Project Memory

## 1. Project Overview
- Project Name: Oh My PM
- Current Demand Task: Clarify how the approval-path expansion should be absorbed into the current version plan and explain its impact on module split, estimate, and schedule.
- Current Mode: alignment_loop
- Current Version: v0.6

## 2. Confirmed Facts
- The approval-path expansion is still inside the current version scope.
- The newly added content should be treated as an in-module supplement inside the existing approval capability, not as a separate module.
- The current review state is still `conditional_pass`.
- Formal delivery cannot continue yet because the module split and estimate explanation are not stable enough.

## 3. Unconfirmed Facts
- None

## 4. Open Questions
- None

## 5. Why Still Unclear
- The scope boundary is now clear, and the module classification is now also clear.
- What is still unclear is how to explain the updated module split, estimate, and schedule impact in one stable narrative that can be reused in the next alignment step.

## 6. Current Version Plan
- Keep the approval-path expansion inside the current version.
- Treat the newly added approval-path content as an in-module supplement inside the existing approval capability.
- Rework the module split, estimate explanation, and schedule-impact wording before attempting a heavier stage.
- A merged stable alignment package is now available to carry the response note, interface boundary note, and acceptance coverage note under one reusable narrative.

## 7. This Round Changes
- Confirmed that the approval-path expansion is still inside the current version scope.
- Corrected the earlier module classification and confirmed that the newly added content should be treated as an in-module supplement rather than a separate module.
- Cleared the PM confirmation blocker on scope boundary.
- Cleared the PM confirmation blocker on change classification.

## 8. Current Recommendation
- Continue refining the module split, estimate explanation, and schedule-impact wording into one stable alignment note before the next alignment step.

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
- Added `deliverables/prototype-v1/index.html`
- Added `deliverables/prd-v1/PRD-v1.md`

## 14. Review Summary
- Review concluded as `conditional_pass`
- Must fix: Missing API contract
- Must fix: Acceptance coverage is incomplete
- Current repair focus has been split into three concrete gaps: module split and estimate wording, interface boundary clarification, and acceptance coverage completion.
- The second and third gaps now both have first-round human-readable repair notes.
- The current repair outputs have now been merged into one stable alignment package for reuse in later steps.

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

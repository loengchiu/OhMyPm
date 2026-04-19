# Ask Back Runbook

## Goal

Turn ask-back from a written rule into a runtime action:

1. detect a PM decision blocker
2. stop heavier stage progression
3. generate the minimal PM question
4. apply the PM answer back into status

## Runtime Checks

The following runtime points must stop and route to ask-back when needed:

- `scripts/stage-gate.ps1`
- `omp-respond`
- `omp-preflight`
- `omp-change`

## Trigger Cases

At minimum, ask-back must trigger when:

- response is blocked by a key fact gap
- preflight is blocked while `pending_confirmations` is still non-empty
- `change_state.change_category_confirmed_by_pm=false`
- scope boundary is still unconfirmed and already affects module list, estimate, or schedule

## Step 1. Generate the minimal question

```powershell
powershell -File .\scripts\ask-back-plan.ps1
```

Expected result:

- `ask_back_required=true`
- one or more trigger records
- a minimal PM question for each trigger

## Step 2. Ask PM the smallest blocking question

Use the top trigger first.

Example from the current sample status:

- Please confirm the scope boundary for the current version: is the approval-path expansion still inside the current version, or should it be treated as a separate scope/module?
- Please confirm whether this newly added content is already large enough that it should be treated as a separate new module, rather than still being handled as an in-module supplement.

Important:

- do not merge scope-boundary judgment and module-classification judgment into one question
- ask scope first
- ask module classification second

## Step 3. Apply the PM answer

```powershell
powershell -File .\scripts\ask-back-apply.ps1 `
  -AnsweredConfirmation 'Need confirmation on scope boundary' `
  -ChangeCategoryConfirmedByPm $true `
  -NextRecommended 'Return to the blocked stage and rerun the gate'
```

Expected result:

- matching `pending_confirmations` entry is removed
- PM confirmation state is updated
- the blocked stage can be retried through `stage-gate.ps1`

# Demo Flow

## Goal

Run a minimal OhMyPm demo chain from first response to alignment, then branch into:

- formal delivery preparation
- reopen alignment after preflight failure
- confirmed post-delivery change handling

This runbook is for demonstration and smoke-check use. It shows which sample payloads can be applied in sequence without redefining the architecture each time.

For a one-command replay, use:

```powershell
powershell -File .\scripts\demo-smoke.ps1
```

## Preparation

Make sure the project is initialized:

```powershell
powershell -File .\scripts\init-project.ps1
```

Recommended backup before replay:

```powershell
Copy-Item .\docs\project-status.json .\docs\cache\project-status.demo.backup.json -Force
Copy-Item .\docs\project-memory.md .\docs\cache\project-memory.demo.backup.md -Force
```

## Path A: Respond -> Align -> Preflight Pass

### 1. First response

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\respond-status.sample.json
powershell -File .\scripts\memory-apply.ps1 -PayloadPath .\docs\examples\respond-memory.sample.json
```

Expected state:

- `RoundNumber=1`
- `RoundResult=continue_alignment`

### 2. Alignment after feedback

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\align-status.sample.json
powershell -File .\scripts\memory-apply.ps1 -PayloadPath .\docs\examples\align-memory.sample.json
```

Expected state:

- `RoundNumber=2`
- `RoundResult=ready_for_preflight`

### 3. Preflight pass

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\preflight-status.sample.json
powershell -File .\scripts\memory-apply.ps1 -PayloadPath .\docs\examples\preflight-memory.sample.json
```

Expected state:

- current plan is ready for formal delivery
- next step can be `omp-deliver-prototype`

## Path B: Preflight Fail -> Reopen Alignment

Use this branch when the stakeholder overturns the structure during or after preflight.

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\reopen-alignment.sample.json
```

Expected state:

- `RoundResult=need_internal_repair`
- `FallbackType=reopen_alignment`

Important:

- `reopen_alignment` stays in fallback state
- the next formal alignment start is what creates the next round number

## Path C: Post-Delivery Change Control

### 1. Unconfirmed classification example

This file is intentionally not for direct happy-path replay. It demonstrates the state before PM confirmation:

- `docs/examples/change-status.sample.json`

### 2. Confirmed classification example

Use this for a runnable change-control demo:

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\change-status-confirmed.sample.json
```

Expected state:

- `ChangeCategory=new_module`
- `ChangeCategoryConfirmedByPm=true`
- next action points back to alignment instead of silent merge

## Restore

If you created backups, restore them after the demo:

```powershell
Copy-Item .\docs\cache\project-status.demo.backup.json .\docs\project-status.json -Force
Copy-Item .\docs\cache\project-memory.demo.backup.md .\docs\project-memory.md -Force
```

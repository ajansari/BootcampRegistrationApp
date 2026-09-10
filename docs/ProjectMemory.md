# Project Memory — Bootcamp Registration Tracking (BC PTE)

> Short anchor only. The *why* of each decision lives in `ChangeLog.md`; this file says
> *where to look* and *what is owed*.

## Current position

- **Phase:** BUILD
- **Step:** 06 — Code Generation
- **Status:** **Batches 1–3 complete — compile 0 errors / 0 warnings** (13 files). B1 Foundation (60800/01/02/03 + 60890/91). B2 Core tables + Mgt codeunit (60810/60820/60813). B3 In-client pages: 60811 `ocpfBootcampList`, 60812 `ocpfBootcampCard`, 60821 `ocpfAttendeeList`, 60822 `ocpfAttendeeSubform`; LookupPageId/DrillDownPageId added to both tables. Deviations logged BUILD-02..05. Compile route: `alc.dll` from terminal against VS Code's pre-provisioned .NET 10 runtime (nothing installed). Next: Batch 4 (2 API pages).

## Live documents

| Document | Path | State |
|---|---|---|
| Problem Statement | `docs/ProblemStatement.md` | Draft, awaiting sign-off |
| ChangeLog | `docs/ChangeLog.md` | Started |
| Project Memory | `docs/ProjectMemory.md` | This file |
| Gap Analysis (PRE-02) | `docs/GapAnalysis-PRE02.md` | Signed off |
| Project Parameters | `docs/ProjectParameters.md` | Confirmed by AJ |
| FRD | `docs/FRD.md` | Signed off (updated in place: D-8/F-3 per ChangeLog DESIGN-02) |
| TDD | `docs/TDD.md` | Signed off; updated for Sanity S-1 & S-7 |
| Object Register | `docs/ObjectRegister.md` | 17 objects planned (60800–60891); batch column revised per S-7 |
| Sanity Check | `docs/SanityCheck.md` | Signed off |
| Build Plan | `docs/BuildPlan.md` | Draft — batch order + pre-flight ready; compile route TBD |
| Scaffold | `app.json`, `src/*`, `.gitignore`, git repo | Done — baseline commit 7e71b33 on branch `build/bootcamp-registration` |
| Requirements (pre-BUILD source) | `requirements/bootcamp-registration-extension-requirements.md` | Given input, frozen |

## Open decisions

| # | Decision | Awaiting |
|---|---|---|
| — | none open | — |

## Milestone log

- 2026-09-10 — Project kicked off from `requirements/bootcamp-registration-extension-requirements.md`. Four clarifying decisions taken (see `ChangeLog.md` Issue DEFINE-01).
- 2026-09-10 — PRE-01 signed off by AJ.
- 2026-09-10 — PRE-02 gap analysis signed off: no ledger/posted/tax tables (descriptive payment only); No. Series (T308) + Customer (T18) added as references; Location/Topic stay free text; 5 items deferred with reasoning.
- 2026-09-10 — Step 01 intake: identity = Bootcamp Registration Tracking / OnlyCopilotFans / SaaS PTE / ns OCPF.BootcampRegistration / loc NA / prefix ocpf; ID range 60800–60899; permission sets = Yes. See `ChangeLog.md` Issue DEFINE-02.
- 2026-09-10 — DEFINE complete; params confirmed. FRD drafted (F-1…F-15, D-1…D-15). 8 open questions resolved by AJ — see `ChangeLog.md` Issue DESIGN-01.
- 2026-09-10 — FRD signed off. TDD drafted: 17 objects, IDs 60800–60891, 5 batches. Seats Remaining changed from FlowField to subscriber-maintained stored field (ChangeLog DESIGN-02).
- 2026-09-10 — TDD signed off. Sanity Check run: batch plan restructured (core tables ship in one batch — mutual FlowField/TableRelation reference, ChangeLog DESIGN-04); `addlast(sections)` fixed; Customer-delete dangling link accepted.
- 2026-09-10 — Sanity signed off. Step 05: scaffold + git baseline (7e71b33). Compile route = Option A. Step 06: Batch 1 (Foundation) generated, pre-flight clean, handed to AJ for compile.
- 2026-09-10 — Pre-release version scheme: `app.json` `version` set to `0.0.1.0`; increment through the test cycle, roll to `1.0.0.0` at go-live (ChangeLog BUILD-01).
- 2026-09-10 — Batch 1 (Foundation) compiles 0/0. PTE0004 fixed by moving permission sets to Batch 1, scoped to tables built so far and grown per batch (ChangeLog BUILD-02); 4 Foundation files renamed to `ocpf*` (AA0215). Terminal compile via VS Code's provisioned .NET runtime. Commit `ea341d2`.
- 2026-09-10 — Batch 2 (core tables + Mgt codeunit) compiles 0/0. AJ approved 2 TDD deviations (BUILD-04): LookupPageId/DrillDownPageId deferred to Batch 3; `Max Seats <= 0` = no overbooking cap. Lint fixes: AA0244 (shared `Bootcamp` var → locals), AA0240 (email label wording). Commit `6c970e5`.
- 2026-09-10 — Batch 3 (in-client pages) compiles 0/0 (BUILD-05). 4 pages + LookupPageId/DrillDownPageId added to both tables. Card gets `UsageCategory = None` (silences info AW0006).

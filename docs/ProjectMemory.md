# Project Memory — Bootcamp Registration Tracking (BC PTE)

> Short anchor only. The *why* of each decision lives in `ChangeLog.md`; this file says
> *where to look* and *what is owed*.

## Current position

- **Phase:** DESIGN
- **Step:** 04 — Sanity Check & Validation
- **Status:** TDD signed off. `SanityCheck.md` drafted; 1 blocking issue (S-7 batch order) found and fixed in TDD. Awaiting Technical Lead sign-off. Next: BUILD Step 05 (Plan the Code).

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
| Sanity Check | `docs/SanityCheck.md` | Draft, awaiting Technical Lead sign-off |
| Requirements (pre-BUILD source) | `requirements/bootcamp-registration-extension-requirements.md` | Given input, frozen |

## Open decisions

| # | Decision | Awaiting |
|---|---|---|
| 1 | Technical Lead sign-off on `docs/SanityCheck.md` (Step 04 exit gate) | awaiting: AJ |

## Milestone log

- 2026-09-10 — Project kicked off from `requirements/bootcamp-registration-extension-requirements.md`. Four clarifying decisions taken (see `ChangeLog.md` Issue DEFINE-01).
- 2026-09-10 — PRE-01 signed off by AJ.
- 2026-09-10 — PRE-02 gap analysis signed off: no ledger/posted/tax tables (descriptive payment only); No. Series (T308) + Customer (T18) added as references; Location/Topic stay free text; 5 items deferred with reasoning.
- 2026-09-10 — Step 01 intake: identity = Bootcamp Registration Tracking / OnlyCopilotFans / SaaS PTE / ns OCPF.BootcampRegistration / loc NA / prefix ocpf; ID range 60800–60899; permission sets = Yes. See `ChangeLog.md` Issue DEFINE-02.
- 2026-09-10 — DEFINE complete; params confirmed. FRD drafted (F-1…F-15, D-1…D-15). 8 open questions resolved by AJ — see `ChangeLog.md` Issue DESIGN-01.
- 2026-09-10 — FRD signed off. TDD drafted: 17 objects, IDs 60800–60891, 5 batches. Seats Remaining changed from FlowField to subscriber-maintained stored field (ChangeLog DESIGN-02).
- 2026-09-10 — TDD signed off. Sanity Check run: batch plan restructured (core tables ship in one batch — mutual FlowField/TableRelation reference, ChangeLog DESIGN-04); `addlast(sections)` fixed; Customer-delete dangling link accepted.

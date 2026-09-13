# Project Parameters — Bootcamp Registration Tracking (BC PTE)

**Phase:** DEFINE · **Step:** 01 — Populate the Intake Sheet · **Status:** Confirmed by AJ Ansari, 2026-09-10 (§1.6/§1.8 backfilled 2026-09-13, Step 08 — see below)
**Date:** 2026-09-10 · **Collected from:** AJ Ansari, 2026-09-10

> Authoritative source for every name, ID, version, and quoting decision for the rest of the
> routine. Never hardcode these in AL — derive everything from this block (Operating Rule 1).

---

## 1.1 Extension Identity

| Parameter | Value |
|---|---|
| **Extension Name** | `Bootcamp Registration Tracking` |
| **Publisher** | `OnlyCopilotFans` |
| **Deployment Target** | `SaaS PTE` |
| **Use Namespace (y/n)** | `Yes` |
| **Namespace** | `OCPF.BootcampRegistration` |
| **Localization** | `NA` (North American market). No tax-framework or country-specific fields are in scope (see `GapAnalysis-PRE02.md` §8.6), so this value has no field-inclusion impact for this build. |

## 1.2 Object ID Allocation

| Block | From | To | Size | Notes |
|---|---|---|---|---|
| **Primary allocation** | 60800 | 60899 | 100 IDs | The entire allocation. Confirmed by AJ 2026-09-10. |

- No additional allocations.
- **Permission Sets required?** `Yes` — ≥ 2 IDs reserved inside the primary range (planned:
  60890 `OCPF - Bootcamp Read`, 60891 `OCPF - Bootcamp Edit`).
- **Rule:** never use object IDs outside 60800–60899. `app.json` `idRanges` was rewritten from
  the placeholder `50100–50149` to `60800–60899` in Step 05, as planned here — done, not a
  standing action item (corrected at Step 08, `GapAnalysis.md` G-17: this note read as still
  outstanding).

## 1.3 Naming & API Parameters

| Parameter | Value |
|---|---|
| **AL Object Prefix** | `ocpf` |
| **APIPublisher** | `'onlyCopilotFans'` |
| **APIGroup Prefix** | `ocpf_` (as-planned; **not** what shipped — see note below) |
| **APIVersion** | `'v1.0'` |
| **Namespace** | `OCPF.BootcampRegistration` (matches 1.1) |
| **Permission Set Prefix** | `OCPF - ` |

**Corrected at Step 08 (`GapAnalysis.md` G-17):** `APIPublisher` and `APIGroup` above are the
**shipped** values, not this section's original plan. AJ decided (ChangeLog BUILD-06) to follow
CodeCop AA0101 over the Standards §1.3 literal pattern: `APIPublisher` is fully camelCased
(`'onlyCopilotFans'`, not `'OnlyCopilotFans'`) and `APIGroup` drops the `<prefix>_` separator
entirely (`'ocpfBootcampRegistration'`, not `'ocpf_bootcampRegistration'`). This is a
**per-project divergence, not a Standards amendment** — a future project should re-decide, not
assume this precedent. TDD §1/§9.1 and `ObjectRegister.md` already reflect the shipped values;
this authoritative sheet did not, until now.

### Entity-naming patterns (derived from prefix `ocpf`)

| Element | Value | Length check |
|---|---|---|
| `APIGroup` (as shipped, BUILD-06) | `'ocpfBootcampRegistration'` | 25 — ok |
| Bootcamp `EntityName` / `EntitySetName` | `ocpfBootcamp` / `ocpfBootcamps` | 12 / 13 — ok (≤30) |
| Attendee `EntityName` / `EntitySetName` | `ocpfAttendee` / `ocpfAttendees` | 12 / 13 — ok (≤30) |
| `ODataKeyFields` | `SystemId` | on every API page |

- Bootcamp Registration Setup and the Assisted Setup Wizard are **not** exposed via API — no
  entity names needed.
- Singleton rule (if any singleton API page were added later): `EntityName = EntitySetName`.

## 1.4 Platform & Runtime

| Parameter | Value |
|---|---|
| **AL Runtime** | `17.0` |
| **BC Application Minimum** | `28.0.0.0` |
| **Recommended BC Version** | `28.4+` |
| **Symbol Source** | BC v28.4 symbol files — Base Application `28.4.53241.54183`, Business Foundation `28.4.53241.53312`, System Application `28.4.53241.54101`, Application `28.4.53241.53312`, System `28.0.53984.0` |

## 1.5 Feature Flags (fixed)

| Flag | Status |
|---|---|
| `NoImplicitWith` | **Enabled (enforced)** — already present in `app.json` `"features"`. Every field source prefixed with `Rec.`. |

## 1.6 Onboarding & Discoverability

> Never formally asked at intake (2026-09-10) — this section didn't exist in the runbook yet.
> Backfilled at Step 08 (`GapAnalysis.md` G-17) from decisions already made de facto elsewhere,
> so this sheet stops being silent on a §1.6 the current runbook requires.

| Parameter | Value | Answered by |
|---|---|---|
| **Assisted Setup Wizard** | `Yes` — configures the Bootcamp/Attendee No. Series and can optionally create 2 sample bootcamps. | F-13 (original FRD scope) |
| **Activity Cues** | `Yes` — 5 cues (Active Bootcamps, Unpaid Registrations, Below Min Seats, Registrations This Month, Bootcamp Revenue This Month). | ChangeLog BUILD-09 (gap-fill, AJ's explicit request 2026-09-12) |
| **Departments / My Business Central placement** | `No` — never asked, never requested. Discoverability instead comes from the Business Manager Role Center entry (F-14) and, since Step 08 (G-03), `UsageCategory = Administration` on the Setup card for Tell Me. | Backfilled 2026-09-13, Step 08 |

## 1.7 Model & Effort Assignment

> Added 2026-09-12 — this parameter didn't exist in the runbook at Step 01 sign-off (2026-09-10);
> collected once the runbook gained §1.7. Does not reopen the Step 01 exit gate, which already
> passed under the rules in force at the time.

Configured: **Yes** — three-role division of labor (AJ Ansari, 2026-09-12).

| Role | Model | Scope |
|---|---|---|
| **Main** | Sonnet | All BUILD code generation, all actual code edits (including applying what the other two roles report), end-to-end ownership of the continuity documents (ChangeLog, Object Register, ProjectMemory, TestingFeedback triage). |
| **Light** | Haiku | Per-batch pre-flight linting only. Reports findings; never edits code. |
| **Reasoning** | Opus | Code Review (Step 10), FRD/TDD authorship (Steps 02/03 — moot for this project, already complete), root-cause troubleshooting/diagnosis (Step 07, and PROVE-phase testing-feedback triage). Reports findings/drafts/diagnoses; never edits code or the continuity documents itself. |

Mechanism: delegation via the executing agent's own subagent-spawning capability (this
harness's `Agent` tool), which supports exactly these three models plus Fable — no other model
provider is reachable from this environment. Applies going forward from 2026-09-12; steps
already completed (Steps 01–06, most of testing-feedback triage) were done single-model and are
not retroactively redone.

## 1.8 Framework File Tracking (`.gitignore`)

> Also never formally asked at Step 01 — backfilled from the decision actually made and executed
> mid-project (2026-09-12, ChangeLog "Repository Hygiene" entry in `RunbookChangelog.md`).
> Backfilled into this sheet at Step 08, `GapAnalysis.md` G-17.

| Parameter | Value |
|---|---|
| **Framework files in `.gitignore`?** | `Yes` (default) — `CLAUDE.md`, `RunbookChangelog.md`, `RunbookSchematics.md`, and the framework outline doc are excluded from this project's git tracking. Confirmed by AJ, 2026-09-12. |

---

## Quoting reference (applies to every AL and config file)

| Context | Quote style | Example |
|---|---|---|
| `app.json` / `launch.json` values | JSON strings | `"publisher": "OnlyCopilotFans"` |
| AL string property values | Single quotes | `APIPublisher = 'OnlyCopilotFans';` |
| AL object names | Double quotes | `page 60810 "ocpfBootcamps"` |
| BC source field names with spaces | Double quotes on the field name | `Rec."No. Series"` |

---

## Exit-gate checklist (Step 01)

- [x] No placeholder remains.
- [x] Deployment Target is one allowed value (`SaaS PTE`).
- [x] Namespace matches between 1.1 and 1.3 (`OCPF.BootcampRegistration`).
- [x] Localization is set (`NA`).
- [x] Permission Sets required = `Yes` → ≥ 2 IDs reserved in the primary range (60890–60891).
- [x] §1.6 answered (backfilled 2026-09-13, Step 08 — see §1.6 above).
- [x] §1.7 answered (2026-09-12 — see §1.7 above).
- [x] §1.8 answered (backfilled 2026-09-13, Step 08 — see §1.8 above).
- [x] **Human confirms the sheet.** Confirmed by AJ Ansari, 2026-09-10 (checkbox corrected at
  Step 08, `GapAnalysis.md` G-17 — `ProjectMemory.md` already recorded this as confirmed; this
  sheet's own checklist did not).

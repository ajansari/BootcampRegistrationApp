# Object Register — Bootcamp Registration Tracking (BC PTE)

Standalone artifact. Every object, its ID, module, source table, and R/W status. Updated as
objects are planned (Step 03) and built (Step 06).

## Allocated ID ranges (from `ProjectParameters.md` §1.2)

| Block | From | To | Size |
|---|---|---|---|
| Primary | 60800 | 60899 | 100 |

## Module sub-blocks (from `TDD.md` §2)

| Module | Sub-block | Tail block for cross-module additions |
|---|---|---|
| M1 Foundation | 60800–60809 | 60860–60889 (shared) |
| M2 Bootcamp | 60810–60819 | " |
| M3 Attendee | 60820–60829 | " |
| M4 API | 60830–60839 | " |
| M5 Wizard & Navigation | 60840–60859 | " |
| Permission sets | 60890–60899 | — |

## Objects (planned — status set to `built` in Step 06)

| ID | Type | Name | Module | Source table (name / no.) | R/W | Batch | Status |
|---|---|---|---|---|---|---|---|
| 60800 | enum | `ocpfBootcampStatus` | M1 | — | — | 1 | **built** |
| 60801 | table | `ocpfBootcampRegSetup` | M1 | new | RW (in-client) | 1 | **built** |
| 60802 | page (Card) | `ocpfBootcampRegSetup` | M1 | `ocpfBootcampRegSetup` / 60801 | RW | 1 | **built** |
| 60803 | codeunit (Install) | `ocpfBootcampRegInstall` | M1 | — | — | 1 / 5 | **built (Batch 1 part: EnsureSetup only)** |
| 60810 | table | `ocpfBootcamp` | M2 | new | RW | 2 | **built** (LookupPageId/DrillDownPageId added Batch 3) |
| 60811 | page (List) | `ocpfBootcampList` | M2 | `ocpfBootcamp` / 60810 | RW | 3 | **built** |
| 60812 | page (Card) | `ocpfBootcampCard` | M2 | `ocpfBootcamp` / 60810 | RW | 3 | **built** |
| 60813 | codeunit | `ocpfBootcampRegMgt` | M2 | — | — | 2 | **built** |
| 60820 | table | `ocpfAttendee` | M3 | new | RW | 2 | **built** (LookupPageId/DrillDownPageId added Batch 3) |
| 60821 | page (List) | `ocpfAttendeeList` | M3 | `ocpfAttendee` / 60820 | RW | 3 | **built** |
| 60822 | page (ListPart) | `ocpfAttendeeSubform` | M3 | `ocpfAttendee` / 60820 | RW | 3 | **built** |
| 60830 | page (API) | `ocpfBootcamps` | M4 | `ocpfBootcamp` / 60810 | RW | 4 | **built** |
| 60831 | page (API) | `ocpfAttendees` | M4 | `ocpfAttendee` / 60820 | RW | 4 | **built** |
| 60840 | page (NavigatePage) | `ocpfBootcampRegSetupWizard` | M5 | `ocpfBootcampRegSetup` / 60801 | RW | 5 | **built** |
| 60841 | pageextension | `ocpfBusinessMgrRCExt` | M5 | extends page 9022 "Business Manager Role Center" | — | 5 | **built** |
| 60842 | tableextension | `ocpfActivitiesCueExt` | M5 | extends table 1313 "Activities Cue" | — | Gap-fill | **built** |
| 60843 | codeunit | `ocpfActivityCueMgt` | M5 | — | — | Gap-fill | **built** |
| 60844 | pageextension | `ocpfO365ActivitiesExt` | M5 | extends page 1310 "O365 Activities" | — | Gap-fill | **built** |
| 60890 | permissionset | `OCPF - Bootcamp Read` | perms | — | R | **1** (grown per batch) | **built (setup table only)** |
| 60891 | permissionset | `OCPF - Bootcamp Edit` | perms | — | RIMD | **1** (grown per batch) | **built (setup table only)** |

**20 objects built (17 planned + 3 gap-fill Activity Cues, ChangeLog BUILD-09). All batches
compile 0 errors / 0 warnings.** Free IDs in M5: 60845–60859. Free IDs overall: 60804–60809,
60814–60819, 60823–60829, 60832–60839, 60845–60889, 60892–60899.

**Activity Cue fields (on tableextension 60842, field IDs 60800–60804 — a separate ID space
scoped to table 1313, chosen to match this project's numeric identity, not colliding with 1313's
own fields which top out at 110):**

| Field ID | Name | Type | Pattern |
|---|---|---|---|
| 60800 | `OCPF Active Bootcamps` | Integer | FlowField — `count("ocpfBootcamp" where(Status = const(Active)))` |
| 60801 | `OCPF Unpaid Registrations` | Integer | FlowField — `count("ocpfAttendee" where(Paid = const(false)))` |
| 60802 | `OCPF Below Min Seats` | Integer | Plain, computed by `ocpfActivityCueMgt.UpdateCues` (field-to-field comparison, not FlowField-expressible) |
| 60803 | `OCPF Registrations This Month` | Integer | Plain, computed by `ocpfActivityCueMgt.UpdateCues` (proxy: `SystemCreatedAt` in the current calendar month — no explicit registration-date field exists) |
| 60804 | `OCPF Revenue This Month` | Decimal | Plain, computed by `ocpfActivityCueMgt.UpdateCues` (sum of `Amount Paid` where `Paid = true` and `Payment Date` in the current month) |

No permission-set change needed: table 1313 "Activities Cue" is a standard table already
readable by every user (it drives their own Role Center); a `tableextension` doesn't introduce a
new table, so PTE0004 does not apply — confirmed by a clean compile with no new `tabledata` grant.

**API identity (as built — diverges from Standards §1.3 literal example; ChangeLog BUILD-06):**
`APIPublisher = 'onlyCopilotFans'`, `APIGroup = 'ocpfBootcampRegistration'`, `APIVersion = 'v1.0'`.

**Permission-set `tabledata` coverage (P-15) — grows as batches add tables:**

| Table | In set 60890 (R) | In set 60891 (IMD) | Added in batch |
|---|---|---|---|
| `ocpfBootcampRegSetup` | ✓ | ✓ | 1 |
| `ocpfBootcamp` | ✓ | ✓ | 2 |
| `ocpfAttendee` | ✓ | ✓ | 2 |

## Standard objects referenced (verified against BC v28.4 symbols, 2026-09-10)

| Object | No. | Namespace | Access |
|---|---|---|---|
| `No. Series` (table) | 308 | `Microsoft.Foundation.NoSeries` | R (TableRelation) |
| `No. Series` (codeunit) | 310 | `Microsoft.Foundation.NoSeries` | execute |
| `No. Series Line` (table) | 309 | `Microsoft.Foundation.NoSeries` | R (indirect) |
| `Customer` (table) | 18 | `Microsoft.Sales.Customer` | R (TableRelation) |
| `Guided Experience` (codeunit) | 1990 | `System.Environment.Configuration` | execute |
| `Assisted Setup Group` (enum) | 1815 | `System.Environment.Configuration` | ref (value `Extensions`) |
| `Video Category` (enum) | 3710 | `System.Media` | ref (value `Uncategorized`) |
| `Business Manager Role Center` (page) | 9022 | `Microsoft.Finance.RoleCenters` | extended (additive) |
| `Activities Cue` (table) | 1313 | `Microsoft.RoleCenters` | extended (additive; new fields only, no new `tabledata` grant) |
| `O365 Activities` (page) | 1310 | *(global — no namespace)* | extended (additive; `addlast(content)`) |

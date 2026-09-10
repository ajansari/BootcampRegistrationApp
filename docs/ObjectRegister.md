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
| 60810 | table | `ocpfBootcamp` | M2 | new | RW | 2 | planned |
| 60811 | page (List) | `ocpfBootcampList` | M2 | `ocpfBootcamp` / 60810 | RW | 3 | planned |
| 60812 | page (Card) | `ocpfBootcampCard` | M2 | `ocpfBootcamp` / 60810 | RW | 3 | planned |
| 60813 | codeunit | `ocpfBootcampRegMgt` | M2 | — | — | 2 | planned |
| 60820 | table | `ocpfAttendee` | M3 | new | RW | 2 | planned |
| 60821 | page (List) | `ocpfAttendeeList` | M3 | `ocpfAttendee` / 60820 | RW | 3 | planned |
| 60822 | page (ListPart) | `ocpfAttendeeSubform` | M3 | `ocpfAttendee` / 60820 | RW | 3 | planned |
| 60830 | page (API) | `ocpfBootcamps` | M4 | `ocpfBootcamp` / 60810 | RW | 4 | planned |
| 60831 | page (API) | `ocpfAttendees` | M4 | `ocpfAttendee` / 60820 | RW | 4 | planned |
| 60840 | page (NavigatePage) | `ocpfBootcampRegSetupWizard` | M5 | `ocpfBootcampRegSetup` / 60801 | RW | 5 | planned |
| 60841 | pageextension | `ocpfBusinessMgrRCExt` | M5 | extends page 9022 "Business Manager Role Center" | — | 5 | planned |
| 60890 | permissionset | `OCPF - Bootcamp Read` | perms | — | R | **1** (grown per batch) | **built (setup table only)** |
| 60891 | permissionset | `OCPF - Bootcamp Edit` | perms | — | RIMD | **1** (grown per batch) | **built (setup table only)** |

17 objects planned; 6 built (Batch 1). Free IDs: 60804–60809, 60814–60819, 60823–60829,
60832–60839, 60842–60889, 60892–60899.

**Permission-set `tabledata` coverage (P-15) — grows as batches add tables:**

| Table | In set 60890 (R) | In set 60891 (IMD) | Added in batch |
|---|---|---|---|
| `ocpfBootcampRegSetup` | ✓ | ✓ | 1 |
| `ocpfBootcamp` | — | — | 2 |
| `ocpfAttendee` | — | — | 2 |

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

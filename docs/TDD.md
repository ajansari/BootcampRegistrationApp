# Technical Design Document — Bootcamp Registration Tracking (BC PTE)

**Phase:** DESIGN · **Step:** 03 · **Status:** Awaiting Technical Lead sign-off
**Date:** 2026-09-10 · **Author:** Claude (agent), for AJ Ansari

**Inputs:** `docs/FRD.md`, `docs/ProjectParameters.md`, BC v28.4 symbol files
(`.alpackages/`), `docs/GapAnalysis-PRE02.md`.

> **Self-sufficiency claim:** every object in this project can be produced correctly from this
> document alone. All Part 1 values are restated in §1; every standard object is named with its
> verified number and `using` namespace in §5; the exact AL templates are in §9.

---

## 1. System identity (from `ProjectParameters.md` — restated, authoritative here)

| Item | Value |
|---|---|
| Publisher | `OnlyCopilotFans` |
| Extension name | `Bootcamp Registration Tracking` |
| Namespace (every object) | `OCPF.BootcampRegistration` |
| AL object prefix | `ocpf` |
| APIPublisher | `'OnlyCopilotFans'` |
| APIGroup | `'ocpf_bootcampRegistration'` |
| APIVersion | `'v1.0'` |
| Permission Set Prefix | `OCPF - ` |
| Object ID range | 60800–60899 (100), no additional ranges |
| AL runtime | 17.0 |
| BC application minimum | 28.0.0.0 |
| Feature | `NoImplicitWith` (enforced) — every field reference `Rec.`-qualified |
| Deployment target | SaaS PTE |

## 2. Module grouping & ID allocation

Contiguous sub-blocks with ≥ 20% unallocated growth buffer; a cross-module tail block; the
permission-set block sits in the 60890s per `ObjectRegister.md`.

| Module | ID sub-block | Used | Buffer | Contents |
|---|---|---|---|---|
| **M1 Foundation** | 60800–60809 | 4 | 6 (60%) | Status enum, Setup table + page, Install codeunit |
| **M2 Bootcamp** | 60810–60819 | 4 | 6 (60%) | Bootcamp table (60810) + Mgt codeunit (60813) + list (60811) + card (60812) |
| **M3 Attendee** | 60820–60829 | 3 | 7 (70%) | Attendee table (60820) + list (60821) + subform (60822) |
| **M4 API** | 60830–60839 | 2 | 8 (80%) | Bootcamp API page, Attendee API page |
| **M5 Wizard & Navigation** | 60840–60859 | 2 | 18 (90%) | Assisted Setup Wizard page, Business Manager RC pageextension |
| **Cross-module tail** | 60860–60889 | 0 | 30 | Future additions in any module |
| **Permission sets** | 60890–60899 | 2 | 8 | Read set, Edit set |

### 2.1 Object register (planned)

| ID | Type | Name | Module | Source table (name / no.) | R/W | Batch |
|---|---|---|---|---|---|---|
| 60800 | enum | `ocpfBootcampStatus` | M1 | — | — | 1 |
| 60801 | table | `ocpfBootcampRegSetup` | M1 | new | RW (in-client) | 1 |
| 60802 | page (Card) | `ocpfBootcampRegSetup` | M1 | `ocpfBootcampRegSetup` / 60801 | RW | 1 |
| 60803 | codeunit (Install) | `ocpfBootcampRegInstall` | M1 | — | — | 1 (setup ensure) / 5 (wizard reg) |
| 60810 | table | `ocpfBootcamp` | M2 | new | RW | 2 |
| 60811 | page (List) | `ocpfBootcampList` | M2 | `ocpfBootcamp` / 60810 | RW | 3 |
| 60812 | page (Card) | `ocpfBootcampCard` | M2 | `ocpfBootcamp` / 60810 | RW | 3 |
| 60813 | codeunit | `ocpfBootcampRegMgt` | M2 | — | — | 2 |
| 60820 | table | `ocpfAttendee` | M3 | new | RW | 2 |
| 60821 | page (List) | `ocpfAttendeeList` | M3 | `ocpfAttendee` / 60820 | RW | 3 |
| 60822 | page (ListPart) | `ocpfAttendeeSubform` | M3 | `ocpfAttendee` / 60820 | RW | 3 |
| 60830 | page (API) | `ocpfBootcamps` | M4 | `ocpfBootcamp` / 60810 | RW | 4 |
| 60831 | page (API) | `ocpfAttendees` | M4 | `ocpfAttendee` / 60820 | RW | 4 |
| 60840 | page (NavigatePage) | `ocpfBootcampRegSetupWizard` | M5 | `ocpfBootcampRegSetup` / 60801 | RW | 5 |
| 60841 | pageextension | `ocpfBusinessMgrRCExt` | M5 | extends page 9022 | — | 5 |
| 60890 | permissionset | `OCPF - Bootcamp Read` | perms | — | R | 5 |
| 60891 | permissionset | `OCPF - Bootcamp Edit` | perms | — | RIMD | 5 |

All 17 IDs are inside 60800–60899. ✓ (Module = where the object *lives*; Batch = when it is
*delivered*. They differ because the two mutually-referencing core tables ship together — see §3.)

## 3. Batch / phase plan

Smallest & simplest first; lookup/reference before referrers. Compile to **0 errors / 0
warnings** after each batch before starting the next.

> **Why the two core tables share a batch (Sanity Check S-7).** `ocpfBootcamp."Registered
> Attendees"` is a `FlowField` `count("ocpfAttendee" …)` and `ocpfAttendee."Bootcamp No."` has
> `TableRelation = "ocpfBootcamp"` — the dependency is **mutual**, so neither table can compile
> in a batch that excludes the other. `ocpfBootcamp`, `ocpfAttendee`, and `ocpfBootcampRegMgt`
> (whose subscribers and helpers touch both) are therefore delivered together in Batch 2, and
> every page follows in Batch 3.

| Batch | Delivers | New objects | Why this order |
|---|---|---|---|
| **1 — Foundation** | Status enum, Setup singleton + its page, Install codeunit (setup-ensure only), **both permission sets** (scoped to `ocpfBootcampRegSetup` only; grown per batch) | 60800, 60801, 60802, 60803 (partial), 60890, 60891 (partial) | No dependency on any app table. Establishes the Status enum and the numbering configuration everything else needs. Permission sets ship here because BC SaaS PTE publish validation (PTE0004) requires every published table to be covered by an in-package permission set — ChangeLog BUILD-02. Smallest batch. |
| **2 — Core tables & logic** | Both core tables and the management codeunit, fully — all fields, all triggers, the `OnDelete` guard, `SeedAmountPaid`, `ConfirmOverbookingIfNeeded`, `UpdateSeatsRemaining`, and the four `ocpfAttendee` event subscribers; **add `ocpfBootcamp` + `ocpfAttendee` `tabledata` lines to 60890/60891** (P-15) | 60810, 60813, 60820 (+ grow 60890, 60891) | Mutual reference (see box above). Compiles as a consistent unit; no forward references. |
| **3 — In-client pages** | Bootcamp list & card (card includes the Attendees subpart), Attendee list & subform | 60811, 60812, 60821, 60822 | Pure UI over finished tables. |
| **4 — API** | Bootcamp API page, Attendee API page | 60830, 60831 | Pure projection of finished tables. |
| **5 — Wizard, Navigation, Permissions** | Assisted Setup Wizard, Business Manager RC pageextension; revisit Install codeunit to add Guided Experience registration + completion; **final review/top-up of the two permission sets (already shipped in Batch 1)** | 60840, 60841 (+ revisit 60803, review 60890/60891) | Wizard drives objects that now all exist; permission-set coverage is re-verified against the full object set. |

No batch contains a forward reference. Batch 2 is the only multi-object-type batch and is
reviewed as one unit.

## 4. Special design notes

1. **Singleton Setup (`ocpfBootcampRegSetup`).** Primary key is a blank `Code[10]` "Primary
   Key". Exactly one record. `ocpfBootcampRegInstall` inserts it on install/per-company; the
   Setup page and the wizard also self-heal (`if not Rec.Get() then begin Rec.Init();
   Rec.Insert(); end;`).
2. **Table/Page name reuse.** `table 60801` and `page 60802` are both named
   `"ocpfBootcampRegSetup"` — deliberate, mirroring standard BC (`table 98` / `page 118`
   `"General Ledger Setup"`). Allowed because they are different object types.
3. **Seats Remaining is NOT a FlowField.** AL `FlowField` `CalcFormula` supports only
   Count/Sum/Exist/Lookup/Min/Max/Average — no subtraction. Design:
   - `ocpfBootcamp."Registered Attendees"` — `FlowField`, `CalcFormula = count("ocpfAttendee"
     where("Bootcamp No." = field("No.")))`, `Editable = false`. Live.
   - `ocpfBootcamp."Seats Remaining"` — plain `Integer`, `Editable = false`, maintained by
     `ocpfBootcampRegMgt` procedure `UpdateSeatsRemaining("Bootcamp No.")` which does
     `CalcFields("Registered Attendees")` then `"Seats Remaining" := "Max Seats" - "Registered
     Attendees"; Modify(false)`.
   - Called from event subscribers in `ocpfBootcampRegMgt` on `Database::"ocpfAttendee"`:
     `OnAfterInsertEvent`, `OnAfterModifyEvent` (recompute for both `xRec."Bootcamp No."` and
     `Rec."Bootcamp No."` if they differ), `OnAfterDeleteEvent`, `OnAfterRenameEvent`; and from
     `ocpfBootcamp` `OnValidate("Max Seats")` and `OnInsert` (`"Seats Remaining" := "Max
     Seats"`).
   - This is deterministic: every mutation path recomputes from the authoritative count.
   - Recorded as ChangeLog Issue DESIGN-02; FRD D-8 / F-3 updated in place.
4. **Two top-level API entities**, not a nested API. `ocpfBootcamps` and `ocpfAttendees` are
   separate API pages; `ocpfAttendees` carries `bootcampNo` as a writable field so an
   integration can create a registration by supplying the parent number. No `API` subpage.
5. **Max Seats — warn but allow (F-10).** `ocpfAttendee` `OnInsert` calls
   `ocpfBootcampRegMgt.ConfirmOverbookingIfNeeded(Rec)`: if adding this attendee would make
   `Registered Attendees + 1 > Bootcamp."Max Seats"` **and** `GuiAllowed`, show
   `Confirm(OverbookingQst)` — `false` → `Error('')` (silent cancel). When `not GuiAllowed`
   (API), proceed silently. Never a hard block.
6. **Bootcamp delete — block (F-11, D-11).** `ocpfBootcamp` `OnDelete`: if any `ocpfAttendee`
   has `"Bootcamp No." = Rec."No."`, `Error(CannotDeleteBootcampErr)` with an actionable
   message. Verified via `Attendee.SetRange(...); Attendee.IsEmpty()`.
7. **Amount Paid seeding (D-9).** `ocpfBootcampRegMgt.SeedAmountPaid(var Attendee)`: exits if
   `Attendee."Amount Paid" <> 0` or `Attendee."Bootcamp No." = ''`; otherwise sets `Attendee.
   "Amount Paid" := Bootcamp."Price"`. Called from `ocpfAttendee` `OnInsert` and from
   `OnValidate("Bootcamp No.")` (only while Amount Paid is still 0). A user/API value — including
   an explicit 0 that stays 0 — is never overwritten. Documented edge: a genuine free (0)
   registration will re-seed to Price if the bootcamp is later changed while Amount Paid is
   still 0; acceptable, noted for the user guide.
8. **`SourceTableView` / `const()` quoting.** No document-type-filtered pages exist in this
   design (Attendee subform uses `SubPageLink`, not `SourceTableView`). The `const()` quoting
   rule (Standards §4.3) is **N/A** for this project. If a filtered list is added later, quote
   only multi-word enum values inside `const()`.
9. **FlowField key.** `ocpfAttendee` declares `key(BootcampNo; "Bootcamp No.")` to back the
   `Registered Attendees` count and the delete-guard `SetRange`.
10. **Email validation (D-13).** `ocpfAttendee."Email Address"` uses `ExtendedDatatype = EMail`
    plus a dependency-free `OnValidate`: if non-blank, `Error` unless the value contains exactly
    one `@`, no spaces, and a `.` after the `@`. No external codeunit dependency.
11. **Uninstall.** `ocpfBootcampRegInstall` has no explicit uninstall logic; the platform
    removes the Guided Experience item registered by AppId on uninstall (N-6). If verification
    in Step 09 shows an orphan, add `OnUninstall` calling `GuidedExperience.Remove(...)`.

## 5. Standard objects — verified numbers & `using` namespaces

All confirmed against the BC v28.4 symbol files on 2026-09-10.

| Object | Kind / No. | `using` namespace | Used by | Members used |
|---|---|---|---|---|
| `No. Series` | table **308** | `Microsoft.Foundation.NoSeries` | 60801, 60810, 60820, 60813 | `TableRelation` target; `LookupPageId = "No. Series"` for assist-edit |
| `No. Series` | codeunit **310** | `Microsoft.Foundation.NoSeries` | 60813 | `GetNextNo(Code[20]): Code[20]`, `PeekNextNo(Code[20]): Code[20]`, `TestManual(Code[20])` |
| `No. Series Line` | table **309** | `Microsoft.Foundation.NoSeries` | (indirect via codeunit 310) | — |
| `Customer` | table **18** | `Microsoft.Sales.Customer` | 60820 | `TableRelation` target for `"Customer No."` |
| `Guided Experience` | codeunit **1990** | `System.Environment.Configuration` | 60803 | `InsertAssistedSetup(Text[2048]; Text[50]; Text[1024]; Integer; ObjectType; Integer; Enum "Assisted Setup Group"; Text[250]; Enum "Video Category"; Text[250])`, `IsAssistedSetupComplete(ObjectType; Integer): Boolean`, `CompleteAssistedSetup(ObjectType; Integer)`, `Run(Enum "Guided Experience Type"; ObjectType; Integer)` |
| `Assisted Setup Group` | enum **1815** (ext 1814 BaseApp) | `System.Environment.Configuration` | 60803 | value `Extensions` (5) — "Install extensions to add features and integrations" |
| `Video Category` | enum **3710** | `System.Media` | 60803 | value `Uncategorized` (0) |
| `Guided Experience Type` | enum | `System.Environment.Configuration` | 60803 | value `"Assisted Setup"` (used by `Run`) |
| `Business Manager Role Center` | page **9022** | `Microsoft.Finance.RoleCenters` | 60841 | `extends`; add `addlast(sections)` group — `area(sections)` confirmed present in page 9022 (Sanity S-1); no coupling to internal control names |

> Agent knowledge of BC table numbers is not authoritative; the four verifications above were
> read from the symbol `.al` files. Re-checked in Step 04.

## 6. Per-object specification

Notation: `id` = field id; identifiers are the source names shown; every field gets `Caption`
and `ToolTip` (ToolTip text drafted in Step 06). All lengths ≤ 30. `AutoFormatType = 1` = LCY.

### 6.1 enum 60800 `ocpfBootcampStatus`

| Property | Value |
|---|---|
| Extensible | `false` |

| value | name | Caption |
|---|---|---|
| 0 | `Active` | `Active` |
| 1 | `Inactive` | `Inactive` |
| 2 | `Completed` | `Completed` |
| 3 | `Canceled` | `Canceled` |

Default for a new bootcamp = `Active` (enum ordinal 0; also set `InitValue = Active` on the
table field for explicitness).

### 6.2 table 60801 `ocpfBootcampRegSetup`

`using Microsoft.Foundation.NoSeries;` · `DataClassification = CustomerContent` ·
`Caption = 'Bootcamp Registration Setup'`

| id | field | type | properties |
|---|---|---|---|
| 1 | `Primary Key` | `Code[10]` | `Caption = 'Primary Key'` |
| 10 | `Bootcamp Nos.` | `Code[20]` | `TableRelation = "No. Series"` |
| 20 | `Attendee Nos.` | `Code[20]` | `TableRelation = "No. Series"` |

Keys: `key(PK; "Primary Key"){ Clustered = true; }`. No triggers. No `OnDelete` handling
(singleton, not user-deletable — Setup page has no Delete).

### 6.3 table 60810 `ocpfBootcamp`

`using Microsoft.Foundation.NoSeries;` · `DataClassification = CustomerContent` ·
`Caption = 'Bootcamp'` · `LookupPageId = "ocpfBootcampList"` · `DrillDownPageId = "ocpfBootcampList"`

| id | field | type | properties / behavior |
|---|---|---|---|
| 1 | `No.` | `Code[20]` | `OnValidate`: if `Rec."No." <> xRec."No."` then `ocpfBootcampRegMgt.TestBootcampManualNo()` and `Rec."No. Series" := ''`. |
| 2 | `No. Series` | `Code[20]` | `Editable = false`; `TableRelation = "No. Series"`. |
| 3 | `Topic` | `Text[100]` | free text. |
| 4 | `Location` | `Text[100]` | free text (venue/city) — **not** linked to `Location` T14. |
| 5 | `Bootcamp Date` | `Date` | single day. |
| 6 | `Price` | `Decimal` | `AutoFormatType = 1`; `MinValue = 0`. |
| 7 | `Max Seats` | `Integer` | `MinValue = 0`; `OnValidate`: `ocpfBootcampRegMgt.UpdateSeatsRemaining(Rec."No.")` (only if `Rec."No." <> ''`). |
| 8 | `Min Seats` | `Integer` | `Caption = 'Min Seats (Go/No-Go)'`; `MinValue = 0`. Informational only. |
| 9 | `Registered Attendees` | `Integer` | `FieldClass = FlowField`; `CalcFormula = count("ocpfAttendee" where("Bootcamp No." = field("No.")))`; `Editable = false`. |
| 10 | `Seats Remaining` | `Integer` | `Editable = false`. Maintained by `UpdateSeatsRemaining` (see §4.3). Not a FlowField. |
| 11 | `Status` | `Enum "ocpfBootcampStatus"` | `InitValue = Active`. No code ever changes it. |

Keys: `key(PK; "No."){ Clustered = true; }`.
Triggers:
- `OnInsert`: if `Rec."No." = ''` then `ocpfBootcampRegMgt.InitBootcampNo(Rec)`; `Rec."Seats
  Remaining" := Rec."Max Seats"`.
- `OnDelete`: `Attendee.SetRange("Bootcamp No.", Rec."No."); if not
  Attendee.IsEmpty() then Error(CannotDeleteBootcampErr);`
  `CannotDeleteBootcampErr: Label 'You cannot delete bootcamp %1 because attendee registrations
  exist for it. Delete the registrations first.', Comment = '%1 = Bootcamp No.';`
- `OnModify`, `OnRename`: none.

### 6.4 table 60820 `ocpfAttendee`

`using Microsoft.Foundation.NoSeries;` · `using Microsoft.Sales.Customer;` ·
`DataClassification = CustomerContent` · `Caption = 'Attendee'` ·
`LookupPageId = "ocpfAttendeeList"` · `DrillDownPageId = "ocpfAttendeeList"`

| id | field | type | properties / behavior |
|---|---|---|---|
| 1 | `No.` | `Code[20]` | `OnValidate`: if `Rec."No." <> xRec."No."` then `ocpfBootcampRegMgt.TestAttendeeManualNo()` and `Rec."No. Series" := ''`. |
| 2 | `No. Series` | `Code[20]` | `Editable = false`; `TableRelation = "No. Series"`. |
| 3 | `Bootcamp No.` | `Code[20]` | `NotBlank = true`; `TableRelation = "ocpfBootcamp"`. `OnValidate`: if changed, `ocpfBootcampRegMgt.SeedAmountPaid(Rec)` (guarded to Amount Paid = 0); recompute handled by the modify subscriber. |
| 10 | `Name` | `Text[100]` | free text. |
| 11 | `Email Address` | `Text[80]` | `ExtendedDatatype = EMail`; `OnValidate` format check per §4.10. |
| 12 | `Phone Number` | `Text[30]` | `ExtendedDatatype = PhoneNo`. |
| 13 | `Company` | `Text[100]` | free text. |
| 14 | `Customer No.` | `Code[20]` | `TableRelation = Customer`; may be blank. Plain link — no field auto-population. |
| 20 | `Paid` | `Boolean` | — |
| 21 | `Payment Date` | `Date` | not enforced against `Paid`. |
| 22 | `Amount Paid` | `Decimal` | `AutoFormatType = 1`; `MinValue = 0`. Seeded per §4.7. |
| 30 | `Attended` | `Boolean` | — |

Keys: `key(PK; "No."){ Clustered = true; }` · `key(BootcampNo; "Bootcamp No.")`.
Triggers:
- `OnInsert`: if `Rec."No." = ''` then `ocpfBootcampRegMgt.InitAttendeeNo(Rec)`;
  `ocpfBootcampRegMgt.SeedAmountPaid(Rec)`; `ocpfBootcampRegMgt.ConfirmOverbookingIfNeeded(Rec)`.
- `OnModify`, `OnDelete`, `OnRename`: none on the table itself — seat maintenance is done by the
  subscribers in `ocpfBootcampRegMgt` (§4.3) so it always runs on committed state, including
  for API and direct writes.

### 6.5 codeunit 60813 `ocpfBootcampRegMgt`

`using Microsoft.Foundation.NoSeries;` · `SingleInstance = false` · no `Subtype` (normal).

Procedures:

| Procedure | Body summary |
|---|---|
| `InitBootcampNo(var Bootcamp: Record "ocpfBootcamp")` | `GetSetup(); Setup.TestField("Bootcamp Nos."); Bootcamp."No. Series" := Setup."Bootcamp Nos."; Bootcamp."No." := NoSeries.GetNextNo(Setup."Bootcamp Nos.");` |
| `InitAttendeeNo(var Attendee: Record "ocpfAttendee")` | analogous with `Setup."Attendee Nos."`. |
| `TestBootcampManualNo()` | `GetSetup(); NoSeries.TestManual(Setup."Bootcamp Nos.");` |
| `TestAttendeeManualNo()` | `GetSetup(); NoSeries.TestManual(Setup."Attendee Nos.");` |
| `SeedAmountPaid(var Attendee: Record "ocpfAttendee")` | per §4.7. |
| `ConfirmOverbookingIfNeeded(var Attendee: Record "ocpfAttendee")` | per §4.5. `OverbookingQst: Label 'Bootcamp %1 is full (%2 of %3 seats used). Register %4 anyway?', Comment='%1=Bootcamp No.,%2=used,%3=Max Seats,%4=Attendee name';` |
| `UpdateSeatsRemaining(BootcampNo: Code[20])` | per §4.3. `if BootcampNo = '' then exit; if not Bootcamp.Get(BootcampNo) then exit; Bootcamp.CalcFields("Registered Attendees"); Bootcamp."Seats Remaining" := Bootcamp."Max Seats" - Bootcamp."Registered Attendees"; Bootcamp.Modify(false);` |
| `GetSetup()` (local) | `if SetupLoaded then exit; if not Setup.Get() then begin Setup.Init(); Setup.Insert(); end; SetupLoaded := true;` |

Event subscribers (in the same codeunit):

| Subscriber | Event | Action |
|---|---|---|
| `OnAfterInsertAttendee` | `Database::"ocpfAttendee", OnAfterInsertEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` |
| `OnAfterModifyAttendee` | `..., OnAfterModifyEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No."); if xRec."Bootcamp No." <> Rec."Bootcamp No." then UpdateSeatsRemaining(xRec."Bootcamp No.")` |
| `OnAfterDeleteAttendee` | `..., OnAfterDeleteEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` |
| `OnAfterRenameAttendee` | `..., OnAfterRenameEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` (No. rename only; bootcamp unchanged — cheap, harmless) |

Variables: `Setup: Record "ocpfBootcampRegSetup"; NoSeries: Codeunit "No. Series"; Bootcamp:
Record "ocpfBootcamp"; SetupLoaded: Boolean;`

> All procedures and all four subscribers are delivered in **Batch 2** together with both core
> tables (Sanity Check S-7).

### 6.6 codeunit 60803 `ocpfBootcampRegInstall`

`using System.Environment.Configuration;` · `using System.Media;` · `Subtype = Install`.

- `OnInstallAppPerCompany()`:
  - `EnsureSetup()` — `if not Setup.Get() then begin Setup.Init(); Setup.Insert(); end;`
  - `RegisterAssistedSetup()` *(added Batch 5)*:
    ```
    if GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"ocpfBootcampRegSetupWizard") then exit;
    GuidedExperience.InsertAssistedSetup(
        SetupTitleTxt, CopyStr(SetupTitleTxt,1,50), SetupDescTxt, 5,
        ObjectType::Page, Page::"ocpfBootcampRegSetupWizard",
        "Assisted Setup Group"::Extensions,
        '', "Video Category"::Uncategorized, '');
    ```
  - Labels: `SetupTitleTxt: Label 'Set up Bootcamp Registration Tracking';`
    `SetupDescTxt: Label 'Choose the number series for bootcamps and attendees, and optionally create sample bootcamps.';`

### 6.7 page 60802 `ocpfBootcampRegSetup` (Card, single instance)

`PageType = Card` · `SourceTable = "ocpfBootcampRegSetup"` · `UsageCategory = None` ·
`ApplicationArea = All` · `Caption = 'Bootcamp Registration Setup'` · `DeleteAllowed = false` ·
`InsertAllowed = false`.
- `OnOpenPage`: `if not Rec.Get() then begin Rec.Init(); Rec.Insert(); end;`
- `layout`: `group(Numbering)` with `field("Bootcamp Nos."; Rec."Bootcamp Nos.")` and
  `field("Attendee Nos."; Rec."Attendee Nos.")` — both `ApplicationArea = All`, with lookup to
  `"No. Series"` (default via `TableRelation`).
- `actions`: `action(RunAssistedSetup)` *(Batch 5)* — `Caption = 'Assisted Setup'`,
  `Image = Setup`, runs `GuidedExperience.Run("Guided Experience Type"::"Assisted Setup",
  ObjectType::Page, Page::"ocpfBootcampRegSetupWizard")`.

### 6.8 page 60811 `ocpfBootcampList` (List)

`PageType = List` · `SourceTable = "ocpfBootcamp"` · `UsageCategory = Lists` ·
`ApplicationArea = All` · `CardPageId = "ocpfBootcampCard"` · `Editable = true` ·
`Caption = 'Bootcamps'`.
Repeater fields (all `ApplicationArea = All`): `No.`, `Topic`, `Location`, `Bootcamp Date`,
`Status`, `Max Seats`, `Registered Attendees`, `Seats Remaining`, `Min Seats`, `Price`.
`trigger OnAfterGetRecord()`: `Rec.CalcFields("Registered Attendees");`
Action `Attendees` — `RunObject = page "ocpfAttendeeList"`, `RunPageLink = "Bootcamp No." =
field("No.")`, `Image = Users`.

### 6.9 page 60812 `ocpfBootcampCard` (Card)

`PageType = Card` · `SourceTable = "ocpfBootcamp"` · `ApplicationArea = All` ·
`Caption = 'Bootcamp'`.
- `group(General)`: `No.`, `Topic`, `Location`, `Bootcamp Date`, `Status`.
- `group("Capacity & Pricing")`: `Price`, `Max Seats`, `Min Seats`, `Registered Attendees`,
  `Seats Remaining`.
- `part(Attendees; "ocpfAttendeeSubform")` — `SubPageLink = "Bootcamp No." =
  field("No.")`, `UpdatePropagation = Both`.
- `trigger OnAfterGetRecord()`: `Rec.CalcFields("Registered Attendees");`

### 6.10 page 60821 `ocpfAttendeeList` (List)

`PageType = List` · `SourceTable = "ocpfAttendee"` · `UsageCategory = Lists` ·
`ApplicationArea = All` · `Editable = true` · `Caption = 'Attendees'`.
Fields: `Bootcamp No.`, `No.`, `Name`, `Email Address`, `Phone Number`, `Company`,
`Customer No.`, `Paid`, `Payment Date`, `Amount Paid`, `Attended`.

### 6.11 page 60822 `ocpfAttendeeSubform` (ListPart)

`PageType = ListPart` · `SourceTable = "ocpfAttendee"` · `ApplicationArea = All` ·
`DelayedInsert = true` · `AutoSplitKey = false` · `Caption = 'Attendees'`.
Fields: `Name`, `Email Address`, `Phone Number`, `Company`, `Customer No.`, `Paid`,
`Payment Date`, `Amount Paid`, `Attended`. (`Bootcamp No.` supplied by `SubPageLink`, not shown.)

### 6.12 page 60830 `ocpfBootcamps` (API)

Follows the §9.1 template exactly. `SourceTable = "ocpfBootcamp"`, `EntityName = 'ocpfBootcamp'`,
`EntitySetName = 'ocpfBootcamps'`, `EntityCaption = 'Bootcamp'`, `EntitySetCaption = 'Bootcamps'`,
`DelayedInsert = true`, `Extensible = false`.

| API field (camelCase) | source | notes |
|---|---|---|
| `systemId` | `Rec.SystemId` | `Editable = false` |
| `number` | `Rec."No."` | |
| `topic` | `Rec."Topic"` | |
| `location` | `Rec."Location"` | |
| `bootcampDate` | `Rec."Bootcamp Date"` | |
| `price` | `Rec."Price"` | |
| `maxSeats` | `Rec."Max Seats"` | |
| `minSeats` | `Rec."Min Seats"` | |
| `registeredAttendees` | `Rec."Registered Attendees"` | `Editable = false` |
| `seatsRemaining` | `Rec."Seats Remaining"` | `Editable = false` |
| `status` | `Rec."Status"` | enum surfaces as its value name |
| `lastModifiedDateTime` | `Rec.SystemModifiedAt` | `Editable = false` |

`trigger OnAfterGetRecord()`: `Rec.CalcFields("Registered Attendees");`
Reserved-word note: `No.` → identifier `number` (avoid the reserved bareword `no`? `no` is not
reserved, but `number` is clearer and conventional in BC APIs).

### 6.13 page 60831 `ocpfAttendees` (API)

`SourceTable = "ocpfAttendee"`, `EntityName = 'ocpfAttendee'`, `EntitySetName = 'ocpfAttendees'`,
`EntityCaption = 'Attendee'`, `EntitySetCaption = 'Attendees'`, `DelayedInsert = true`,
`Extensible = false`.

| API field | source | notes |
|---|---|---|
| `systemId` | `Rec.SystemId` | `Editable = false` |
| `number` | `Rec."No."` | |
| `bootcampNo` | `Rec."Bootcamp No."` | writable — how an integration attaches to a bootcamp |
| `name` | `Rec."Name"` | |
| `email` | `Rec."Email Address"` | |
| `phoneNumber` | `Rec."Phone Number"` | |
| `company` | `Rec."Company"` | |
| `customerNo` | `Rec."Customer No."` | optional |
| `paid` | `Rec."Paid"` | |
| `paymentDate` | `Rec."Payment Date"` | |
| `amountPaid` | `Rec."Amount Paid"` | seeded server-side if omitted / 0 |
| `attended` | `Rec."Attended"` | |
| `lastModifiedDateTime` | `Rec.SystemModifiedAt` | `Editable = false` |

No `OnAfterGetRecord` calc needed (no FlowField exposed).

### 6.14 page 60840 `ocpfBootcampRegSetupWizard` (NavigatePage)

`PageType = NavigatePage` · `SourceTable = "ocpfBootcampRegSetup"` · `ApplicationArea = All` ·
`Caption = 'Bootcamp Registration Setup'` · `UsageCategory = None`.
Steps (via a `Step` option variable + `group`s with `Visible` bindings):
1. **Welcome** — static text describing what the wizard does.
2. **Numbering** — `field("Bootcamp Nos."; Rec."Bootcamp Nos.")`, `field("Attendee Nos.";
   Rec."Attendee Nos.")`. If either is blank on "Next", offer to create a default series
   (`BOOTCAMP` / `ATTENDEE`) via a helper (see below).
3. **Sample data** — `field(CreateSamples; CreateSamplesVar)` boolean ("Create two sample
   bootcamps so I can see how this works").
4. **Finish** — summary text.
`trigger OnOpenPage`: ensure Setup record (as §6.7).
`actionref`s: `Back`, `Next`, `Finish` (standard NavigatePage `SystemActions`).
`OnQueryClosePage` / `Finish` action:
- `Rec.Modify(true)` (persist the two series).
- If `CreateSamplesVar` then `CreateSampleBootcamps()` — inserts 2 `ocpfBootcamp` rows
  (e.g. "AL Extension Development", "Business Central for Consultants"), dates ~30/60 days out,
  `Price := 1500`, `Max Seats := 20`, `Min Seats := 6`, `Status := Active`. Uses normal
  `Bootcamp.Insert(true)` so numbering fires.
- `GuidedExperience.CompleteAssistedSetup(ObjectType::Page,
  Page::"ocpfBootcampRegSetupWizard");`
Helper `CreateDefaultSeriesIfBlank()` — creates a `No. Series` + `No. Series Line`
(`"Starting No." := 'BC00001'` / `'ATT00001'`) when the field is blank and the user consents.
`using Microsoft.Foundation.NoSeries;` · `using System.Environment.Configuration;`.

### 6.15 pageextension 60841 `ocpfBusinessMgrRCExt`

`using Microsoft.Finance.RoleCenters;` · `extends "Business Manager Role Center"`.
```
addlast(sections)
{
    group(ocpfBootcamps)
    {
        Caption = 'Bootcamps';
        action(ocpfBootcampListAction)      { RunObject = page "ocpfBootcampList"; Caption='Bootcamps'; ApplicationArea=All; Image=Users; ToolTip='Open the list of bootcamps.'; }
        action(ocpfAttendeeListAction)      { RunObject = page "ocpfAttendeeList"; Caption='Bootcamp Attendees'; ApplicationArea=All; Image=Persons; ToolTip='Open the list of bootcamp attendees.'; }
        action(ocpfBootcampSetupAction)     { RunObject = page "ocpfBootcampRegSetup"; Caption='Bootcamp Registration Setup'; ApplicationArea=All; Image=Setup; ToolTip='Open the Bootcamp Registration Setup.'; }
    }
}
```
`addlast(sections)` targets `area(sections)` (confirmed present at page 9022 line 457, Sanity
S-1) and avoids any dependency on internal control names.

### 6.16 permissionset 60890 `OCPF - Bootcamp Read`

`Assignable = true` · `Caption = 'OCPF - Bootcamp Read'`. **Shipped in Batch 1** (ChangeLog
BUILD-02); `tabledata` lines added as each batch introduces its table — final state:
```
Permissions =
    tabledata "ocpfBootcamp" = R,          // added Batch 2
    tabledata "ocpfAttendee" = R,          // added Batch 2
    tabledata "ocpfBootcampRegSetup" = R;  // Batch 1
```
(Objects — pages/codeunits — are covered by the extension's `InherentPermissions`/execution;
tabledata is the controlling grant. If Step 09 shows page-execution gaps, add
`page ... = X` lines.)

### 6.17 permissionset 60891 `OCPF - Bootcamp Edit`

`Assignable = true` · `Caption = 'OCPF - Bootcamp Edit'` ·
`IncludedPermissionSets = "OCPF - Bootcamp Read"`. **Shipped in Batch 1** (ChangeLog BUILD-02);
`tabledata` lines grown per batch — final state:
```
Permissions =
    tabledata "ocpfBootcamp" = IMD,          // added Batch 2
    tabledata "ocpfAttendee" = IMD,          // added Batch 2
    tabledata "ocpfBootcampRegSetup" = IMD;  // Batch 1
```

## 7. Deletion behavior (explicit — feeds Step 04)

| Table | Behavior | Mechanism | Referencing fields re-checked |
|---|---|---|---|
| `ocpfBootcamp` | **Block** if any attendee references it | `OnDelete` → `Error` (§6.3) | `ocpfAttendee."Bootcamp No."` (this app). No standard BC table references `ocpfBootcamp`. |
| `ocpfAttendee` | **Allow**; parent seat count updated | `OnAfterDeleteEvent` subscriber → `UpdateSeatsRemaining` | none reference `ocpfAttendee`. |
| `ocpfBootcampRegSetup` | **Not user-deletable** | Setup page `DeleteAllowed = false`; no wizard delete | n/a (singleton). |
| `Customer` (std) | Not extended | — | `ocpfAttendee."Customer No."` is an **optional** link; deleting a Customer is **not** blocked by this app and may leave a dangling `Customer No.`. **Decision: accepted** — informational link, low harm, `ValidateTableRelation` still prevents setting an invalid value. Step 04 to confirm; a `Customer` `OnDelete` subscriber to blank the field was considered and declined to keep the footprint minimal. |

## 8. Field conversion / naming decisions (Standards §6)

| Source name | AL identifier | Decision |
|---|---|---|
| "No." | `No.` (table), `number` (API) | Standard BC pattern; `.` kept in table field id, camelCased away for API. |
| "Min Seats (Go/No-Go)" | `Min Seats` + `Caption = 'Min Seats (Go/No-Go)'` | Parenthetical kept in caption, not identifier. |
| "Email Address" | `Email Address` (table), `email` (API) | — |
| "Bootcamp Date" | `Bootcamp Date` / `bootcampDate` | — |
| "Amount Paid" | `Amount Paid` / `amountPaid` | — |
| "Seats Remaining" | `Seats Remaining` / `seatsRemaining` | Stored, not FlowField (§4.3). |
| "Registered Attendees" | `Registered Attendees` / `registeredAttendees` | FlowField count. |

- No reserved-keyword collisions (`Status`, `Company`, `Name`, `Location`, `Price` are all
  valid AL field identifiers when `Rec.`-qualified; none are AL keywords).
- No abbreviations required — all identifiers ≤ 30 chars (longest: `Registered Attendees` = 20).
- No obsolete/pending fields referenced anywhere (all source tables' fields used —
  `No. Series`, `Customer` — are current in v28.4).
- Localization `NA`: no field is included or excluded on a localization basis (no localized
  standard fields are touched; all fields are on new tables).

## 9. Standard templates (every generated object follows these)

### 9.1 API page template

```al
namespace OCPF.BootcampRegistration;

// using lines only if the page references a standard object type

page 608XX "ocpfEntitySet"
{
    PageType = API;
    Caption = 'EntitySet';                 // plural, plain
    APIPublisher = 'OnlyCopilotFans';
    APIGroup = 'ocpf_bootcampRegistration';
    APIVersion = 'v1.0';
    EntityName = 'ocpfEntity';
    EntitySetName = 'ocpfEntitySet';
    EntityCaption = 'Entity';
    EntitySetCaption = 'EntitySet';
    SourceTable = "ocpf...";
    ODataKeyFields = SystemId;
    DelayedInsert = true;                   // editable API => exactly this (not Editable=false)
    Extensible = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System Id';
                    Editable = false;
                }
                field(<camelCaseName>; Rec."<Source Field>")
                {
                    Caption = '<Readable, self-describing for an API consumer>';
                }
                // ... one field per exposed column
            }
        }
    }
    // OnAfterGetRecord only if a FlowField is exposed:
    // trigger OnAfterGetRecord() begin Rec.CalcFields("<FlowField>"); end;
}
```

Rules for every API page: `ODataKeyFields = SystemId`; exactly one of `DelayedInsert = true`
(all pages in this project — both are read/write) or `Editable = false`; every field a `Caption`;
no `ToolTip` required on API pages but `Caption` must be self-describing; no business logic in
the API page (logic lives in the table triggers / `ocpfBootcampRegMgt`).

### 9.2 Table field template

```al
field(<id>; "<Name>"; <Type>)
{
    Caption = '<Readable>';
    ToolTip = '<Specifies ...>';           // self-describing schema for consumers
    DataClassification = CustomerContent;  // or inherit table-level
    // MinValue / TableRelation / Editable / ExtendedDatatype / InitValue as specified in §6
    // trigger OnValidate() only where §6 lists behavior — never an empty trigger
}
```

### 9.3 Non-API page field template

```al
field("<Name>"; Rec."<Name>")
{
    ApplicationArea = All;
    ToolTip = 'Specifies <...>';
    // Editable / Importance / etc. as specified
}
```

### 9.4 Formatting

4-space indent, no tabs. One `namespace` line per file. `using` lines sorted, only those
actually referenced. No dead code, no empty triggers, no commented-out fields, no `// TODO`.

## 10. Pre-flight validation (run before each batch — Standards §9.1)

| Check | Rule |
|---|---|
| Identifier length | every field/object identifier ≤ 30 chars |
| Entity name length | `EntityName` / `EntitySetName` ≤ 30 incl. `ocpf` |
| Object IDs | all within 60800–60899; none reused |
| Reserved keywords | no field identifier is an AL keyword |
| Localization filter | n/a (no localized standard fields) — assert "no `#if`/localization gating added" |
| `ObsoleteState` | no referenced standard field/table/proc/event is `Pending`/`Removed` |
| Required properties | every table field + non-API page field has `Caption` + `ToolTip`; every non-API page field has `ApplicationArea = All`; every API page has `ODataKeyFields = SystemId` + exactly one of `DelayedInsert=true`/`Editable=false` |
| `Rec.` prefix | every field reference qualified (`NoImplicitWith`) |
| No dead code | no empty triggers / TODO / commented fields |
| Permission-set coverage (P-15) | every table introduced in the batch has a `tabledata` line in a permission set shipped in the same batch — BC PTE publish validation (PTE0004). See ChangeLog BUILD-02. |
| File naming (P-16) | every `.al` file named `<ObjectName>.<Type>.al` (CodeCop AA0215) |

## 11. Traceability — FRD → TDD

| FRD | TDD |
|---|---|
| F-1 Bootcamp CRUD | 60810 table, 60811/60812 pages |
| F-2 Bootcamp fields | §6.3 |
| F-3 Seats Remaining + Registered Attendees | §4.3, §6.3 fields 9–10 |
| F-4 manual Status | §6.1 enum, §6.3 field 11 (no code changes it) |
| F-5 Attendee CRUD, parent link, numbering | 60820 table, §6.5 `InitAttendeeNo` |
| F-6 Attendee contact fields | §6.4 fields 10–13 |
| F-7 optional Customer link | §6.4 field 14, `using Microsoft.Sales.Customer` |
| F-8 Amount Paid default, editable, no overwrite | §4.7, §6.5 `SeedAmountPaid` |
| F-9 Attended flag | §6.4 field 30 |
| F-10 Max Seats warn-but-allow | §4.5, §6.5 `ConfirmOverbookingIfNeeded` |
| F-11 block delete with attendees | §4.6, §6.3 `OnDelete`, §7 |
| F-12 Setup singleton with two No. Series | §6.2, §6.7 |
| F-13 wizard registered in Assisted Setup, re-runnable, completion state | §6.14, §6.6 `RegisterAssistedSetup`, §6.7 action |
| F-14 in-client pages + Business Manager RC entry | §6.8–§6.11, §6.15 |
| F-15 API v1.0 read/write for Bootcamp & Attendee | §6.12, §6.13, §9.1 |
| D-1…D-15 | §1, §5, §9, §10 |
| N-1…N-9 | §9.4, §10, §7, §4.5 |

---

**Exit gate (Step 03):** Technical Lead sign-off. Self-sufficiency check: no rule here requires
knowledge outside this document + `ProjectParameters.md` + the named symbol files.

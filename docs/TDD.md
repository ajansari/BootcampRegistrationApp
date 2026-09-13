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
| APIPublisher | `'onlyCopilotFans'` **(camelCase — AA0101; diverges from Standards §1.3's `'<Publisher>'` example. See ChangeLog BUILD-06.)** |
| APIGroup | `'ocpfBootcampRegistration'` **(camelCase, no `<prefix>_` separator — AA0101; diverges from Standards §1.3's `'<prefix>_<camelCaseGroupName>'` pattern. See ChangeLog BUILD-06.)** |
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
| **M5 Wizard & Navigation** | 60840–60859 | 5 | 15 (75%) | Assisted Setup Wizard page, Business Manager RC pageextension, + gap-fill Activity Cues: `ocpfActivitiesCueExt` tableextension (60842), `ocpfActivityCueMgt` codeunit (60843), `ocpfO365ActivitiesExt` pageextension (60844) — BUILD-09, folded in at Step 08 (G-01) |
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
| 60842 | tableextension | `ocpfActivitiesCueExt` | M5 | extends table 1313 "Activities Cue" | — | Gap-fill (BUILD-09) |
| 60843 | codeunit | `ocpfActivityCueMgt` | M5 | — | — | Gap-fill (BUILD-09) |
| 60844 | pageextension | `ocpfO365ActivitiesExt` | M5 | extends page 1310 "O365 Activities" | — | Gap-fill (BUILD-09) |
| 60890 | permissionset | `OCPF - Bootcamp Read` | perms | — | R | 5 |
| 60891 | permissionset | `OCPF - Bootcamp Edit` | perms | — | RIMD | 5 |

All 20 IDs (17 planned + 3 gap-fill) are inside 60800–60899. ✓ (Module = where the object
*lives*; Batch = when it is *delivered*. They differ because the two mutually-referencing core
tables ship together — see §3 — and because the three gap-fill objects arrived after the
5-batch plan closed.)

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
   - `ocpfBootcamp."Seats Remaining"` — plain `Integer`, `Editable = false`, maintained **two
     different ways depending on which side changed**, both funneling through one shared
     procedure, `ocpfBootcamp.CalcSeatsRemaining()`, added at Step 09 (`CodeReview.md` BP-7):
     `if Rec."Max Seats" <= 0 then exit(0); exit(Rec."Max Seats" - Rec."Registered Attendees");`
     — **`Max Seats <= 0` ("no cap", F-10) always shows `0`, never a negative number.** Before
     this, an uncapped bootcamp with registrations beyond 0 displayed a raw negative subtraction.
     - **From `ocpfAttendee`'s own event subscribers** (a registration was added/changed/
       removed) — `ocpfBootcampRegMgt` procedure `UpdateSeatsRemaining("Bootcamp No.")`, which
       does `Bootcamp.Get(BootcampNo); Bootcamp.CalcFields("Registered Attendees");
       Bootcamp."Seats Remaining" := Bootcamp.CalcSeatsRemaining(); Bootcamp.Modify(false);`.
       Correct here because the attendee change is already committed to the database by the
       time these subscribers run.
     - **From `ocpfBootcamp."Max Seats".OnValidate`** (the seat cap itself changed) —
       computed **in memory, directly on `Rec`**: `Rec.CalcFields("Registered Attendees");
       Rec."Seats Remaining" := Rec.CalcSeatsRemaining();`. **Must not** call
       `UpdateSeatsRemaining` here: `OnValidate` runs *before* the page/API's own pending
       write for `Max Seats` is committed, so a `Get()`/`Modify()` pair reads the stale
       pre-change row and its write is then silently overwritten by the caller's own save —
       exactly the bug the original design had (deterministic on any Card-created bootcamp
       where `Max Seats` isn't the very first field entered, and on any edit to `Max Seats` on
       an existing bootcamp). **Generalizable rule:** never recompute a stored field by
       re-`Get()`-ing the same record from the database inside its own `OnValidate` — write
       directly to `Rec` instead.
   - Called from event subscribers in `ocpfBootcampRegMgt` on `Database::"ocpfAttendee"`:
     `OnAfterInsertEvent`, `OnAfterModifyEvent`, `OnAfterDeleteEvent`, `OnAfterRenameEvent`; and
     from `ocpfBootcamp` `OnValidate("Max Seats")` (in-memory, per above) and `OnInsert`
     (`"Seats Remaining" := Rec.CalcSeatsRemaining()` — a brand-new bootcamp's in-memory
     `Registered Attendees` is correctly 0 without a `CalcFields`, so this reduces to `Max Seats`
     unless `Max Seats <= 0`).
   - **`OnAfterModifyEvent`'s `xRec` reliability, corrected at Step 09 (`CodeReview.md` BP-2):**
     `xRec` inside a table trigger is only a true before-image when the change came from a page —
     a code- or API-driven `Modify()` leaves `xRec` equal to `Rec`, so the original
     `if xRec."Bootcamp No." <> Rec."Bootcamp No." then UpdateSeatsRemaining(xRec."Bootcamp No.")`
     branch never fired on that path, leaving the *old* bootcamp's `Seats Remaining` stale after
     an API-driven reassignment. Fixed with a new `OnBeforeModifyEvent` subscriber:
     `xRec.Get(xRec."No.")` — refreshing `xRec` from the database before the write, which carries
     the real prior row through to `OnAfterModifyEvent` regardless of caller (the documented
     technique for this exact AL gotcha; Microsoft's own reference page doesn't spell it out,
     independently verified against multiple sources before applying). **Generalizable rule:**
     never trust `xRec` for a "did this key field change?" check without first confirming the
     record can only ever be modified from a page — refresh it defensively otherwise.
   - This is deterministic: every mutation path recomputes from the authoritative count.
   - Recorded as ChangeLog Issue DESIGN-02; FRD D-8 / F-3 updated in place. The `OnValidate`
     correction is ChangeLog STEP08-01 (G-12); the `xRec` and no-cap-clamp corrections are
     ChangeLog STEP09-02 (BP-2, BP-7).
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
   `Attendee."Amount Paid" <> 0` or `Attendee."Bootcamp No." = ''`; **also exits if
   `Bootcamp.Get(Attendee."Bootcamp No.")` fails** (as-built guard, not in the original plan —
   G-10, Step 08: strictly better, avoids an error on a dangling link, code is right as
   written); otherwise sets `Attendee. "Amount Paid" := Bootcamp."Price"`.
   **Corrected at Step 09 (`CodeReview.md` BP-1): called ONLY from `OnValidate("Bootcamp No.")` —
   the `OnInsert` call was removed.** The original design called it from both `OnInsert` and
   `OnValidate("Bootcamp No.")`, using `Amount Paid <> 0` as the "already seeded" guard — but `0`
   is also a legitimate value (a comped/free registration), and the code couldn't tell "not yet
   supplied" from "deliberately zero." A user or API caller who explicitly entered `0` for a comp
   had it silently re-billed to the bootcamp's Price on `OnInsert`. Seeding now happens exactly
   once, at the moment the bootcamp is selected, and never again — the sentinel-collision class
   of bug is removed structurally rather than patched around. **This required a second fix in the
   same pass:** `ocpfAttendeeSubform`'s `OnNewRecord` previously set `"Bootcamp No."` via a plain
   field assignment, which never fires `OnValidate` at all — the normal subform registration flow
   would have stopped seeding Amount Paid entirely once the `OnInsert` call was removed. Changed
   to `Rec.Validate("Bootcamp No.", ...)` (guarded on a non-blank filter, matching the prior
   behavior on a blank one) so the seed still fires on the one path that matters most. Verified
   the API page (`ocpfAttendees`) declares `bootcampNo` before `amountPaid` in field order, so an
   explicit `amountPaid: 0` in a POST body is still processed *after* the seed and correctly wins.
   A user/API value — including an explicit 0 that stays 0 — is never overwritten. Documented
   edge, unchanged: a genuine free (0) registration will re-seed to Price if the bootcamp is later
   changed while Amount Paid is still 0; acceptable, noted for the user guide.
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
    removes the Guided Experience item registered by AppId on uninstall (N-6). Verification is
    a named Step 12 test case (renumbered from the pre-restructure "Step 09" this note
    originally cited) — if it shows an orphan, add `OnUninstall` calling
    `GuidedExperience.Remove(...)`.
12. **Page-level `ToolTip` removed from bound fields that duplicate their table field's own,
    project-wide (Step 09, `CodeReview.md` R-1).** From runtime 13.0/BC24 onward (this project
    targets 17.0), a page field bound to a table field inherits that field's `ToolTip`
    automatically — a page-level copy is pure duplicate-maintenance, and by Step 09 five had
    already drifted from the table's own wording (see §6.18's note for two examples). Cleaned up
    across `ocpfBootcampList`, `ocpfBootcampCard`, `ocpfAttendeeList`, `ocpfAttendeeSubform`, and
    the `ocpfO365ActivitiesExt` cuegroup fields. **Rule going forward:** a page-level `ToolTip`
    override is only for a field genuinely worded differently for that specific page context —
    not the default for every bound field.

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
**(both added in Batch 3 when the List page exists — ChangeLog BUILD-04)**

| id | field | type | properties / behavior |
|---|---|---|---|
| 1 | `No.` | `Code[20]` | `OnValidate`: if `Rec."No." <> xRec."No."` then `ocpfBootcampRegMgt.TestBootcampManualNo()` and `Rec."No. Series" := ''`. |
| 2 | `No. Series` | `Code[20]` | `Editable = false`; `TableRelation = "No. Series"`. |
| 3 | `Topic` | `Text[100]` | free text. |
| 4 | `Location` | `Text[100]` | free text (venue/city) — **not** linked to `Location` T14. |
| 5 | `Bootcamp Date` | `Date` | single day. |
| 6 | `Price` | `Decimal` | `AutoFormatType = 1`; `MinValue = 0`. |
| 7 | `Max Seats` | `Integer` | `MinValue = 0`; `OnValidate` (only if `Rec."No." <> ''`): `Rec.CalcFields("Registered Attendees"); Rec."Seats Remaining" := Rec."Max Seats" - Rec."Registered Attendees";` — computed **in memory on `Rec` itself**. **Corrected at Step 08 (`GapAnalysis.md` G-12):** the original rule called `ocpfBootcampRegMgt.UpdateSeatsRemaining(Rec."No.")`, which re-`Get()`s the same record from the database and `Modify()`s a separate copy — that read is stale (the page/API's own write for the field just validated hasn't committed yet) and gets silently overwritten by the caller's own subsequent save. `UpdateSeatsRemaining` is still correct and still used, but only from the four `ocpfAttendee` event subscribers (§6.5), where reading already-committed state is correct. |
| 8 | `Min Seats` | `Integer` | `Caption = 'Min Seats (Go/No-Go)'`; `MinValue = 0`. Informational only. |
| 9 | `Registered Attendees` | `Integer` | `FieldClass = FlowField`; `CalcFormula = count("ocpfAttendee" where("Bootcamp No." = field("No.")))`; `Editable = false`. |
| 10 | `Seats Remaining` | `Integer` | `Editable = false`. Maintained by field 7's own `OnValidate` (in memory, see above) and by `UpdateSeatsRemaining` from the Attendee-side subscribers (§4.3, §6.5). Not a FlowField. |
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
**(both added in Batch 3 when the List page exists — ChangeLog BUILD-04)**

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
- `OnInsert`: `Rec.TestField("Bootcamp No.")` (ChangeLog BUILD-16 — fail loudly on a genuinely
  blank link instead of silently saving a corrupt orphan row); if `Rec."No." = ''` then
  `ocpfBootcampRegMgt.InitAttendeeNo(Rec)`; `ocpfBootcampRegMgt.SeedAmountPaid(Rec)`;
  `ocpfBootcampRegMgt.ConfirmOverbookingIfNeeded(Rec)`.
- `OnModify`, `OnDelete`, `OnRename`: none on the table itself — seat maintenance is done by the
  subscribers in `ocpfBootcampRegMgt` (§4.3) so it always runs on committed state, including
  for API and direct writes.

### 6.5 codeunit 60813 `ocpfBootcampRegMgt`

`using Microsoft.Foundation.NoSeries;` · `SingleInstance = false` · no `Subtype` (normal).

Procedures:

| Procedure | Body summary |
|---|---|
| `InitBootcampNo(var Bootcamp: Record "ocpfBootcamp")` | `GetSetup(); Setup.TestField("Bootcamp Nos."); Bootcamp."No. Series" := Setup."Bootcamp Nos."; Bootcamp."No." := NoSeries.GetNextNo(Setup."Bootcamp Nos.");` — plain assignment. (BUILD-13 added a self-healing retry loop here on a wrong diagnosis of the sample-bootcamp collision bug; reverted by BUILD-16 once the real cause — `Record.Init()` not clearing the primary key in `CreateSampleBootcamps`, §6.14 — was found. `InitBootcampNo` was never the problem.) |
| `InitAttendeeNo(var Attendee: Record "ocpfAttendee")` | analogous with `Setup."Attendee Nos."`. |
| `TestBootcampManualNo()` | `GetSetup(); NoSeries.TestManual(Setup."Bootcamp Nos.");` |
| `TestAttendeeManualNo()` | `GetSetup(); NoSeries.TestManual(Setup."Attendee Nos.");` |
| `SeedAmountPaid(var Attendee: Record "ocpfAttendee")` | per §4.7. |
| `ConfirmOverbookingIfNeeded(var Attendee: Record "ocpfAttendee")` | per §4.5. **`Max Seats <= 0` ⇒ no cap, return without warning** (ChangeLog BUILD-04). `OverbookingQst: Label 'Bootcamp %1 is full (%2 of %3 seats used). Register %4 anyway?', Comment='%1=Bootcamp No.,%2=used,%3=Max Seats,%4=Attendee name';` |
| `UpdateSeatsRemaining(BootcampNo: Code[20])` | per §4.3. `if BootcampNo = '' then exit; if not Bootcamp.Get(BootcampNo) then exit; Bootcamp.CalcFields("Registered Attendees"); Bootcamp."Seats Remaining" := Bootcamp."Max Seats" - Bootcamp."Registered Attendees"; Bootcamp.Modify(false);` |
| `GetSetup()` (local) | `if SetupLoaded then exit; if not Setup.Get() then begin Setup.Init(); Setup.Insert(); end; SetupLoaded := true;` |

Event subscribers (in the same codeunit):

| Subscriber | Event | Action |
|---|---|---|
| `OnAfterInsertAttendee` | `Database::"ocpfAttendee", OnAfterInsertEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` |
| `OnAfterModifyAttendee` | `..., OnAfterModifyEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No."); if xRec."Bootcamp No." <> Rec."Bootcamp No." then UpdateSeatsRemaining(xRec."Bootcamp No.")` |
| `OnAfterDeleteAttendee` | `..., OnAfterDeleteEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` |
| `OnAfterRenameAttendee` | `..., OnAfterRenameEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` (No. rename only; bootcamp unchanged — cheap, harmless) |

Variables: `Setup: Record "ocpfBootcampRegSetup"; NoSeries: Codeunit "No. Series";
SetupLoaded: Boolean;` — `Bootcamp: Record "ocpfBootcamp"` is now a **local** var in
`SeedAmountPaid`, `ConfirmOverbookingIfNeeded`, `UpdateSeatsRemaining` (no shared scratch state;
avoids the AA0244 name clash with the `var Bootcamp` parameter — ChangeLog BUILD-04).

> All procedures and all four subscribers are delivered in **Batch 2** together with both core
> tables (Sanity Check S-7). Each subscriber opens with `if Rec.IsTemporary() then exit;`
> (ChangeLog BUILD-04) so seat maintenance never fires against temporary records.

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
Fields: `Bootcamp No.` (`Visible = false` — see below), `Name`, `Email Address`, `Phone Number`,
`Company`, `Customer No.`, `Paid`, `Payment Date`, `Amount Paid`, `Attended`.

**`field("Bootcamp No."; Rec."Bootcamp No.") { Visible = false; }`** (ChangeLog BUILD-16): the
link field is now an actual (hidden) control on the subform, matching the standard BC pattern for
a `SubPageLink`-driven line subform (e.g. `Job Task Lines Subform`, which always carries its own
link field, just hidden) rather than relying on `SubPageLink` alone with no corresponding control.

**`trigger OnNewRecord(BelowxRec: Boolean)`** (ChangeLog BUILD-12, corrected by BUILD-16): the
original BUILD-12 version read `Rec.GetFilter("Bootcamp No.")` without switching filter groups
first — a provable no-op, since `SubPageLink` filters live in filter group 4 ("Link"), not the
default group 0 that a plain `GetFilter` reads (verified against Microsoft Learn's
`Record.FilterGroup()` reference). Corrected version switches to group 4, reads the filter, then
restores the previous group before assigning. Any future `ListPart` subform in this project with
a non-key `SubPageLink` field that needs to read the link value in code must do the same —
`GetFilter` alone, without `FilterGroup(4)` first, will silently return blank.

**Corrected at Step 09 (`CodeReview.md` BP-1):** the final assignment is now
`Rec.Validate("Bootcamp No.", CopyStr(BootcampNoFilter, 1, MaxStrLen(Rec."Bootcamp No.")))`,
guarded on `BootcampNoFilter <> ''` — not a plain field assignment. A plain assignment never
fires the field's `OnValidate`, so it silently skipped Amount Paid seeding once that seeding was
consolidated onto `OnValidate("Bootcamp No.")` alone (see §4.7). A blank filter is still left
blank exactly as before (no-op either way); `OnInsert`'s `TestField` still catches that case
loudly.

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
**Navigation, as actually built (corrected at Step 08, `GapAnalysis.md` G-08 — the original plan
below was never implemented and the running system was live-tested end-to-end at BUILD-21):**
three hand-written `action(ActionBack)` / `action(ActionNext)` / `action(ActionFinish)` in
`area(Navigation)`, `InFooterBar = true`, with `Enabled` bindings driven by the `Step` variable —
not the standard NavigatePage `actionref`/`SystemActions` pattern originally planned. Only the
`Finish` action exists (no separate `OnQueryClosePage` handler); a mid-wizard cancel leaves the
Setup record untouched because all persistence happens in `Finish` alone.
`Finish` action:
- `Rec.Modify(true)` (persist the two series).
- If `CreateSamplesVar` then `CreateSampleBootcamps()` — inserts 2 `ocpfBootcamp` rows
  (e.g. "AL Extension Development", "Business Central for Consultants"), dates ~30/60 days out,
  `Price := 1500`, `Max Seats := 20`, `Min Seats := 6`. **`Status` and `Location` are left to the
  field's own `InitValue`/blank rather than set explicitly** (G-09 — same outcome, no functional
  difference). Uses normal `Bootcamp.Insert(true)` so numbering fires. **`Bootcamp."No." := '';`
  immediately after each `Bootcamp.Init()` call, before setting the other fields** (ChangeLog
  BUILD-16) — `Init()` does not clear primary key fields (Microsoft Learn, `Record.Init()`,
  verbatim: "Primary key and timestamp fields aren't initialized"), so reusing one record
  variable for both inserts without this explicit clear leaves the second insert holding the
  first insert's already-assigned `No.`, skipping `InitBootcampNo` entirely and colliding on the
  primary key. Any future procedure that inserts more than one row from a reused record variable
  in this project must clear the key the same way.
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
        action(ocpfAttendeeListAction)      { RunObject = page "ocpfAttendeeList"; Caption='Bootcamp Attendees'; ApplicationArea=All; Image=ContactPerson; ToolTip='Open the list of bootcamp attendees.'; }
        action(ocpfBootcampSetupAction)     { RunObject = page "ocpfBootcampRegSetup"; Caption='Bootcamp Registration Setup'; ApplicationArea=All; Image=Setup; ToolTip='Open the Bootcamp Registration Setup.'; }
    }
}
```
`addlast(sections)` targets `area(sections)` (confirmed present at page 9022 line 457, Sanity
S-1) and avoids any dependency on internal control names. **`Image=ContactPerson`, corrected at
Step 08 (`GapAnalysis.md` G-07)** — this section previously still showed the original planned
value `Image=Persons`, which ChangeLog BUILD-07 records as invalid (`AL0482`, two names tried
before `ContactPerson` compiled) but had marked "Updated: TDD — no"; a developer regenerating
from this document alone would have reproduced that same compile error.

### 6.16 permissionset 60890 `OCPF - Bootcamp Read`

`Assignable = true` · `Caption = 'OCPF - Bootcamp Read'`. **Shipped in Batch 1** (ChangeLog
BUILD-02); `tabledata` lines added as each batch introduces its table — final state:
```
Permissions =
    tabledata "ocpfBootcamp" = R,
    tabledata "ocpfAttendee" = R,
    tabledata "ocpfBootcampRegSetup" = R,
    page "ocpfBootcampRegSetup" = X,
    page "ocpfBootcampList" = X,
    page "ocpfBootcampCard" = X,
    page "ocpfAttendeeList" = X,
    page "ocpfAttendeeSubform" = X,
    page "ocpfBootcampRegSetupWizard" = X,
    page "ocpfBootcamps" = X,
    page "ocpfAttendees" = X;
```
**Object-execute grants added at Step 09 (`CodeReview.md` SC-1) — this closes Step 08's deferred
G-04.** The original plan noted "objects are covered by `InherentPermissions`/execution; tabledata
is the controlling grant" and deferred adding explicit `page … = X` lines to "if Step 09 shows
page-execution gaps." Step 09's Code Review treated that as unverified in either direction rather
than assumed safe, and added explicit execute grants on all 8 of this extension's own pages
defensively, per Standards §7.3's literal requirement ("read-only set grants execute on all
pages"). Pageextensions (`ocpfBusinessMgrRCExt`, `ocpfO365ActivitiesExt`) and the tableextension
(`ocpfActivitiesCueExt`) need no grant of their own — they ride on the base object's own standard
permission coverage. **Still to verify live** (named Step 09/12 test case, not a silent
assumption): confirm with a non-SUPER user assigned only this set that every page actually opens.

### 6.17 permissionset 60891 `OCPF - Bootcamp Edit`

`Assignable = true` · `Caption = 'OCPF - Bootcamp Edit'` ·
`IncludedPermissionSets = "OCPF - Bootcamp Read"`. **Shipped in Batch 1** (ChangeLog BUILD-02);
`tabledata` lines grown per batch — final state:
```
Permissions =
    tabledata "ocpfBootcamp" = IMD,
    tabledata "ocpfAttendee" = IMD,
    tabledata "ocpfBootcampRegSetup" = IMD;
```
Inherits all 8 page execute grants from the included Read set (§6.16) — no separate execute
grants needed here.

### 6.18 tableextension 60842 `ocpfActivitiesCueExt`

**Gap-fill (ChangeLog BUILD-09), folded in at Step 08 (G-01).** `extends "Activities Cue"`
(table 1313, `Microsoft.RoleCenters`). Five new fields, IDs 60800–60804 — a separate ID space
scoped to table 1313 (not the project's own 60800–60899 object range; chosen to match this
project's numeric identity, no collision with 1313's own fields which top out at 110):

| id | field | type | behavior |
|---|---|---|---|
| 60800 | `OCPF Active Bootcamps` | Integer | FlowField, `count("ocpfBootcamp" where(Status = const(Active)))` |
| 60801 | `OCPF Unpaid Registrations` | Integer | FlowField, `count("ocpfAttendee" where(Paid = const(false)))` |
| 60802 | `OCPF Below Min Seats` | Integer | Plain, computed by `ocpfActivityCueMgt.UpdateCues` (`Registered Attendees < Min Seats` on `Status = Active` bootcamps — field-to-field, not FlowField-expressible; **no date filter**, so a past-dated Active bootcamp still counts) |
| 60803 | `OCPF Registrations This Month` | Integer | Plain, computed by `UpdateCues` (proxy: `SystemCreatedAt` in the current calendar month — no explicit registration-date field exists) |
| 60804 | `OCPF Revenue This Month` | Decimal | Plain, computed by `UpdateCues` (sum of `Amount Paid` where `Paid = true` **and** `Payment Date` in the current month — paid-this-month, not registered-this-month) |

All five carry `Caption` + `ToolTip` (added at Step 08 — G-13; the original gap-fill batch ran
no Step 05 pre-flight pass, which is how the ToolTips were missed the first time). **Corrected at
Step 09 (`CodeReview.md` CQ-2):** the 60802 and 60804 ToolTips originally described behavior the
code didn't implement — 60802 said "active, **upcoming**" (no such filter exists) and 60804 said
"attendees **registered** this month" (the code actually filters on **paid** date, not
registration date) — both reworded to match the table above exactly. **Also added at Step 09
(`CodeReview.md` BP-5):** `DataClassification = CustomerContent` on the three plain fields
(60802–60804) — a `tableextension` has no table-level classification to inherit, so each Normal
field it adds must set its own; without one they ship as `ToBeClassified`. The two FlowFields
(60800/60801) need none. **Also at Step 09 (R-1):** the page-level `ToolTip`s on the matching
`cuegroup` fields in §6.20 were removed — a bound page field inherits its table field's `ToolTip`
from runtime 13.0/BC24 onward (this project targets 17.0), so the page-level copies were pure
duplication, and two of them had already drifted from the table's own wording before this fix.

### 6.19 codeunit 60843 `ocpfActivityCueMgt`

**Gap-fill (BUILD-09), folded in at Step 08.** One public procedure, `UpdateCues`, plus three
local calculation procedures (one per plain field above). Called from the pageextension's
`OnAfterGetRecord` (§6.20) — i.e., recomputed on every Role Center refresh, not cached. No
permission-set entry needed: `Activities Cue` is already readable by every user since it drives
their own Role Center (confirmed by a clean compile, not assumed — `PTE0004` doesn't apply to a
`tableextension`, which introduces no new table).

### 6.20 pageextension 60844 `ocpfO365ActivitiesExt`

**Gap-fill (BUILD-09), folded in at Step 08.** `extends "O365 Activities"` (page 1310, global —
no namespace). Adds a `cuegroup` via `addlast(content)` surfacing the five fields from §6.18
(caption-only page-level metadata now — see §6.18's own ToolTip-inheritance note); the
`cuegroup`'s own trigger structure was revised at Step 09 (below).

**Permission guard added at Step 09 (`CodeReview.md` BP-3) — closes Step 08's deferred G-14, and
is bigger than that item assumed.** G-14 proposed a guard inside `UpdateCues` alone
(`if not Bootcamp.ReadPermission() then exit;`). That would not have been sufficient: fields
60800/60801 (§6.18) are **FlowFields**, calculated by the platform when the `cuegroup` renders —
not through `UpdateCues` at all — so a codeunit-only guard would leave two of the five cues still
touching tables a user without `OCPF - Bootcamp Read` can't read. Fixed at the `cuegroup` level
instead:
```al
cuegroup(ocpfBootcamps)
{
    Visible = OcpfCuesVisible;
    ...
}

trigger OnOpenPage()
var
    Bootcamp: Record "ocpfBootcamp";
begin
    OcpfCuesVisible := Bootcamp.ReadPermission();
end;

trigger OnAfterGetRecord()
begin
    if OcpfCuesVisible then
        ActivityCueMgt.UpdateCues(Rec);
end;
```
One `Boolean`, computed once in `OnOpenPage`, covers both the FlowField cues (via `Visible`) and
the plain-field cues (via the `UpdateCues` guard) in a single place. **Still to verify live**
(named Step 09/12 test case, not a silent assumption): assign a test user only `OCPF - Bootcamp
Read` or neither OCPF set, open the Business Manager Role Center, confirm the cuegroup is hidden
and no error surfaces.

**Investigation basis (verified against symbols, Standards §10.5):** `page 9022 "Business
Manager Role Center"` already renders cues via `part(Control16; "O365 Activities")` bound to
table 1313. Microsoft's own `ActivitiesCue.Table.al`/`O365Activities.Page.al` confirm
date-relative cues are **plain stored fields recomputed on page open**, not FlowFields with
date-relative FlowFilters (`CalcFormula` can't reference a runtime-relative date like Today).
Microsoft's own implementation adds page-background-task caching on top of that at their scale —
deliberately not replicated here; this app's data volume doesn't need it.

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
    APIPublisher = 'onlyCopilotFans';           // camelCase — AA0101 (ChangeLog BUILD-06)
    APIGroup = 'ocpfBootcampRegistration';      // camelCase, no separator — AA0101 (ChangeLog BUILD-06)
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
| F-16 Role Center Activity Cues (gap-fill BUILD-09, folded in at Step 08) | 60842/60843/60844, §2.1 |
| D-1…D-15 | §1, §5, §9, §10 |
| N-1…N-9 | §9.4, §10, §7, §4.5 |

---

**Exit gate (Step 03):** Technical Lead sign-off. Self-sufficiency check: no rule here requires
knowledge outside this document + `ProjectParameters.md` + the named symbol files.

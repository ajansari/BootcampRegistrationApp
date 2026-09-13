# Post-Development Technical Design Document — Bootcamp Registration Tracking (BC PTE)

**Phase:** PROVE · **Step:** 10 · **Status:** As-built reference
**Date:** 2026-09-13 · **Author:** Claude (agent), for AJ Ansari

> **What this is.** This document reflects the extension **as actually implemented** at
> `0.0.5.1`, after BUILD (Steps 05–07), Step 08 (Gap-Fit Test), and Step 09 (Code Review) all
> found and corrected real issues in the original design. It states the *current, final* rule for
> everything — not the history of how each rule got there. For that history, see §12 (Deviation
> Summary) and `docs/ChangeLog.md`, which remains the ground truth for *why*.
>
> **Self-sufficiency claim (Standards §2.3), re-verified as-built:** every object in this
> extension can be reproduced correctly from this document alone. Every value, property, and
> trigger body below was read directly from the shipped `.al` files on 2026-09-13, not carried
> forward from the original `TDD.md` narrative.
>
> **Relationship to the original `TDD.md`:** that document is retained, unmodified, as historical
> design context and as the artifact the code was originally generated from (runbook Step 10
> rationale). It already carries most of the same corrections inline, as "corrected at Step
> 08/09" annotations — this document restates the same facts as clean, final rules, with the
> annotation narrative moved to §12.

---

## 1. System identity (as shipped)

| Item | Value |
|---|---|
| Publisher | `OnlyCopilotFans` |
| Extension name | `Bootcamp Registration Tracking` |
| Namespace (every object) | `OCPF.BootcampRegistration` |
| AL object prefix | `ocpf` |
| APIPublisher | `'onlyCopilotFans'` (camelCase — a deliberate AA0101 divergence from Standards §1.3's literal `'<Publisher>'` example; AJ's call, ChangeLog BUILD-06) |
| APIGroup | `'ocpfBootcampRegistration'` (camelCase, no `<prefix>_` separator — same AA0101 divergence, ChangeLog BUILD-06) |
| APIVersion | `'v1.0'` |
| Permission Set Prefix | `OCPF - ` |
| Object ID range | 60800–60899 (100 IDs), no additional ranges |
| AL runtime | 17.0 |
| BC application minimum | 28.0.0.0 |
| Feature | `NoImplicitWith` (enforced) — every field reference `Rec.`-qualified |
| Deployment target | SaaS PTE |
| Version at this writing | `0.0.5.1` (see `outputAppPackage/`) |

## 2. Final object inventory

**20 objects built** (17 originally planned + 3 gap-fill Activity Cue objects, ChangeLog
BUILD-09). All compile at **0 errors / 0 warnings**. Source: `docs/ObjectRegister.md`.

| ID | Type | Name | Module | Source table | R/W | Status |
|---|---|---|---|---|---|---|
| 60800 | enum | `ocpfBootcampStatus` | M1 | — | — | built |
| 60801 | table | `ocpfBootcampRegSetup` | M1 | new | RW (in-client) | built |
| 60802 | page (Card) | `ocpfBootcampRegSetup` | M1 | 60801 | RW | built |
| 60803 | codeunit (Install) | `ocpfBootcampRegInstall` | M1 | — | — | built |
| 60810 | table | `ocpfBootcamp` | M2 | new | RW | built |
| 60811 | page (List) | `ocpfBootcampList` | M2 | 60810 | RW | built |
| 60812 | page (Card) | `ocpfBootcampCard` | M2 | 60810 | RW | built |
| 60813 | codeunit | `ocpfBootcampRegMgt` | M2 | — | — | built |
| 60820 | table | `ocpfAttendee` | M3 | new | RW | built |
| 60821 | page (List) | `ocpfAttendeeList` | M3 | 60820 | RW | built |
| 60822 | page (ListPart) | `ocpfAttendeeSubform` | M3 | 60820 | RW | built |
| 60830 | page (API) | `ocpfBootcamps` | M4 | 60810 | RW | built |
| 60831 | page (API) | `ocpfAttendees` | M4 | 60820 | RW | built |
| 60840 | page (NavigatePage) | `ocpfBootcampRegSetupWizard` | M5 | 60801 | RW | built |
| 60841 | pageextension | `ocpfBusinessMgrRCExt` | M5 | extends page 9022 | — | built |
| 60842 | tableextension | `ocpfActivitiesCueExt` | M5 (gap-fill) | extends table 1313 | — | built |
| 60843 | codeunit | `ocpfActivityCueMgt` | M5 (gap-fill) | — | — | built |
| 60844 | pageextension | `ocpfO365ActivitiesExt` | M5 (gap-fill) | extends page 1310 | — | built |
| 60890 | permissionset | `OCPF - Bootcamp Read` | perms | — | R | built (3 tables + 8 own pages) |
| 60891 | permissionset | `OCPF - Bootcamp Edit` | perms | — | RIMD | built (3 tables; pages inherited) |

Free IDs remaining: 60804–60809, 60814–60819, 60823–60829, 60832–60839, 60845–60889, 60892–60899.

## 3. Special design notes (final rules, generalizable beyond this project)

1. **Singleton Setup (`ocpfBootcampRegSetup`).** Blank `Code[10]` primary key; exactly one record.
   `ocpfBootcampRegInstall` inserts it on install; the Setup page and the wizard both self-heal
   (`if not Rec.Get() then begin Rec.Init(); Rec.Insert(); end;`).
2. **Table/Page name reuse is deliberate.** `table 60801` and `page 60802` are both named
   `"ocpfBootcampRegSetup"`, mirroring standard BC (`table 98` / `page 118` "General Ledger
   Setup").
3. **Seats Remaining is a stored field, not a FlowField** — AL `FlowField` `CalcFormula` has no
   subtraction operator. Final design:
   - `ocpfBootcamp."Registered Attendees"` — FlowField, `count("ocpfAttendee"
     where("Bootcamp No." = field("No.")))`, read-only. Live.
   - `ocpfBootcamp."Seats Remaining"` — plain `Integer`, read-only, maintained through one shared
     table procedure, `CalcSeatsRemaining()`:
     ```al
     procedure CalcSeatsRemaining(): Integer
     begin
         if Rec."Max Seats" <= 0 then
             exit(0);
         exit(Rec."Max Seats" - Rec."Registered Attendees");
     end;
     ```
     `Max Seats <= 0` ("no cap", F-10) always yields `0`, never a negative number.
   - **Two call sites, by design, never interchangeable:**
     - From `ocpfAttendee`'s own event subscribers (a registration was added/changed/removed),
       via `ocpfBootcampRegMgt.UpdateSeatsRemaining(BootcampNo)`: `Bootcamp.Get(BootcampNo);
       Bootcamp.CalcFields("Registered Attendees"); Bootcamp."Seats Remaining" :=
       Bootcamp.CalcSeatsRemaining(); Bootcamp.Modify(false);`. Correct here because the attendee
       change is already committed by the time these subscribers run.
     - From `ocpfBootcamp."Max Seats".OnValidate` (the seat cap itself changed): computed **in
       memory, directly on `Rec`** — `Rec.CalcFields("Registered Attendees"); Rec."Seats
       Remaining" := Rec.CalcSeatsRemaining();` — guarded on `Rec."No." <> ''`. **Never** call
       `UpdateSeatsRemaining` from inside a table's own `OnValidate`: that trigger runs *before*
       the page/API's own pending write for the field just validated is committed, so a
       `Get()`/`Modify()` pair there reads a stale row and is then silently overwritten by the
       caller's own subsequent save. **Generalizable rule: never recompute a stored field by
       re-`Get()`-ing the same record from the database inside its own `OnValidate` — write
       directly to `Rec` instead.**
   - **`xRec` reliability inside `OnAfterModifyEvent`.** `xRec` in a table trigger is only a true
     before-image when the change came from a page — a code- or API-driven `Modify()` leaves
     `xRec` equal to `Rec`. A `"did this key field change?"` comparison (here: did
     `"Bootcamp No."` change, so the *old* bootcamp's seat count also needs updating) silently
     never fires on that path unless guarded against. Fixed with a companion
     `OnBeforeModifyEvent` subscriber:
     ```al
     [EventSubscriber(ObjectType::Table, Database::"ocpfAttendee", 'OnBeforeModifyEvent', '', false, false)]
     local procedure OnBeforeModifyAttendee(var Rec: Record "ocpfAttendee"; var xRec: Record "ocpfAttendee"; RunTrigger: Boolean)
     begin
         if Rec.IsTemporary() then
             exit;
         xRec.Get(xRec."No.");
     end;
     ```
     Refreshing `xRec` from the database before the write commits carries the real prior row
     through to every subsequent `OnAfterModifyEvent` subscriber, regardless of caller. Verified
     against multiple independent sources (Microsoft's own `OnAfterModifyEvent` reference page
     doesn't document this). **Generalizable rule: never trust `xRec` for a "did this key field
     change?" check without first confirming the record can only ever be modified from a page —
     refresh it defensively otherwise.**
   - Deterministic: every mutation path recomputes from the authoritative count.
4. **Two top-level API entities**, not a nested API. `ocpfBootcamps` and `ocpfAttendees` are
   separate API pages; `ocpfAttendees` carries `bootcampNo` as a writable field so an integration
   can create a registration by supplying the parent number directly. No `API` subpage.
5. **Max Seats — warn but allow (F-10).** `ocpfAttendee.OnInsert` calls
   `ocpfBootcampRegMgt.ConfirmOverbookingIfNeeded(Rec)`: if adding this attendee would exceed
   `Max Seats` **and** `GuiAllowed`, show a confirm; declining raises a silent `Error('')`. When
   `not GuiAllowed` (API), proceed silently. `Max Seats <= 0` ⇒ no cap, never warns. Never a hard
   block.
6. **Bootcamp delete — block (F-11, D-11).** `ocpfBootcamp.OnDelete` errors with an actionable
   message if any `ocpfAttendee` still references it.
7. **Amount Paid seeding (D-9) — seeded exactly once, at bootcamp selection, never re-seeded.**
   `ocpfAttendee."Bootcamp No.".OnValidate` is the *only* call site for
   `ocpfBootcampRegMgt.SeedAmountPaid(Rec)`. `SeedAmountPaid` exits without changing anything if
   `Attendee."Amount Paid" <> 0`, if `"Bootcamp No." = ''`, or if the bootcamp can't be found;
   otherwise sets `Amount Paid := Bootcamp.Price`. There is **no** seeding call in `OnInsert`.
   **Why this shape, not "seed if Amount Paid = 0" on every insert (the original design):** `0`
   is also a legitimate value — a comped/free registration — and code can't distinguish "not yet
   supplied" from "deliberately zero" using the field's own value alone. Seeding exactly once, at
   the one moment a value is genuinely being chosen for the first time, removes the
   sentinel-collision class of bug structurally instead of patching around it. A user or API
   value — including an explicit `0` that stays `0` — is never overwritten afterward. Documented
   edge case, accepted: a genuine free (`0`) registration re-seeds to Price if the bootcamp
   selection is changed again while Amount Paid is still `0` (unusual — Amount Paid is normally
   touched once a comp is decided). The API page declares `bootcampNo` before `amountPaid` in
   field order, so an explicit `amountPaid: 0` in a POST body is processed *after* the seed and
   correctly wins.
   **Consequence for any UI that sets `"Bootcamp No."` in code:** it must call
   `Rec.Validate("Bootcamp No.", ...)`, never a plain field assignment — a plain assignment never
   fires `OnValidate` and would silently skip Amount Paid seeding on that path. This project's
   subform (`ocpfAttendeeSubform.OnNewRecord`) does this correctly; see §5.11.
8. **`SourceTableView` / `const()` quoting** — N/A. No document-type-filtered pages exist in this
   design (the Attendee subform uses `SubPageLink`, not `SourceTableView`).
9. **FlowField key.** `ocpfAttendee` declares `key(BootcampNo; "Bootcamp No.")` to back the
   `Registered Attendees` count and the delete-guard `SetRange`.
10. **Email validation (D-13).** `ocpfAttendee."Email Address"` uses `ExtendedDatatype = EMail`
    plus a dependency-free `OnValidate`: non-blank values must contain exactly one `@`, no
    spaces, and a `.` after the `@`. No external codeunit dependency.
11. **`SubPageLink` filters live in filter group 4 ("Link"), not the default group 0.** A plain
    `Rec.GetFilter("Bootcamp No.")` on the Attendee subform silently returns blank — it must
    switch to `FilterGroup(4)` first, read the filter, then restore the previous group. Verified
    against Microsoft Learn's `Record.FilterGroup()` reference. See §5.11 for the exact code.
    **Generalizable rule: any `ListPart` subform with a non-key `SubPageLink` field that needs to
    read the link value in code must switch to filter group 4 first — `GetFilter` alone will
    silently return blank.**
12. **`Record.Init()` does not clear primary key fields.** Confirmed against Microsoft Learn
    (`Record.Init()`, verbatim: "Primary key and timestamp fields aren't initialized"). Any
    procedure that inserts more than one row from a reused record variable in this project must
    explicitly clear the key field(s) after `Init()` before setting other fields — see
    `CreateSampleBootcamps()` in §5.14 for the applied pattern.
13. **Uninstall.** `ocpfBootcampRegInstall` has no explicit uninstall logic; the platform is
    expected to remove the Guided Experience item it registered, by AppId, on uninstall. Not yet
    live-verified — a named Step 12 test case. If it shows an orphan, add `OnUninstall` calling
    `GuidedExperience.Remove(...)`.
14. **Page-level `ToolTip` is never added to a bound field that only repeats its table field's
    own.** From runtime 13.0/BC24 onward (this project targets 17.0), a page field bound to a
    table field inherits that field's `ToolTip` automatically — a page-level copy is pure
    duplicate-maintenance, and several had already drifted from the table's own wording before
    this was caught. A page-level `ToolTip` override is only for a field genuinely worded
    differently for that specific page context.
15. **Role Center Activity Cue visibility must guard the `cuegroup`'s own `Visible`, not only the
    codeunit that computes plain cue values.** Two of the five Activity Cue fields are FlowFields,
    calculated by the platform at render time — a permission guard placed only inside the
    computing codeunit misses them entirely. See §5.20 for the applied guard.

## 4. Standard objects referenced (verified against BC v28.4 symbol files)

| Object | Kind / No. | `using` namespace | Used by |
|---|---|---|---|
| `No. Series` | table 308 | `Microsoft.Foundation.NoSeries` | 60801, 60810, 60820, 60813 |
| `No. Series` | codeunit 310 | `Microsoft.Foundation.NoSeries` | 60813 |
| `No. Series Line` | table 309 | `Microsoft.Foundation.NoSeries` | (indirect via codeunit 310) |
| `Customer` | table 18 | `Microsoft.Sales.Customer` | 60820 |
| `Guided Experience` | codeunit 1990 | `System.Environment.Configuration` | 60803 |
| `Assisted Setup Group` | enum 1815 | `System.Environment.Configuration` | 60803 (value `Extensions`) |
| `Video Category` | enum 3710 | `System.Media` | 60803 (value `Uncategorized`) |
| `Guided Experience Type` | enum | `System.Environment.Configuration` | 60803 (value `"Assisted Setup"`) |
| `Business Manager Role Center` | page 9022 | `Microsoft.Finance.RoleCenters` | 60841 — extended, `addlast(sections)` |
| `Activities Cue` | table 1313 | `Microsoft.RoleCenters` | 60842 — extended, 5 new fields |
| `O365 Activities` | page 1310 | *(global, no namespace)* | 60844 — extended, `addlast(content)` |

## 5. Per-object specification (as shipped)

### 5.1 enum 60800 `ocpfBootcampStatus`

Non-extensible. Values: `Active` (0, default), `Inactive` (1), `Completed` (2), `Canceled` (3).
No code ever changes an existing bootcamp's status.

### 5.2 table 60801 `ocpfBootcampRegSetup`

`DataClassification = CustomerContent` · `Caption = 'Bootcamp Registration Setup'`. Fields:
`Primary Key` (Code[10]), `Bootcamp Nos.` (Code[20], `TableRelation = "No. Series"`),
`Attendee Nos.` (Code[20], `TableRelation = "No. Series"`). Key: `PK` on `Primary Key`,
clustered. No triggers; not user-deletable.

### 5.3 table 60810 `ocpfBootcamp`

`DataClassification = CustomerContent` · `Caption = 'Bootcamp'` ·
`LookupPageId = "ocpfBootcampList"` · `DrillDownPageId = "ocpfBootcampList"`.

| id | field | type | behavior |
|---|---|---|---|
| 1 | `No.` | Code[20] | `OnValidate`: if changed, `BootcampRegMgt.TestBootcampManualNo()`, clears `"No. Series"`. |
| 2 | `No. Series` | Code[20] | Read-only; `TableRelation = "No. Series"`. |
| 3 | `Topic` | Text[100] | free text |
| 4 | `Location` | Text[100] | free text; not linked to warehouse Location |
| 5 | `Bootcamp Date` | Date | single day |
| 6 | `Price` | Decimal | `AutoFormatType = 1`; `MinValue = 0` |
| 7 | `Max Seats` | Integer | `MinValue = 0`; `OnValidate` (guarded `Rec."No." <> ''`) recomputes `Seats Remaining` in memory via `CalcSeatsRemaining()` — see §3.3 |
| 8 | `Min Seats` | Integer | `Caption = 'Min Seats (Go/No-Go)'`; informational only |
| 9 | `Registered Attendees` | Integer | FlowField, `count("ocpfAttendee" where("Bootcamp No." = field("No.")))`, read-only |
| 10 | `Seats Remaining` | Integer | Read-only; not a FlowField — see §3.3 |
| 11 | `Status` | Enum `ocpfBootcampStatus` | `InitValue = Active` |

Key: `PK` on `No.`, clustered. `OnInsert`: assigns `No.` via `InitBootcampNo` if blank, sets
`Seats Remaining := CalcSeatsRemaining()`. `OnDelete`: blocks if any Attendee references it.
Procedure `CalcSeatsRemaining(): Integer` — shared by this trigger, `OnValidate`, and the
codeunit's `UpdateSeatsRemaining` (see §3.3's code block).

### 5.4 table 60820 `ocpfAttendee`

`DataClassification = CustomerContent` · `Caption = 'Attendee'` ·
`LookupPageId = "ocpfAttendeeList"` · `DrillDownPageId = "ocpfAttendeeList"`.

| id | field | type | behavior |
|---|---|---|---|
| 1 | `No.` | Code[20] | `OnValidate`: if changed, `BootcampRegMgt.TestAttendeeManualNo()`, clears `"No. Series"`. |
| 2 | `No. Series` | Code[20] | Read-only; `TableRelation = "No. Series"`. |
| 3 | `Bootcamp No.` | Code[20] | `NotBlank = true`; `TableRelation = "ocpfBootcamp"`. `OnValidate`: if changed, `BootcampRegMgt.SeedAmountPaid(Rec)` — the **only** call site (§3.7). |
| 10 | `Name` | Text[100] | free text |
| 11 | `Email Address` | Text[80] | `ExtendedDatatype = EMail`; format-validated `OnValidate` (§3.10) |
| 12 | `Phone Number` | Text[30] | `ExtendedDatatype = PhoneNo` |
| 13 | `Company` | Text[100] | free text |
| 14 | `Customer No.` | Code[20] | `TableRelation = Customer`; optional, no auto-population |
| 20 | `Paid` | Boolean | — |
| 21 | `Payment Date` | Date | not enforced against `Paid` |
| 22 | `Amount Paid` | Decimal | `AutoFormatType = 1`; `MinValue = 0`; seeded per §3.7 |
| 30 | `Attended` | Boolean | — |

Keys: `PK` on `No.` (clustered); `BootcampNo` on `Bootcamp No.`. `OnInsert`:
`Rec.TestField("Bootcamp No.")` (fails loudly on a blank link rather than saving a corrupt
orphan row); assigns `No.` via `InitAttendeeNo` if blank; calls
`ConfirmOverbookingIfNeeded(Rec)`. **No `SeedAmountPaid` call here** (§3.7). Seat-count
maintenance is done entirely by `ocpfBootcampRegMgt`'s event subscribers (§5.5), not by any
trigger on this table itself, so it always runs against committed state regardless of caller.

### 5.5 codeunit 60813 `ocpfBootcampRegMgt`

`using Microsoft.Foundation.NoSeries;`. Public procedures: `InitBootcampNo`, `InitAttendeeNo`
(plain No.-Series assignment, no retry logic), `TestBootcampManualNo`, `TestAttendeeManualNo`,
`SeedAmountPaid` (§3.7), `ConfirmOverbookingIfNeeded` (§3.5), `UpdateSeatsRemaining(BootcampNo)`
(§3.3). Local: `GetSetup()` (lazy-loads the singleton once per session, self-healing insert).

Event subscribers, all on `Database::"ocpfAttendee"`, each opening with
`if Rec.IsTemporary() then exit;`:

| Subscriber | Event | Action |
|---|---|---|
| `OnAfterInsertAttendee` | `OnAfterInsertEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` |
| `OnBeforeModifyAttendee` | `OnBeforeModifyEvent` | `xRec.Get(xRec."No.")` — see §3.3's `xRec` note |
| `OnAfterModifyAttendee` | `OnAfterModifyEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")`; if `xRec."Bootcamp No." <> Rec."Bootcamp No."` also `UpdateSeatsRemaining(xRec."Bootcamp No.")` |
| `OnAfterDeleteAttendee` | `OnAfterDeleteEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` |
| `OnAfterRenameAttendee` | `OnAfterRenameEvent` | `UpdateSeatsRemaining(Rec."Bootcamp No.")` |

Variables: `Setup: Record "ocpfBootcampRegSetup"`, `NoSeries: Codeunit "No. Series"`,
`SetupLoaded: Boolean`. `Bootcamp` is a local variable inside each procedure that needs it — no
shared scratch state.

### 5.6 codeunit 60803 `ocpfBootcampRegInstall`

`using System.Environment.Configuration;` · `using System.Media;` · `Subtype = Install`.
`OnInstallAppPerCompany`: ensures the Setup record exists; registers the wizard with
`GuidedExperience.InsertAssistedSetup(...)` (skips if already registered/complete).

### 5.7 page 60802 `ocpfBootcampRegSetup` (Card, single instance)

`PageType = Card` · `SourceTable = "ocpfBootcampRegSetup"` · `UsageCategory = None` ·
`DeleteAllowed = false` · `InsertAllowed = false`. `OnOpenPage` self-heals the singleton row.
Fields: `Bootcamp Nos.`, `Attendee Nos.`. Action `RunAssistedSetup` re-launches the wizard.

### 5.8 page 60811 `ocpfBootcampList` (List)

`PageType = List` · `SourceTable = "ocpfBootcamp"` · `UsageCategory = Lists` ·
`CardPageId = "ocpfBootcampCard"` · `Editable = true`. Repeater: `No.`, `Topic`, `Location`,
`Bootcamp Date`, `Status`, `Max Seats`, `Registered Attendees`, `Seats Remaining`, `Min Seats`,
`Price` — no field-level `ToolTip`s (inherited from the table, §3.14). `OnAfterGetRecord`:
`Rec.CalcFields("Registered Attendees")`. Action `Attendees` (its own `ToolTip` retained, since
it isn't a bound field): opens `ocpfAttendeeList` filtered via `RunPageLink`.

### 5.9 page 60812 `ocpfBootcampCard` (Card)

`PageType = Card` · `SourceTable = "ocpfBootcamp"`. Groups: `General` (`No.`, `Topic`,
`Location`, `Bootcamp Date`, `Status`), `Capacity & Pricing` (`Price`, `Max Seats`, `Min Seats`,
`Registered Attendees`, `Seats Remaining`) — no field-level `ToolTip`s (§3.14). `part(Attendees;
"ocpfAttendeeSubform")`, `SubPageLink = "Bootcamp No." = field("No.")`,
`UpdatePropagation = Both`. `OnAfterGetRecord`: `Rec.CalcFields("Registered Attendees")`.

### 5.10 page 60821 `ocpfAttendeeList` (List)

`PageType = List` · `SourceTable = "ocpfAttendee"` · `UsageCategory = Lists` ·
`Editable = true` · **`DelayedInsert = true`** (matches its subform sibling). Repeater:
`Bootcamp No.` (**`ShowMandatory = true`** — hard `TestField`-enforced, now visually flagged),
`No.`, `Name`, `Email Address`, `Phone Number`, `Company`, `Customer No.`, `Paid`,
`Payment Date`, `Amount Paid`, `Attended` — no field-level `ToolTip`s (§3.14).

### 5.11 page 60822 `ocpfAttendeeSubform` (ListPart)

`PageType = ListPart` · `SourceTable = "ocpfAttendee"` · `DelayedInsert = true` ·
`AutoSplitKey = false`. Fields: `Bootcamp No.` (`Visible = false` — a real, hidden control
backing the `SubPageLink`, matching the standard BC pattern for a link-driven line subform, e.g.
Job Task Lines), `Name`, `Email Address`, `Phone Number`, `Company`, `Customer No.`, `Paid`,
`Payment Date`, `Amount Paid`, `Attended` — no field-level `ToolTip`s (§3.14).

`trigger OnNewRecord`:
```al
trigger OnNewRecord(BelowxRec: Boolean)
var
    PrevFilterGroup: Integer;
    BootcampNoFilter: Text;
begin
    if Rec."Bootcamp No." <> '' then
        exit;
    PrevFilterGroup := Rec.FilterGroup();
    Rec.FilterGroup(4);
    BootcampNoFilter := Rec.GetFilter("Bootcamp No.");
    Rec.FilterGroup(PrevFilterGroup);
    if BootcampNoFilter <> '' then
        Rec.Validate("Bootcamp No.", CopyStr(BootcampNoFilter, 1, MaxStrLen(Rec."Bootcamp No.")));
end;
```
Two things this trigger depends on, both generalizable (§3.11, §3.7): reading a `SubPageLink`
filter in code requires `FilterGroup(4)` first; assigning the result must use `Rec.Validate`, not
a plain field assignment, or Amount Paid seeding is silently skipped.

### 5.12 page 60830 `ocpfBootcamps` (API)

`SourceTable = "ocpfBootcamp"`, `EntityName = 'ocpfBootcamp'`, `EntitySetName = 'ocpfBootcamps'`,
`DelayedInsert = true`, `Extensible = false`. Fields: `systemId`, `number` (`No.`), `topic`,
`location`, `bootcampDate`, `price`, `maxSeats`, `minSeats`, `registeredAttendees` (read-only),
`seatsRemaining` (read-only), `status`, `lastModifiedDateTime` (read-only). `OnAfterGetRecord`:
`Rec.CalcFields("Registered Attendees")`.

### 5.13 page 60831 `ocpfAttendees` (API)

`SourceTable = "ocpfAttendee"`, `EntityName = 'ocpfAttendee'`, `EntitySetName = 'ocpfAttendees'`,
`DelayedInsert = true`, `Extensible = false`. Fields, in declaration order (matters for §3.7's
seed-vs-override guarantee): `systemId`, `number`, **`bootcampNo`** (writable — how an
integration attaches to a bootcamp), `name`, `email`, `phoneNumber`, `company`, `customerNo`,
`paid`, `paymentDate`, **`amountPaid`** (seeded server-side if omitted/left implicit; an explicit
value including `0` wins because `bootcampNo` validates first), `attended`,
`lastModifiedDateTime` (read-only).

### 5.14 page 60840 `ocpfBootcampRegSetupWizard` (NavigatePage)

`PageType = NavigatePage` · `SourceTable = "ocpfBootcampRegSetup"` · `UsageCategory = None`.
Four steps (Welcome, Numbering, Sample data, Finish) driven by a `Step` option variable, with
three hand-written `action(ActionBack)` / `ActionNext` / `ActionFinish` in `area(Navigation)`
(`InFooterBar = true`) — not the standard NavigatePage `actionref`/`SystemActions` pattern. All
persistence happens in `Finish` alone; a mid-wizard cancel leaves the Setup record untouched.

`Finish`: `Rec.Modify(true)`; if sample data was requested, `CreateSampleBootcamps()` inserts two
`ocpfBootcamp` rows using `Bootcamp.Insert(true)` (so numbering fires) —
```al
Bootcamp.Init();
Bootcamp."No." := '';   // Init() does not clear the primary key (§3.12) — required before
                        // reusing this record variable for a second insert.
// ... set Topic/Bootcamp Date/Price/Max Seats/Min Seats ...
Bootcamp.Insert(true);
```
— then `GuidedExperience.CompleteAssistedSetup(...)`. Helper
`CreateDefaultSeriesIfBlank()` creates a `No. Series` + line when a numbering field is left blank
and the user consents.

### 5.15 pageextension 60841 `ocpfBusinessMgrRCExt`

`extends "Business Manager Role Center"` (page 9022). `addlast(sections)` adds a
`group(ocpfBootcamps)` with three actions (Bootcamps list, Bootcamp Attendees list, Bootcamp
Registration Setup), each `Image` value confirmed valid against the symbol file
(`Image = ContactPerson`, not the originally planned `Persons`, which doesn't compile — `AL0482`).

### 5.16 permissionset 60890 `OCPF - Bootcamp Read`

```al
Permissions =
    tabledata "ocpfBootcampRegSetup" = R,
    tabledata "ocpfBootcamp" = R,
    tabledata "ocpfAttendee" = R,
    page "ocpfBootcampRegSetup" = X,
    page "ocpfBootcampList" = X,
    page "ocpfBootcampCard" = X,
    page "ocpfAttendeeList" = X,
    page "ocpfAttendeeSubform" = X,
    page "ocpfBootcampRegSetupWizard" = X,
    page "ocpfBootcamps" = X,
    page "ocpfAttendees" = X;
```
Explicit `page … = X` execute grants on all 8 of this extension's own pages, added defensively
per Standards §7.3's literal requirement rather than relying on `tabledata`-implied page access.
Pageextensions/tableextensions on standard objects need no grant of their own — they ride on the
base object's own permission coverage. **Not yet live-verified** with a non-SUPER test user — a
named Step 12 test case.

### 5.17 permissionset 60891 `OCPF - Bootcamp Edit`

`IncludedPermissionSets = "OCPF - Bootcamp Read"`, plus `tabledata … = IMD` on all three owned
tables. Inherits all 8 page execute grants from the included Read set — no separate grants here.

### 5.18 tableextension 60842 `ocpfActivitiesCueExt`

`extends "Activities Cue"` (table 1313). Field IDs 60800–60804 (a separate ID space scoped to
table 1313, chosen to match this project's numeric identity — no collision with 1313's own fields,
which top out at 110):

| id | field | type | pattern |
|---|---|---|---|
| 60800 | `OCPF Active Bootcamps` | Integer | FlowField, `count("ocpfBootcamp" where(Status = const(Active)))` |
| 60801 | `OCPF Unpaid Registrations` | Integer | FlowField, `count("ocpfAttendee" where(Paid = const(false)))` |
| 60802 | `OCPF Below Min Seats` | Integer | Plain, `DataClassification = CustomerContent`, computed by `UpdateCues` |
| 60803 | `OCPF Registrations This Month` | Integer | Plain, `DataClassification = CustomerContent`, computed by `UpdateCues` |
| 60804 | `OCPF Revenue This Month` | Decimal | Plain, `AutoFormatType = 1`, `DataClassification = CustomerContent`, computed by `UpdateCues` |

Every Normal field a `tableextension` adds must set its own `DataClassification` — the base table
has none to inherit. All five carry a `Caption` and a `ToolTip` that match their actual computed
behavior exactly (60802's ToolTip does not claim an "upcoming" filter that doesn't exist; 60804's
ToolTip says "paid this month," matching the code, not "registered this month").

### 5.19 codeunit 60843 `ocpfActivityCueMgt`

One public procedure, `UpdateCues(var ActivitiesCue: Record "Activities Cue")`, computing the
three plain fields:
- `OCPF Below Min Seats` — `Bootcamp.SetRange(Status, Active); Bootcamp.SetAutoCalcFields
  ("Registered Attendees")`, then counts rows where `Registered Attendees < Min Seats`.
- `OCPF Registrations This Month` — count of `ocpfAttendee` rows with `SystemCreatedAt` in the
  current calendar month (proxy — no explicit registration-date field exists).
- `OCPF Revenue This Month` — `CalcSums("Amount Paid")` where `Paid = true` and `Payment Date`
  falls in the current calendar month (paid-this-month, not registered-this-month).

Called from the pageextension's `OnAfterGetRecord`, guarded — see §5.20. No permission-set entry
needed: `Activities Cue` is already readable by every user (it drives their own Role Center); a
`tableextension` introduces no new table, so `PTE0004` doesn't apply.

### 5.20 pageextension 60844 `ocpfO365ActivitiesExt`

`extends "O365 Activities"` (page 1310, global). Adds a `cuegroup` via `addlast(content)`
surfacing the five fields from §5.18, each with a page-level `Caption` (no `ToolTip` — inherited,
§3.14) and an `OnDrillDown` opening the relevant list, filtered.

```al
cuegroup(ocpfBootcamps)
{
    Visible = OcpfCuesVisible;
    // ... 5 fields, each with OnDrillDown ...
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

var
    ActivityCueMgt: Codeunit "ocpfActivityCueMgt";
    OcpfCuesVisible: Boolean;
```
One `Boolean`, computed once in `OnOpenPage`, covers both the FlowField cues (60800/60801, via
`Visible` on the whole `cuegroup`) and the plain-field cues (via the `UpdateCues` guard) in a
single place — a codeunit-only guard would have missed the two FlowField cues entirely, since the
platform calculates them at render time, not through `UpdateCues`. **Not yet live-verified** with
a non-SUPER, non-`OCPF - Bootcamp Read` test user — a named Step 12 test case.

## 6. Deletion behavior

| Table | Behavior | Mechanism | Referencing fields checked |
|---|---|---|---|
| `ocpfBootcamp` | **Block** if any attendee references it | `OnDelete` → `Error` | `ocpfAttendee."Bootcamp No."`. No standard BC table references `ocpfBootcamp`. |
| `ocpfAttendee` | **Allow**; parent seat count updated | `OnAfterDeleteEvent` subscriber | none reference `ocpfAttendee`. |
| `ocpfBootcampRegSetup` | **Not user-deletable** | `DeleteAllowed = false` | n/a (singleton). |
| `Customer` (std) | Not extended | — | `ocpfAttendee."Customer No."` is optional; deleting a Customer is not blocked here and may leave a dangling link — accepted, informational only. |

## 7. Field conversion / naming decisions

| Source name | AL identifier | Decision |
|---|---|---|
| "No." | `No.` (table), `number` (API) | Standard BC pattern. |
| "Min Seats (Go/No-Go)" | `Min Seats` + `Caption = 'Min Seats (Go/No-Go)'` | Parenthetical kept in caption, not identifier. |
| "Seats Remaining" | `Seats Remaining` / `seatsRemaining` | Stored, not FlowField (§3.3). |
| "Registered Attendees" | `Registered Attendees` / `registeredAttendees` | FlowField count. |

No reserved-keyword collisions; no abbreviations required (longest identifier: `Registered
Attendees`, 20 chars); no obsolete/pending standard fields referenced.

## 8. Standard templates (unchanged from design; still followed by every object)

See `TDD.md` §9 for the full API page / table field / non-API page field templates and
formatting rules (4-space indent, no tabs, one `namespace` per file). No deviation was found
here at Step 09 — this section is carried forward unchanged.

## 9. Traceability — FRD → as-built

| FRD | As-built location |
|---|---|
| F-1 Bootcamp CRUD | 60810 table, 60811/60812 pages |
| F-2 Bootcamp fields | §5.3 |
| F-3 Seats Remaining + Registered Attendees, 0-when-uncapped | §3.3, §5.3 fields 9–10 |
| F-4 manual Status | §5.1 |
| F-5 Attendee CRUD, parent link, numbering | 60820 table, §5.5 `InitAttendeeNo` |
| F-6 Attendee contact fields | §5.4 fields 10–13 |
| F-7 optional Customer link | §5.4 field 14 |
| F-8 Amount Paid default, editable, seed-once | §3.7, §5.5 `SeedAmountPaid` |
| F-9 Attended flag | §5.4 field 30 |
| F-10 Max Seats warn-but-allow, 0 = no cap | §3.5, §5.5 `ConfirmOverbookingIfNeeded` |
| F-11 block delete with attendees | §3.6, §6 |
| F-12 Setup singleton with two No. Series | §5.2, §5.7 |
| F-13 wizard registered in Assisted Setup, re-runnable | §5.14, §5.6 |
| F-14 in-client pages + Business Manager RC entry | §5.8–§5.11, §5.15 |
| F-15 API v1.0 read/write for Bootcamp & Attendee | §5.12, §5.13 |
| F-16 Role Center Activity Cues | §5.18–§5.20 |

## 10. Permission verification (Standards §7.3)

| Check | Status |
|---|---|
| Read set grants `tabledata … = R` on all 3 owned tables | ✅ verified in source (§5.16) |
| Read set grants `page … = X` on all 8 owned pages | ✅ verified in source (§5.16) |
| Edit set includes Read set plus `IMD` on all 3 tables | ✅ verified in source (§5.17) |
| Live test: a non-SUPER user assigned only the Read set can open every page | ⬜ **not yet run** — named Step 12 test case |
| Live test: the same user sees the Activity Cues hidden without the Read set, visible with it | ⬜ **not yet run** — named Step 12 test case |

## 11. Known, deliberately-scheduled items (not defects — see `docs/Roadmap.md`)

- **R-1** — no explicit upgrade codeunit exists; a new-company Assisted Setup registration gap
  is folded into the same item.
- **R-2** — `Confirm()` inside `ConfirmOverbookingIfNeeded` runs inside the same transaction as
  the Attendee insert (BP-6, Step 09) — not wrong, but worth revisiting if this project ever
  needs to run headless/unattended inserts at scale.

## 12. Deviation summary — original `TDD.md` vs. as-built

Full reasoning and diagnosis for every row below lives in `docs/ChangeLog.md`, cited by Issue ID;
this table is a map, not a replacement.

| Area | Original design (`TDD.md`) | As-built (this document) | ChangeLog |
|---|---|---|---|
| Bootcamp numbering collision | `InitBootcampNo` suspected as root cause | Real cause: `Init()` doesn't clear the primary key; `CreateSampleBootcamps` now clears `"No."` explicitly after each `Init()` | BUILD-13 (wrong fix, reverted), BUILD-16 (real fix) |
| Attendee subform blank `Bootcamp No.` | `SubPageLink` alone, no hidden control, plain `GetFilter()` | Hidden `Bootcamp No.` control added; `FilterGroup(4)` read before `GetFilter` | BUILD-12 (wrong fix), BUILD-16 (real fix) |
| `Max Seats.OnValidate` → Seats Remaining | Called `UpdateSeatsRemaining` (re-`Get()`s the record) | Computed in memory directly on `Rec` | STEP08-01/02 (G-12) |
| Seats Remaining, `Max Seats <= 0` | Raw subtraction could go negative | Clamped to 0 via shared `CalcSeatsRemaining()` | STEP09-02 (BP-7) |
| `OnAfterModifyEvent` `xRec` comparison | Trusted `xRec` unconditionally | New `OnBeforeModifyEvent` subscriber refreshes `xRec` from the database first | STEP09-02 (BP-2) |
| Amount Paid seeding | Seeded on `OnInsert` **and** `OnValidate`, guarded by `Amount Paid = 0` | Seeded only from `OnValidate("Bootcamp No.")`; `OnInsert` call removed | STEP09-02 (BP-1) |
| Attendee subform `OnNewRecord` | Plain field assignment to `"Bootcamp No."` | `Rec.Validate("Bootcamp No.", ...)` — required once Amount Paid seeding moved to `OnValidate` alone | STEP09-02 (BP-1, second half) |
| Permission sets | `tabledata` grants only; page execution assumed inherent | Explicit `page … = X` grants added to the Read set | STEP09-02 (SC-1, closes STEP08's G-04) |
| Activity Cue permission guard | Proposed guard inside `UpdateCues` only (G-14) | `cuegroup.Visible` guard added — covers the 2 FlowField cues a codeunit-only guard would miss | STEP09-02 (BP-3) |
| Activity Cue ToolTips (60802, 60804) | Described behavior the code didn't implement | Reworded to match the code exactly | STEP09-02 (CQ-2) |
| Activity Cue `DataClassification` | Missing on 3 plain fields | Added `CustomerContent` on each | STEP09-02 (BP-5) |
| `ocpfAttendeeList` | No `DelayedInsert`; no `ShowMandatory` on `Bootcamp No.` | Both added, matching the subform | STEP09-02 (CQ-3, BP-4) |
| `CountBelowMinSeats` | Per-row `CalcFields` in a loop | `SetAutoCalcFields` once before the loop | STEP09-02 (PERF-1) |
| Page-level `ToolTip`s (40 total, 5 files) | Duplicated the table field's own; some drifted | Removed — inherited automatically from runtime 13.0+ | STEP09-02 (R-1) |
| `ocpfBusinessMgrRCExt` action image | Planned `Image = Persons` (invalid, `AL0482`) | `Image = ContactPerson` | BUILD-07 |
| Business Manager RC wizard navigation | Planned standard NavigatePage `actionref`/`SystemActions` | Three hand-written actions, `Enabled` bound to a `Step` variable | STEP08-01/02 (G-08) |
| `ProjectParameters.md` §1.3 API identity | Recorded the Standards §1.3 literal example | Corrected to the shipped camelCase identity (`onlyCopilotFans` / `ocpfBootcampRegistration`) | STEP08-01/02 (G-17) |
| `ObjectRegister.md` permission-set rows | Described as "setup table only" | Corrected to reflect all 3 tables + 8 pages | STEP09-02 |

Not corrected — checked and found not to apply: a Step 09 finding (R-2) claimed an unused
`using Microsoft.RoleCenters;` line in `ocpfO365ActivitiesExt.PageExt.al`; that file has no such
line. Left as-is (STEP09-02).

Not corrected — accepted as a deliberate divergence, not a defect: API page Captions follow
CodeCop AA0101 rather than the Standards §4.5 literal example (CQ-1, STEP09-02); `APIPublisher`/
`APIGroup` camelCasing (BUILD-06, §1 above).

---

**Exit gate (Step 10):** this document is complete enough to regenerate the system from; `FRD.md`
has been updated in place to match (see its own header for the pre-BUILD version pointer). Dev
Manager review pending.

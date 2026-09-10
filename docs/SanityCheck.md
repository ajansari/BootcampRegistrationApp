# Sanity Check & Validation (Step 04) — Bootcamp Registration Tracking

**Phase:** DESIGN · **Step:** 04 · **Status:** Awaiting Technical Lead sign-off
**Date:** 2026-09-10
**Inputs:** `docs/FRD.md`, `docs/TDD.md`, BC v28.4 symbol files.
**Method:** Formal structured review — (A) can BC do what the FRD asks? (B) does the TDD fully
and correctly implement the FRD? Every check below has a finding and a resolution.

---

## A. BC feasibility of the FRD

| FRD item | Can BC do it? | Evidence |
|---|---|---|
| F-1…F-2 Bootcamp master + fields | Yes | Plain table + card/list pages. |
| F-3 Seats Remaining + Registered Attendees | Yes, **not as one FlowField** | AL `FlowField` `CalcFormula` has no subtraction (Count/Sum/Exist/Lookup/Min/Max/Avg only). Resolved in DESIGN-02: `Registered Attendees` = FlowField count; `Seats Remaining` = stored, subscriber-maintained. |
| F-4 manual Status | Yes | Project `enum`; no code path changes it (verified in TDD §6.3 field 11). |
| F-5 Attendee + No. Series numbering | Yes | `codeunit 310 "No. Series"` `GetNextNo(Code[20]): Code[20]` verified in `Microsoft.Foundation.NoSeries`. |
| F-6 Attendee contact fields | Yes | Plain fields. |
| F-7 optional Customer link | Yes | `TableRelation = Customer` (`table 18`, `Microsoft.Sales.Customer`) verified. |
| F-8 Amount Paid default, editable, no overwrite | Yes | `OnInsert`/`OnValidate` seeding a stored field, guarded on `<> 0` (TDD §4.7). |
| F-9 Attended flag | Yes | Boolean. |
| F-10 Max Seats warn-but-allow | Yes | `Confirm()` in table `OnInsert` guarded by `GuiAllowed`; headless (API) path proceeds — matches "allow". |
| F-11 block delete with attendees | Yes | Table `OnDelete` → `Error`. `Attendee.SetRange(...); IsEmpty()`. |
| F-12 Setup singleton, two No. Series | Yes | Standard blank-key singleton pattern. |
| F-13 wizard in Assisted Setup, re-runnable, completion state | Yes | `codeunit 1990 "Guided Experience"` verified: `InsertAssistedSetup(...)`, `IsAssistedSetupComplete`, `CompleteAssistedSetup`, `Run("Guided Experience Type"; ObjectType; Integer)`. `enum 1990 "Guided Experience Type"::"Assisted Setup"` (value 0) verified. `enum "Assisted Setup Group"::Extensions` (value 5, BaseApp ext 1814) verified. `enum 3710 "Video Category"::Uncategorized` verified. |
| F-14 Business Manager Role Center entry | Yes | `page 9022 "Business Manager Role Center"` (`Microsoft.Finance.RoleCenters`) has `area(sections)` (line 457) — `addlast(sections)` is a valid, low-coupling anchor. |
| F-15 API v1.0 read/write for Bootcamp & Attendee | Yes | Standard `PageType = API` with `APIPublisher`/`APIGroup`/`APIVersion`/`EntityName`/`EntitySetName`/`ODataKeyFields = SystemId`/`DelayedInsert = true`. |

**A result:** No FRD requirement depends on platform behavior BC does not have. The one
impossible literal reading (Seats Remaining as a single FlowField) was already corrected in
DESIGN-02.

## B. Runbook checklist

| # | Check | Finding | Resolution |
|---|---|---|---|
| B-1 | Every FRD entity maps to ≥ 1 TDD object | Pass — TDD §11 traceability covers F-1…F-15. | — |
| B-2 | Every TDD object ID is inside an allocated range | Pass — 17 IDs, all in 60800–60899, none reused (60800/01/02/03, 60810/11/12/13, 60820/21/22, 60830/31, 60840/41, 60890/91). | — |
| B-3 | Every source table number verified against the symbol file | Pass — No. Series 308, No. Series Line 309, No. Series codeunit 310, Customer 18, Guided Experience codeunit 1990, Assisted Setup Group enum 1815 (+BaseApp ext 1814), Video Category enum 3710, Guided Experience Type enum 1990, Business Manager Role Center page 9022. All read from the `.al` files on 2026-09-10. | — |
| B-4 | Every field complies with Localization (`NA`) + Standards Part 5 | Pass — no localized standard field is touched; every field is on a new table; no tax/VAT fields (per GapAnalysis §8.6). | — |
| B-5 | Every obsolete / pending field excluded | Pass — only current members used (`GetNextNo`/`TestManual`/`PeekNextNo` — the modern codeunit 310, **not** the obsolete `NoSeriesManagement`). No `ObsoleteState = Pending/Removed` reference. | — |
| B-6 | Every `using` namespace sourced from the symbol file | Pass — `Microsoft.Foundation.NoSeries`, `Microsoft.Sales.Customer`, `System.Environment.Configuration`, `System.Media`, `Microsoft.Finance.RoleCenters` — all confirmed. | — |
| B-7 | Document-type-filtered pages use correct `const()` quoting | N/A — no such pages in this design (TDD §4.8). Recorded so a future addition knows the rule. | — |
| B-8 | All entity names ≤ 30 chars; all field identifiers ≤ 30 | Pass — longest field id `Registered Attendees` (20); longest object name `ocpfBootcampRegSetupWizard` (26); `EntitySetName` `ocpfBootcamps`/`ocpfAttendees` (13); `APIGroup` `ocpf_bootcampRegistration` (25). | — |
| B-9 | Read vs read/write matches Standards §4.2 mutability | Pass — Bootcamp & Attendee API pages `DelayedInsert = true` (RW master/registration data); Setup not exposed; `Registered Attendees` / `Seats Remaining` `Editable = false`. | — |
| B-10 | Growth buffers ≥ 20% per module block | Pass — M1 60%, M2 60%, M3 70%, M4 80%, M5 90%; plus a 30-ID cross-module tail block (60860–60889). | — |
| B-11 | Permission sets planned (Parameter 1.2 = Yes) | Pass — 60890 `OCPF - Bootcamp Read` (tabledata R ×3), 60891 `OCPF - Bootcamp Edit` (`IncludedPermissionSets` + tabledata IMD ×3). See S-12 for a documented standard-permission dependency. | — |
| B-12 | Every entity's deletion behavior explicitly decided, incl. referencing fields | Pass with S-3 accepted — TDD §7: Bootcamp **block** (OnDelete vs `ocpfAttendee."Bootcamp No."`); Attendee **allow** (nothing references it); Setup **not user-deletable**; `Customer` deletion **not** blocked → optional `Customer No.` may dangle (**S-3, accepted**). No `tableextension` in this project, so no standard-table field references a new entity. | — |

## C. Issues found in this review

| ID | Severity | Issue | Resolution |
|---|---|---|---|
| **S-1** | Minor | TDD §6.15 wrote `addlast(Sections)`; the actual area token in page 9022 is lowercase `sections`. | Align TDD to `addlast(sections)`. (AL area names are case-insensitive, so functionally equivalent — corrected for fidelity.) **TDD updated.** |
| **S-2** | Note | Wizard `NavigatePage` binds to the real singleton `ocpfBootcampRegSetup`; a mid-wizard cancel leaves the record untouched because changes persist only in the `Finish` action's `Rec.Modify(true)`. | Acceptable and standard for a simple setup wizard. No change. Documented in TDD §6.14. |
| **S-3** | Accepted | Deleting a `Customer` is not blocked and can leave a dangling `ocpfAttendee."Customer No."`. | **Accepted** — optional informational link, low harm; `ValidateTableRelation` still blocks setting an invalid value. A `Customer` `OnDelete` subscriber was considered and declined to keep the footprint minimal. Revisit only if it bites in Step 09. |
| **S-4** | Minor | Attendee API exposes `bootcampNo` as writable. Need to confirm field validation (NotBlank, TableRelation) and `OnInsert` logic fire on an API insert. | Confirmed: `DelayedInsert = true` API pages run field `OnValidate` on write and the table `OnInsert` on completion. `NotBlank` + `TableRelation` on `"Bootcamp No."` will reject a missing/invalid parent with a clean error (supports N-9). No change. |
| **S-5** | Note | `UpdateSeatsRemaining` does `Bootcamp.Modify(false)` from an event subscriber during an `ocpfAttendee` write — parent modified within the child's transaction. | Standard denormalized-counter pattern; at this scale (hundreds of attendees) locking impact is negligible; runs in the same transaction so the value is consistent on commit. No change. |
| **S-7** | **Blocking (design)** | **Batch-ordering defect.** Old plan built `ocpfBootcamp` (Batch 2) before `ocpfAttendee` (Batch 3), but `ocpfBootcamp`'s `Registered Attendees` FlowField has `CalcFormula = count("ocpfAttendee" …)` — a reference to a table that would not yet exist. And `ocpfAttendee` has `TableRelation = "ocpfBootcamp"` — the reference is **mutual**, so neither table can fully precede the other in its own batch. | **Restructure the batch plan** so the two core tables + the Mgt codeunit are delivered in **one** batch, and all pages in the next. New 5-batch plan (TDD §3 rewritten): **1** Foundation → **2** Core tables & logic (`ocpfBootcamp`, `ocpfAttendee`, `ocpfBootcampRegMgt` together) → **3** In-client pages (both lists, card+subpart) → **4** API pages → **5** Wizard, Navigation, Permissions (+ revisit Install for Guided Experience registration). "Smallest/simplest first" still holds. **TDD updated.** |
| **S-8** | Note | `ocpfBootcampRegMgt` event subscribers reference `Database::"ocpfAttendee"` — fine now that the table is in the same batch (S-7 fix). | No further change. |
| **S-9** | Note | `UpdateSeatsRemaining` called from `OnValidate("Max Seats")` on a not-yet-inserted Bootcamp: `Bootcamp.Get()` fails → guarded `exit`. `OnInsert` then sets `"Seats Remaining" := "Max Seats"`. | Consistent. Explicit guard `if not Bootcamp.Get() then exit;` is in TDD §6.5. No change. |
| **S-11** | Note | Creating a Bootcamp/Attendee before the wizard has set the No. Series → `Setup.TestField("Bootcamp Nos.")` raises a standard, actionable error naming the missing field. | Acceptable (supports N-7). Optionally soften the message later; not required. |
| **S-12** | Documented dependency | `OCPF - Bootcamp Edit` grants IMD on the three new tables only. The wizard's optional "create a default No. Series" step writes standard `No. Series` / `No. Series Line` — **not** covered by our permission sets. | **Documented, not granted** — consistent with FRD §6.6 ("consumers also need standard base permissions"). The wizard is an admin task; admins hold `D365 SETUP` / SUPER. Add to the deployment doc (Step 12) and verify in Step 09. |

## D. As-built object structure (what BUILD will produce)

```
app.json                       (idRanges 60800-60899, name/publisher/deps rewritten in Step 05)
src/
  Foundation/
    BootcampStatus.Enum.al                 (60800)
    BootcampRegSetup.Table.al              (60801)
    BootcampRegSetup.Page.al               (60802)
    BootcampRegInstall.Codeunit.al         (60803)
  Bootcamp/
    Bootcamp.Table.al                      (60810)
    Bootcamp.Page.al  -> ocpfBootcampCard  (60812)
    BootcampList.Page.al                   (60811)
    BootcampRegMgt.Codeunit.al             (60813)
  Attendee/
    Attendee.Table.al                      (60820)
    AttendeeList.Page.al                   (60821)
    AttendeeSubform.Page.al                (60822)
  Api/
    BootcampApi.Page.al  -> ocpfBootcamps  (60830)
    AttendeeApi.Page.al  -> ocpfAttendees  (60831)
  Setup/
    BootcampRegSetupWizard.Page.al         (60840)
  RoleCenter/
    BusinessMgrRCExt.PageExt.al            (60841)
  Permissions/
    BootcampRead.PermissionSet.al          (60890)
    BootcampEdit.PermissionSet.al          (60891)
```

- Two top-level tables (`ocpfBootcamp`, `ocpfAttendee`) + one singleton (`ocpfBootcampRegSetup`).
- Relationship graph: `ocpfAttendee."Bootcamp No."` → `ocpfBootcamp."No."` (1:N, block-on-delete);
  `ocpfAttendee."Customer No."` → `Customer` (0..1, not blocked); `ocpfBootcampRegSetup.
  "Bootcamp Nos."`/`"Attendee Nos."` → `No. Series`.
- `ocpfBootcamp."Registered Attendees"` FlowField counts `ocpfAttendee` on `key(BootcampNo)`.

## E. Result

- **Blocking issues:** 1 found (S-7), **resolved** by restructuring the batch plan in `TDD.md` §3
  and the batch columns in §2.1 / §6.
- **Minor issues:** S-1 fixed in TDD; S-4 confirmed OK.
- **Accepted / documented:** S-2, S-3, S-5, S-9, S-11, S-12.
- All 12 runbook checklist items pass.

**Exit gate (Step 04):** 0 blocking issues outstanding; every gap resolved; Technical Lead
sign-off.

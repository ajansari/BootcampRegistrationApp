# ChangeLog — Bootcamp Registration Tracking (BC PTE)

Ground truth for what was actually built and why. Every deviation from FRD or TDD — by any
contributor — is logged here before the next batch begins (Standards §10.4).

---

## Issue DEFINE-01 — Clarifying decisions on requirements ambiguities

**Problem:** The requirements doc contained a contradiction (Relationship Type selector present
in the body, declared removed in the header note, pointing at a `docs/FRD.md` that does not exist
in this repo) and was silent on consumer surface, wizard scope, and record numbering.

**Root cause:** The input is described in its own header as a "loose requirements statement,"
re-baselined elsewhere; the re-baselined FRD was not carried into this repo.

**Resolution:** Four decisions taken by AJ on 2026-09-10:
1. Attendee record linking — **single optional Customer link, no Relationship Type selector**;
   Contact and Vendor links dropped.
2. Consumer surface — **in-client pages + read/write API v1.0 pages** for Bootcamp and Attendee.
3. Assisted Setup Wizard configures **No. Series for Bootcamp and Attendee** and can
   **optionally create sample bootcamp data**. Configurable Setup defaults and formal Guided
   Experience registration were not selected (registration recommended as an open question).
4. Numbering — **both Bootcamp and Attendee use No. Series** code keys; Attendee carries the
   parent Bootcamp No.

**Files affected:** `docs/ProblemStatement.md` (new), `docs/ProjectMemory.md` (new),
`docs/ChangeLog.md` (this file).

**Updated:** TDD — no (not yet written). FRD — no (not yet written). Requirements input left
as-is (frozen given input); divergence recorded here and will be reflected in `docs/FRD.md`.

---

## Issue DEFINE-02 — Project Parameters intake

**Problem:** The scaffold carried placeholder identity (`publisher = "Default Publisher"`,
`name = "BootcampClaude"`) and an ID range (`50100–50149`) that had not been confirmed.

**Root cause:** Fresh scaffold; identity never collected.

**Resolution:** Intake sheet completed with AJ on 2026-09-10 (`docs/ProjectParameters.md`):
Extension Name `Bootcamp Registration Tracking`; Publisher `OnlyCopilotFans`; Deployment Target
`SaaS PTE`; Namespace `OCPF.BootcampRegistration` (Use Namespace = Yes); Localization `NA`;
Prefix `ocpf`; APIPublisher `'OnlyCopilotFans'`; APIGroup prefix `ocpf_`; APIVersion `'v1.0'`;
Permission Set Prefix `OCPF - `; AL Runtime `17.0`; BC Application minimum `28.0.0.0`; Symbol
source BC v28.4. **Object ID range changed from `50100–50149` to `60800–60899` (100 IDs), no
additional ranges.** Permission Sets required = Yes (reserved 60890–60891).

**Files affected:** `docs/ProjectParameters.md` (new), `docs/ObjectRegister.md` (new). `app.json`
`idRanges`, `name`, `publisher` still to be rewritten in Step 05.

**Updated:** TDD — n/a (not written). FRD — n/a (not written).

---

## Issue DESIGN-01 — Resolve the 8 open questions; author the FRD

**Problem:** `ProblemStatement.md` §8 parked 8 open questions that the FRD needs resolved.

**Root cause:** Deliberately deferred from DEFINE so they could be decided with parameters in hand.

**Resolution:** AJ decided on 2026-09-10: (1) register the wizard in Assisted Setup / Guided
Experience with a completion state; (2) **block** bootcamp deletion when attendees exist;
(3) Max Seats — **warn but allow** overbooking; (4) Seats Remaining counts all attendee rows;
(5) Amount Paid is a stored seeded field, never auto-overwritten (not a FlowField); (6) add a
**Business Manager Role Center** pageextension; (7) Email uses the standard email datatype,
optional; (8) build targets BC v28.4 symbols, minimum 28.0.0.0. `docs/FRD.md` authored with
15 functional requirements (F-1…F-15), 15 design rules (D-1…D-15), and the object inventory.

**Files affected:** `docs/FRD.md` (new).

**Updated:** FRD — yes (created). TDD — n/a (not written).

---

## Issue DESIGN-02 — Seats Remaining cannot be a FlowField

**Problem:** FRD D-8 (as signed off) required `Seats Remaining` to be a pure `FlowField`,
read-only and always live.

**Root cause:** `Seats Remaining` = `Max Seats − attendee count`. AL `FlowField` `CalcFormula`
supports only Count / Sum / Exist / Lookup / Min / Max / Average — it cannot express a
subtraction. Discovered while writing the per-field spec in Step 03.

**Resolution:** `ocpfBootcamp` gets **two** fields: `Registered Attendees` (`FlowField`,
`CalcFormula = count(...)`, live) and `Seats Remaining` (plain `Integer`, `Editable = false`,
**maintained by code**). `ocpfBootcampRegMgt.UpdateSeatsRemaining()` recomputes `Max Seats −
Registered Attendees` and is invoked from `ocpfAttendee` `OnAfterInsert/Modify/Delete/Rename`
event subscribers and from `ocpfBootcamp.OnValidate("Max Seats")` / `OnInsert`. Deterministic —
every mutation path recomputes from the authoritative count. Neither field is user- or
API-writable, so F-3's intent (never entered) is preserved.

**Files affected:** `docs/FRD.md` (F-3, D-8, §4, §6.1, §7 updated in place), `docs/TDD.md` §4.3,
§6.3, §6.5.

**Updated:** FRD — yes (in place). TDD — yes (authored with this design).

---

## Issue DESIGN-03 — Technical Design Document authored

**Problem:** FRD signed off; a self-sufficient TDD was needed before any code.

**Root cause:** n/a — planned step (03).

**Resolution:** `docs/TDD.md` written: 5 modules (M1–M5) in ID sub-blocks 60800–60859 with ≥60%
buffers, permission sets 60890–60891, tail block 60860–60889; 5-batch plan (Foundation →
Bootcamp → Attendee → API → Wizard/Nav/Permissions); per-object and per-field specs for all 17
objects; standard AL templates (API page, table field, page field); pre-flight checklist;
FRD→TDD traceability. All standard object numbers/namespaces re-verified against the BC v28.4
symbols (No. Series 308 / codeunit 310 / `Microsoft.Foundation.NoSeries`; Customer 18 /
`Microsoft.Sales.Customer`; Guided Experience 1990 / `System.Environment.Configuration`;
Assisted Setup Group enum value `Extensions`; Video Category `Uncategorized`; Business Manager
Role Center page 9022 / `Microsoft.Finance.RoleCenters`).

**Files affected:** `docs/TDD.md` (new), `docs/ObjectRegister.md` (populated with 17 planned
objects).

**Updated:** TDD — yes (created). FRD — no further change.

---

## Issue DESIGN-04 — Sanity Check: batch-ordering defect + minor fixes

**Problem:** The Step 03 batch plan built `ocpfBootcamp` (Batch 2) before `ocpfAttendee`
(Batch 3). But `ocpfBootcamp."Registered Attendees"` is `FlowField count("ocpfAttendee" …)` and
`ocpfAttendee."Bootcamp No."` has `TableRelation = "ocpfBootcamp"` — a **mutual** reference, so
neither table can compile in a batch that omits the other. Also TDD §6.15 used `addlast(Sections)`
where page 9022's actual area token is lowercase `sections`.

**Root cause:** Batch boundaries drawn along module lines (M2 Bootcamp / M3 Attendee) without
accounting for the FlowField→table reference crossing that line in the opposite direction to the
TableRelation.

**Resolution:**
- **Batch plan restructured to 5 batches:** 1 Foundation → **2 Core tables & logic
  (`ocpfBootcamp` + `ocpfAttendee` + `ocpfBootcampRegMgt` delivered together)** → 3 In-client
  pages → 4 API → 5 Wizard/Navigation/Permissions. Modules (where an object lives) are unchanged;
  only delivery batches moved. No batch now contains a forward reference.
- `addlast(Sections)` → `addlast(sections)`; `area(sections)` confirmed present at page 9022
  line 457.
- Accepted/documented without change: dangling `Customer No.` after a Customer delete (S-3);
  wizard binds the real singleton and persists only on Finish (S-2); denormalized-counter
  `Modify(false)` from a subscriber (S-5); `OCPF - Bootcamp Edit` does not grant standard
  `No. Series` write — admin permission dependency, to document in Step 12 (S-12).

**Files affected:** `docs/SanityCheck.md` (new), `docs/TDD.md` §2, §2.1, §3, §5, §6.3, §6.5,
§6.9, §6.15.

**Updated:** TDD — yes. FRD — no.

---

## Issue BUILD-00 — Scaffold prepared (Step 05)

**Problem:** Project needed its scaffold before code generation.

**Root cause:** n/a — planned step.

**Resolution:** `app.json` rewritten (`name` = `Bootcamp Registration Tracking`, `publisher` =
`OnlyCopilotFans`, `idRanges` = `60800–60899`, `runtime` `17.0`, `application` `28.0.0.0`,
`features` `["NoImplicitWith"]`, brief/description). `src/` module folders created (`Foundation`,
`Bootcamp`, `Attendee`, `Api`, `Setup`, `RoleCenter`, `Permissions`), plus `out/` (git-ignored,
never pruned). `.gitignore` keeps `.alpackages/` tracked for a reproducible build. `git init`,
branch `build/bootcamp-registration`, baseline commit `7e71b33`. `docs/BuildPlan.md` records the
batch order, the pre-flight checklist (P-1…P-14), and a **compilation-route decision** (no local
.NET runtime → cannot run `alc` here; options A/B/C in BuildPlan §3).

**Files affected:** `app.json`, `.gitignore`, `src/**` (folders), `out/README.md`,
`docs/BuildPlan.md`, `docs/ProjectMemory.md`.

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-01 — Pre-release version scheme

**Problem:** The scaffold's `app.json` carried `version` `1.0.0.0`, implying a shipped release
while the app is still in test.

**Root cause:** Default value left in place from the scaffold template (BUILD-00).

**Resolution:** AJ decided on 2026-09-10: start at **`0.0.1.0`** for the test cycle and
increment from there (Revision/Build as re-verification packages land, Minor for feature
batches). Roll to **`1.0.0.0`** at go-live. `app.json` `version` set to `0.0.1.0`.

**Files affected:** `app.json`.

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-02 — Permission sets must ship from Batch 1 (PTE0004)

**Problem:** Publishing Batch 1 (Foundation) to the sandbox failed:
`error PTE0004: Table 60801 'ocpfBootcampRegSetup' is missing a matching permission set`. The
TDD §3 batch plan delivered both permission sets in Batch 5.

**Root cause:** BC SaaS PTE deployment validation requires **every table in the published
package** to be covered by a permission set contained in the same extension — enforced on every
publish, not only the final one. The batch plan treated permission sets as a last-batch
deliverable, which is valid for offline `alc` compilation but not for the chosen compile route
(each batch is published to a sandbox). Nothing in Sanity Check tied the permission-set delivery
batch to the per-publish coverage rule.

**Resolution:**
- **Permission-set delivery moved to Batch 1.** `60890 "OCPF - Bootcamp Read"` and
  `60891 "OCPF - Bootcamp Edit"` created in `src/Permissions/`, scoped for now to
  `tabledata "ocpfBootcampRegSetup"` only (`R` / `IMD`). Each later batch that adds a table adds
  the matching `tabledata` line: Batch 2 will add `ocpfBootcamp` and `ocpfAttendee`.
- Batch 5 no longer *introduces* the permission sets — it does a final review/top-up only.
- New pre-flight check **P-15**: every table introduced in a batch has a matching `tabledata`
  line in a permission set shipped in the same batch.
- Also fixed in this batch: 4 Foundation source files renamed to the `ocpf`-prefixed object name
  (`ocpfBootcampStatus.Enum.al` etc.) to clear CodeCop `AA0215`.
- Compile route: `alc.dll` is run from the terminal against the .NET 10 runtime the VS Code
  `.NET Install Tool` extension had already provisioned for the AL extension
  (`~/Library/Application Support/Code/.../ms-dotnettools.vscode-dotnet-runtime/.dotnet/10.0.12~arm64~aspnetcore/dotnet`).
  No runtime installed on the machine. Supersedes BuildPlan §3 Option A.

**Files affected:** `src/Permissions/ocpfBootcampRead.PermissionSet.al` (new),
`src/Permissions/ocpfBootcampEdit.PermissionSet.al` (new), `src/Foundation/*.al` (renamed),
`docs/TDD.md` §3 / §10, `docs/BuildPlan.md` §1 / §3 / §4, `docs/ObjectRegister.md`.

**Updated:** TDD — yes (§3 batch plan, §10 pre-flight P-15). FRD — no.

---

## Issue BUILD-03 — Batch 1 (Foundation) compiles clean

**Problem:** n/a — planned batch delivery.

**Root cause:** n/a.

**Resolution:** Batch 1 delivered: `60800 ocpfBootcampStatus` (enum), `60801 ocpfBootcampRegSetup`
(table), `60802 ocpfBootcampRegSetup` (page), `60803 ocpfBootcampRegInstall` (codeunit, install
trigger + `EnsureSetup` only — Guided Experience registration deferred to Batch 5 per TDD §6.6),
`60890` / `60891` permission sets (per BUILD-02). 6 files compile with **0 errors / 0 warnings**
(CodeCop + UICop + PerTenantExtensionCop analyzers). `No. Series` (table 308) resolved
transitively from `application 28.0.0.0` — the BuildPlan §2.1 dependency risk did not
materialise; no explicit Business Foundation dependency needed.

**Files affected:** `src/Foundation/*.al` (4), `src/Permissions/*.al` (2).

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-04 — Batch 2 (core tables & logic): deviations + lint fixes

**Problem:** Building Batch 2 (`ocpfBootcamp` 60810, `ocpfAttendee` 60820, `ocpfBootcampRegMgt`
60813) surfaced four items:
1. TDD §6.3 / §6.4 put `LookupPageId` / `DrillDownPageId` (= the List pages) on the tables, but
   those pages are Batch 3 — a forward reference that will not compile in Batch 2.
2. TDD §4.5 overbooking rule (`Registered + 1 > Max Seats`) fires on every registration when
   `Max Seats` is left at 0 (unconfigured) — a Confirm dialog on every insert.
3. `warning AA0244`: codeunit-level `Bootcamp` var name collided with the `var Bootcamp`
   parameter of `InitBootcampNo`.
4. `warning AA0240`: the email-validation `Label` contained `name@example.com`, which CodeCop
   rejects (labels must not contain email addresses).

**Root cause:**
1. Sanity Check S-7 restructured batches for the mutual `FlowField` ↔ `TableRelation` reference
   but did not account for the tables also referencing their own List pages via
   `LookupPageId` / `DrillDownPageId`.
2. TDD took `Max Seats` literally as a hard number; 0 was never given a "no limit" meaning.
3. TDD §6.5 listed `Bootcamp` as a shared codeunit-level scratch var *and* used `Bootcamp` as a
   record parameter name in two procedures.
4. Example address written into a user-facing label out of habit.

**Resolution (AJ approved items 1 & 2 on 2026-09-10):**
1. `LookupPageId` / `DrillDownPageId` **deferred to Batch 3** — added to both tables when the
   List pages are created. Tables compile clean without them; final wiring is identical.
2. `ConfirmOverbookingIfNeeded` treats `Max Seats <= 0` as **no cap** and returns without
   warning. FRD F-10 intent ("warn but allow") is preserved for configured bootcamps.
3. Removed the shared `Bootcamp` codeunit var; `SeedAmountPaid`, `ConfirmOverbookingIfNeeded`,
   and `UpdateSeatsRemaining` each declare a **local** `Bootcamp: Record "ocpfBootcamp"`. This
   also removes shared mutable state between calls — strictly better than the TDD's shared var.
4. Email label reworded to `'The email address "%1" is not valid. Enter a name, an at sign, and
   a domain that contains a dot.'` — no literal address.
- Also added (defensive, not in TDD): each of the four `ocpfAttendee` event subscribers begins
  `if Rec.IsTemporary() then exit;` so seat maintenance never runs against temporary records.
- Permission sets 60890 / 60891 grown with `tabledata "ocpfBootcamp"` and
  `tabledata "ocpfAttendee"` (P-15).

Batch 2 — 9 files — compiles **0 errors / 0 warnings** (CodeCop + UICop + PerTenantExtensionCop).

**Files affected:** `src/Bootcamp/ocpfBootcamp.Table.al` (new),
`src/Attendee/ocpfAttendee.Table.al` (new), `src/Bootcamp/ocpfBootcampRegMgt.Codeunit.al` (new),
`src/Permissions/*.al` (grown), `docs/TDD.md` §6.3 / §6.4 / §6.5 (deferral + `Max Seats` 0
semantics + local-var note), `docs/ObjectRegister.md`.

**Updated:** TDD — yes. FRD — no (F-10 intent unchanged; the 0 = no-cap clarification noted in
TDD only).

---

## Issue BUILD-05 — Batch 3 (in-client pages) compiles clean

**Problem:** n/a — planned batch delivery.

**Root cause:** n/a.

**Resolution:** Batch 3 delivered: `60822 ocpfAttendeeSubform` (ListPart), `60821 ocpfAttendeeList`
(List), `60811 ocpfBootcampList` (List, `CardPageId` + `Attendees` navigation action),
`60812 ocpfBootcampCard` (Card, `General` + `Capacity & Pricing` groups + `ocpfAttendeeSubform`
part). `LookupPageId` / `DrillDownPageId` added to `ocpfBootcamp` (→ `ocpfBootcampList`) and
`ocpfAttendee` (→ `ocpfAttendeeList`) per the BUILD-04 deferral. Every page field carries
`ApplicationArea = All` + a `Specifies…` `ToolTip` (P-7).

Minor: `info AW0006` on the Card ("should use UsageCategory to be searchable") resolved with
`UsageCategory = None` — a Card reached only via `CardPageId` is intentionally not in Tell Me.
Not in TDD §6.9; conventional completion of the page, not a design change.

Batch 3 — 13 files — compiles **0 errors / 0 warnings**.

**Files affected:** `src/Attendee/ocpfAttendeeSubform.Page.al` (new),
`src/Attendee/ocpfAttendeeList.Page.al` (new), `src/Bootcamp/ocpfBootcampList.Page.al` (new),
`src/Bootcamp/ocpfBootcampCard.Page.al` (new), `src/Bootcamp/ocpfBootcamp.Table.al` +
`src/Attendee/ocpfAttendee.Table.al` (LookupPageId/DrillDownPageId), `docs/ObjectRegister.md`.

**Updated:** TDD — no (§6.9 `UsageCategory = None` is within the standard template). FRD — no.

---

## Issue BUILD-06 — Batch 4 (API pages): AA0101 vs. Standards §1.3 API naming

**Problem:** `60830 ocpfBootcamps` and `60831 ocpfAttendees` compiled with 4×
`warning AA0101: For pages of the type API the value of properties APIPublisher, APIGroup,
EntityName, and EntitySetName should be camel-cased`, against `APIPublisher = 'OnlyCopilotFans'`
and `APIGroup = 'ocpf_bootcampRegistration'` — both taken verbatim from Project Parameters /
Standards §1.3 (`APIPublisher = '<Publisher>'`; `APIGroup = '<prefix>_<camelCaseGroupName>'`).
`EntityName`/`EntitySetName` (`ocpfBootcamp`/`ocpfBootcamps` etc.) were already camelCase and not
flagged.

**Root cause:** Standards §1.3's `APIPublisher` pattern reuses the PascalCase `Publisher` value
verbatim, and its `APIGroup` pattern mandates a `<prefix>_` separator — CodeCop AA0101 requires
full camelCase with no underscore for both properties. The two authoritative sources (project
Standards and the project's own zero-warnings linter policy) disagree; nothing in DESIGN caught
it because TDD §1/§9.1 copied Part 1's literal example values without compiling them.

**Resolution:** AJ decided on 2026-09-10: **follow AA0101**, not the Standards §1.3 literal
example.
- `APIPublisher`: `'OnlyCopilotFans'` → `'onlyCopilotFans'`.
- `APIGroup`: `'ocpf_bootcampRegistration'` → `'ocpfBootcampRegistration'` (drops the `ocpf_`
  separator entirely).
- This changes the API URL for this app to `/api/onlyCopilotFans/ocpfBootcampRegistration/v1.0/…`
  — no longer sharing an `ocpf_` group namespace convention with any other OnlyCopilotFans app
  that follows the Standards §1.3 pattern literally. **Standards §1.3 itself is not amended by
  this entry** — this is a per-project divergence, recorded here and in `TDD.md` §1/§9.1; a
  future project should re-decide, not assume this precedent.

Batch 4 — 15 files — compiles **0 errors / 0 warnings**.

**Files affected:** `src/Api/ocpfBootcamps.Page.al` (new), `src/Api/ocpfAttendees.Page.al` (new),
`docs/TDD.md` §1, §9.1.

**Updated:** TDD — yes (§1, §9.1). FRD — no.

---

## Issue BUILD-07 — Batch 5 (Wizard, Navigation, Permissions) — full extension compiles clean

**Problem:** n/a — planned final batch delivery.

**Root cause:** n/a.

**Resolution:** Batch 5 delivered: `60840 ocpfBootcampRegSetupWizard` (NavigatePage; Welcome →
Numbering → Sample Data → Finish steps; `CreateDefaultSeriesIfBlank` creates `No. Series` +
`No. Series Line` `BOOTCAMP`/`ATTENDEE` when a series is left blank and the user consents;
`CreateSampleBootcamps` inserts the two sample bootcamps on Finish if selected), `60841
ocpfBusinessMgrRCExt` (extends Business Manager Role Center, `addlast(sections)`), and the
revisit of `60803 ocpfBootcampRegInstall` to add `RegisterAssistedSetup` (calls
`GuidedExperience.InsertAssistedSetup`, guarded by `IsAssistedSetupComplete`). Also added the
`RunAssistedSetup` action to `60802 ocpfBootcampRegSetup` (Setup card page) per TDD §6.7, which
had been deferred since the wizard page it runs didn't exist before this batch. Permission sets
`60890`/`60891` reviewed — no further `tabledata` lines needed; full object set covered.

Two lint items resolved during generation (not in TDD, both mechanical):
- `warning AL0482`: `Image = Persons` is not a recognized image name on this control; also tried
  `Person` (also invalid in this context) before landing on the valid `Image = ContactPerson`
  (verified against Base Application usage).
- A real logic bug caught before it ever compiled/ran: `CreateSampleBootcamps` originally set
  fields via `Bootcamp.Insert(true)` **then** `Bootcamp.Validate("Max Seats", 20)`. Because
  `ocpfBootcampRegMgt.UpdateSeatsRemaining` (fired from that `OnValidate`) re-`Get`s the bootcamp
  from the database into its own local record, it would have computed `Seats Remaining` against
  the **not-yet-persisted** `Max Seats` (still 0 in the DB) and wrongly persisted `Seats
  Remaining = 0`; a later `Bootcamp.Modify(true)` from the caller would then have overwritten the
  DB row with the caller's stale in-memory `Seats Remaining` (also 0) instead of 20. Fixed by
  setting every field **before** the single `Insert(true)` call, so `OnInsert`'s `"Seats
  Remaining" := "Max Seats"` runs against the correct value in one pass — no `Validate` call, no
  second record instance, no staleness window.

This is exactly the class of bug the runbook's "one procedure, one authoritative recompute path"
design for `UpdateSeatsRemaining` was meant to prevent for *user* edits (§4.3) — it did not
anticipate a caller using `Insert()` + `Validate()` instead of setting fields pre-insert. No TDD
change needed: the fix is in the wizard's use of the table, not in the table's contract.

**All 17 planned objects now built. Full extension — 17 files — compiles 0 errors / 0 warnings**
(CodeCop + UICop + PerTenantExtensionCop).

**Files affected:** `src/Setup/ocpfBootcampRegSetupWizard.Page.al` (new),
`src/RoleCenter/ocpfBusinessMgrRCExt.PageExt.al` (new),
`src/Foundation/ocpfBootcampRegInstall.Codeunit.al` (RegisterAssistedSetup added),
`src/Foundation/ocpfBootcampRegSetup.Page.al` (RunAssistedSetup action added),
`docs/ObjectRegister.md`.

**Updated:** TDD — no. FRD — no.

**Correction, 2026-09-13 (Step 08, `GapAnalysis.md` G-07):** this entry's "Updated: TDD — no" was
wrong for the `Image=Persons` → `Image=ContactPerson` fix described above — TDD §6.15 still
showed the original, invalid `Image=Persons` value until Step 08 corrected it. A developer
regenerating `ocpfBusinessMgrRCExt` from the TDD alone, without reading this ChangeLog entry,
would have reproduced the same `AL0482` compile error this issue describes fixing. Not rewriting
the original line above — recording the correction here instead, per the same
mark-don't-rewrite convention used for superseded diagnoses.

---

## Issue BUILD-08 — First package built

**Problem:** n/a — first packaging milestone after all 5 batches compiled clean.

**Root cause:** n/a.

**Resolution:** AJ requested packaging only (no sandbox publish yet). Built
`out/Bootcamp_Registration_Tracking_0.0.1.0.app` — name and version read from `app.json` at
build time (`name` → spaces to underscores, `version` verbatim), per the runbook's fixed naming
rule. Version stays `0.0.1.0` (BUILD-01) — this is the first package of the test cycle, not a
bump. 17 files, 0 errors / 0 warnings. Not published to any sandbox.

**Files affected:** `out/Bootcamp_Registration_Tracking_0.0.1.0.app` (new; git-ignored, per
policy no previous package was touched — none existed yet).

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-09 — Gap-fill: Role Center Activity Cues

**Problem:** The app had no Activity Cue tiles on the Business Manager Role Center. AJ asked
directly (2026-09-12) whether the app had any; it did not.

**Root cause:** Not a defect against the original spec — Activity Cues were never in FRD/TDD
scope, and this project's DEFINE/DESIGN phases predate CLAUDE.md §1.6 (Onboarding &
Discoverability), which now asks this exact question at intake. **Classification (Step 08-style,
ahead of the formal Gap-Fit Test): Oversight relative to the framework's own current standard,
not relative to the FRD** — genuinely useful, not scope creep, added by AJ's explicit request as
a gap-fill work item, same discipline as a main batch.

**Investigation (Standards §10.5 — verified against symbols, not memory):** `page 9022 "Business
Manager Role Center"` already renders cues via `part(Control16; "O365 Activities")` bound to
`table 1313 "Activities Cue"` (`Microsoft.RoleCenters`). The standard BC pattern for a PTE to add
cues to a Role Center that already uses this part is a `tableextension` on 1313 (new fields) +
a `pageextension` on `page 1310 "O365 Activities"` (a new `cuegroup`) — not a new custom cue
table/page. Confirmed against Microsoft's own `ActivitiesCue.Table.al` / `O365Activities.Page.al`
source: date-relative cues ("Sales This Month") are **plain stored fields recomputed on page
open**, not FlowFields with date-relative FlowFilters — CalcFormula filters can't reference
runtime-relative dates like Today. Microsoft's own implementation adds page-background-task
caching on top of that for its scale; deliberately **not** replicated here — this app's data
volume doesn't need it, and copying that machinery blind would have been the wrong kind of
risk for what it buys.

**Resolution:** 5 cues chosen by AJ (all three recommended options plus two of AJ's own):

| Cue | Pattern | Drill-down |
|---|---|---|
| Active Bootcamps | FlowField, `count(... where(Status = const(Active)))` | `ocpfBootcampList` filtered to Active |
| Unpaid Registrations | FlowField, `count(... where(Paid = const(false)))` | `ocpfAttendeeList` filtered to unpaid |
| Below Min Seats (Go/No-Go) | Plain field, computed — needs `Registered Attendees < Min Seats` (field-to-field, not FlowField-expressible) | `ocpfBootcampList` filtered to Active |
| Registrations This Month | Plain field, computed — proxy: `SystemCreatedAt` in the current calendar month (no explicit registration-date field exists on `ocpfAttendee`) | `ocpfAttendeeList` |
| Bootcamp Revenue This Month | Plain field, computed — sum of `Amount Paid` where `Paid = true` and `Payment Date` in the current month | `ocpfAttendeeList` |

Built as `60842 tableextension "ocpfActivitiesCueExt"` (5 new fields, IDs 60800–60804 — a
separate ID space scoped to table 1313, chosen to match this project's numeric identity, no
collision with 1313's own fields which top out at 110), `60843 codeunit
"ocpfActivityCueMgt"` (`UpdateCues` + 3 local calculation procedures), `60844 pageextension
"ocpfO365ActivitiesExt"` (adds `cuegroup` via `addlast(content)`; `trigger OnAfterGetRecord()`
calls `UpdateCues` — a pageextension's own trigger body runs additively after the base page's,
standard AL behavior). All 3 IDs from the M5 sub-block (60840–60859), well within its buffer.

**No permission-set change needed** — confirmed by a clean compile, not assumed: a
`tableextension` doesn't introduce a new table, so `PTE0004` doesn't apply; `Activities Cue` is
already readable by every user since it drives their own Role Center.

Full extension — 20 files — compiles **0 errors / 0 warnings**.

**Files affected:** `src/RoleCenter/ocpfActivitiesCueExt.TableExt.al` (new),
`src/RoleCenter/ocpfActivityCueMgt.Codeunit.al` (new),
`src/RoleCenter/ocpfO365ActivitiesExt.PageExt.al` (new), `docs/ObjectRegister.md`.

**Updated:** TDD — no (a formal Step 08 `GapAnalysis.md` will fold this in when that step runs
for the whole project; this entry is the ground truth until then). FRD — no.

---

## Issue BUILD-10 — Version bump for BUILD-09 (Build-position override)

**Problem:** BUILD-09 (Activity Cues) added new functionality but had no version bump proposed
yet.

**Root cause:** n/a — routine packaging/versioning step (ALL ALONG policy).

**Resolution:** Proposed **Minor** (`0.1.0.0`) per the scheme recorded in BUILD-01 ("Minor for
feature batches"). AJ decided **`0.0.2.0`** (Build-position) instead on 2026-09-12 — a deliberate
override of that recommendation, confirmed after the mismatch was named: the pre-1.0 test cycle
is being treated as flat sequential build numbers regardless of feature vs. non-feature content,
not the Major/Minor/Build/Revision semantics that will apply from `1.0.0.0` onward. `app.json`
`version` set to `0.0.2.0`.

**Files affected:** `app.json`.

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-11 — TestingFeedback triage: sample-bootcamp "already exists" (data, not code)

**⚠️ Superseded by BUILD-13 — the classification below was wrong.** Recorded here anyway, not
deleted: it was AJ's and this agent's honest read of the evidence available at the time, and the
correction (BUILD-13) only exists because AJ pushed back with a fact that didn't fit it. Erasing
the wrong turn would erase the reason the right one was found.

**Problem:** `TestingFeedback.md` (2026-09-12 session) — Assisted Setup Wizard's sample-bootcamp
creation errors "a record already exists" at the Bootcamp No. series' first available number.

**Root cause (as understood at the time — since revised, see BUILD-13):** AJ had reset the
Bootcamp No. series but a `ocpfBootcamp` record from earlier testing still existed at that
series' starting number. Manual entry or a series reset does not un-claim a number already used
by an existing row — only `GetNextNo()` tracks "Last No. Used", so resetting the counter without
also clearing (or accounting for) records that already used it makes the platform reissue an
already-taken number. This is standard BC number-series behavior, not unique to this app (the
same thing happens with Sales Orders under the same conditions) — **classified Environment/data
state, not a code defect.**

**Resolution (superseded):** No code change for the collision itself. AJ to delete the
conflicting `ocpfBootcamp` record (or advance the series past it) in the sandbox before
re-running the wizard's sample-data step.

**Why this was wrong:** AJ then confirmed (a) the `ocpfBootcamp` table was verified empty
(everything deleted), and (b) a **brand-new** No. Series, created fresh with new Code/Starting
No./Ending No., produced the exact same "already exists" error on its very first use. An empty
table cannot contain a pre-existing row for a number series had never issued a number from
before. The stale-data theory could not survive that fact.

**Files affected:** none.

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-12 — Fix: subform insert leaves Attendee with blank Bootcamp No.

**⚠️ Superseded by BUILD-16 — this fix was a provable no-op.** `Rec.GetFilter("Bootcamp No.")`
was called without switching to filter group 4 first, so it read the wrong group and never
returned anything but blank. Kept here, not deleted — see BUILD-16 for the corrected fix.

**Problem:** `TestingFeedback.md` (2026-09-12 session) — creating a new Bootcamp, filling in its
header fields, then adding an Attendee line via the embedded `ocpfAttendeeSubform` produces "the
view is filtered, and the entry is outside the filter." The Attendee record is nonetheless
created, with `"Bootcamp No."` **blank** — confirmed by AJ, not assumed.

**Root cause:** `part(Attendees; "ocpfAttendeeSubform") { SubPageLink = "Bootcamp No." =
field("No."); }` normally auto-populates the child's linking field on a new subform row. That
automatic propagation did not reliably stick through to the actual insert here — a known category
of BC gotcha where a subform's `DelayedInsert = true` (needed so typing into a new attendee row
doesn't insert prematurely, per TDD §6.11) can defer the physical `Insert()` past the point where
the runtime still associates the auto-filled value with that specific pending record buffer. The
exact platform-internal trigger for *why* the auto-fill didn't stick isn't verifiable without a
live debugging session (none available); the fix below is the standard, textbook-documented
remedy for this exact symptom class regardless of the precise internal timing cause, and is
inert when the automatic propagation *does* work (the guard only fires when the field is still
blank).

**Resolution:** Added `trigger OnNewRecord(BelowxRec: Boolean)` to `ocpfAttendeeSubform`: if
`Rec."Bootcamp No."` is blank, read it explicitly from the subform's own active filter
(`Rec.GetFilter("Bootcamp No.")` — that filter is exactly what `SubPageLink` establishes) and
assign it. This defends against the propagation timing issue without changing `DelayedInsert`,
`AutoSplitKey`, or `UpdatePropagation`.

Full extension — 20 files — compiles **0 errors / 0 warnings**.

**Files affected:** `src/Attendee/ocpfAttendeeSubform.Page.al`.

**Updated:** TDD — yes (§6.11, `OnNewRecord` pattern recorded, with a note to apply the same
guard to any future `ListPart` with a non-key `SubPageLink` field). FRD — no.

---

## Issue BUILD-13 — Corrected diagnosis + fix: sample-bootcamp number collision

**⚠️ Superseded by BUILD-16 — this diagnosis was also wrong.** `InitBootcampNo` was never called
on the colliding second insert at all (`Record.Init()` doesn't clear the primary key, so the
guard that triggers `InitBootcampNo` never fired) — the self-healing loop below lived inside a
procedure the bug never reached. Kept here, not deleted — see BUILD-16 for the corrected fix.

**Problem:** Same symptom as BUILD-11 (Assisted Setup Wizard sample-bootcamp creation errors
"Bootcamp already exists" at the series' first-available number), but BUILD-11's diagnosis
(stale leftover data) was disproved by AJ: `ocpfBootcamp` confirmed empty, and a **brand-new**
No. Series with a fresh Code/Starting No./Ending No. reproduced the identical error on its very
first-ever use (`No.='B10001'`).

**Root cause:** Confirmed against the actual BC v28.4 `"No. Series - Stateless Impl."` (codeunit
306) source: `GetNextNo` re-reads the `No. Series Line` with an update lock and writes
`"Last No. Used"` back immediately on every call — textbook-correct for sequential calls, and
this agent could not identify a defect in that platform code from static reading alone (no live
sandbox available to this agent to attach and observe directly). The evidence is nonetheless
conclusive about the *mechanism*, even without pinning the exact platform-internal trigger: an
empty table plus an "already exists" error naming the series' brand-new starting number is only
possible if `ocpfBootcampRegMgt.InitBootcampNo` computed **the same number for both sample
bootcamps**, the second `Insert()` collided with the first (still-uncommitted) row, and the
resulting unhandled error rolled back the entire wizard transaction — undoing the first,
otherwise-successful insert too. That fully explains both of AJ's independent reproductions
(old series, then a brand-new one) without requiring stale data.

**Resolution:** Made number assignment self-healing rather than continuing to chase the exact
platform trigger. `ocpfBootcampRegMgt.InitBootcampNo` / `InitAttendeeNo` now check whether the
number `GetNextNo()` returned is already taken (via a lookup on a *separate* record variable,
never the one being inserted, to avoid clobbering its in-progress field values) and keep
requesting the next number until they find one that is actually free:

```
CandidateNo := NoSeries.GetNextNo(Setup."Bootcamp Nos.");
while ExistingBootcamp.Get(CandidateNo) do
    CandidateNo := NoSeries.GetNextNo(Setup."Bootcamp Nos.");
Bootcamp."No." := CandidateNo;
```

This resolves the reported failure regardless of which platform-internal condition caused the
duplicate, is inert in the normal case (the loop runs zero times when the number is free, which
is true almost always), and terminates naturally on a genuinely exhausted series (`GetNextNo`
itself raises the "no more numbers" error, which was always going to happen at exhaustion
regardless of this change).

Full extension — 20 files — compiles **0 errors / 0 warnings**.

**Files affected:** `src/Bootcamp/ocpfBootcampRegMgt.Codeunit.al`.

**Updated:** TDD — yes (§6.5, self-healing number-assignment pattern recorded). FRD — no.

---

## Issue BUILD-14 — Package built at 0.0.2.0 (includes BUILD-09..13)

**Problem:** n/a — routine packaging after BUILD-09 (Activity Cues), BUILD-10 (version bump),
BUILD-12 (blank Bootcamp No. fix), and BUILD-13 (self-healing numbering) had accumulated without
a package to test them.

**Root cause:** n/a.

**Resolution:** Built `out/Bootcamp_Registration_Tracking_0.0.2.0.app` — name and version read
from `app.json` at build time, per the fixed naming rule. The prior `0.0.1.0` package was left
untouched next to it (never delete a previous package). 20 files, 0 errors / 0 warnings. Not yet
published to any sandbox; neither BUILD-12 nor BUILD-13's fix has been retested live.

**Files affected:** `out/Bootcamp_Registration_Tracking_0.0.2.0.app` (new; git-ignored).

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-15 — Version bumped directly to 0.0.3.0 (AJ)

**Problem:** n/a.

**Root cause:** n/a — AJ edited `app.json` directly (outside this agent's session) to
`0.0.3.0`, presumably while publishing/testing the `0.0.2.0` package. Consistent with the flat
sequential pre-1.0 build-number scheme (BUILD-10); not flagged as a mismatch.

**Resolution:** Recorded here for continuity; no package has yet been built at `0.0.3.0`.

**Files affected:** `app.json`.

**Updated:** TDD — no. FRD — no.

---

## Issue BUILD-16 — Both BUILD-12 and BUILD-13 were wrong; corrected diagnoses + real fixes

**⚠️ Supersedes BUILD-12 and BUILD-13 — both marked superseded below, not deleted.** AJ retested
the `0.0.3.0` build live in BC after it was published (with BUILD-09's Activity Cues, BUILD-12,
and BUILD-13 all present in the compiled source) and reported, verbatim (`TestingFeedback.md`):
*"I got the activity cues. But neither of the two issues were resolved."* Per §1.7, diagnosis
routed to the reasoning role (a dedicated Opus review) rather than patched again on a guess — the
same discipline that caught BUILD-11's wrong diagnosis. Both root causes below were independently
verified by the main-role agent against official Microsoft Learn documentation before being
applied, not taken on the sub-agent's word alone.

### Bug 1 — Sample-bootcamp "already exists" (BUILD-13 superseded)

**BUILD-13's diagnosis was wrong.** It assumed `NoSeries.GetNextNo` was returning the same number
for both sample bootcamps, and "fixed" this with a self-healing retry loop in
`InitBootcampNo`/`InitAttendeeNo`. That loop could never have worked, because `InitBootcampNo` is
never called on the second insert at all.

**Actual root cause, verified against Microsoft Learn's `Record.Init()` reference (quoted
verbatim): "Primary key and timestamp fields aren't initialized."** `CreateSampleBootcamps` (in
the Setup Wizard) reuses one `Bootcamp` record variable for both inserts:
1. `Bootcamp.Insert(true)` — `Rec."No." = ''` → `InitBootcampNo` assigns e.g. `B10001`. Succeeds.
2. `Bootcamp.Init()` clears Topic/Price/etc. but **not** `"No."` — it's the primary key, and
   `Init()` explicitly does not touch primary key fields. The buffer still holds `B10001`.
3. Second `Bootcamp.Insert(true)` — `Rec."No." <> ''` now, so `InitBootcampNo` is **skipped
   entirely** — the platform attempts to insert `B10001` again → "already exists."
4. The unhandled error rolls back the whole wizard transaction, undoing insert #1 — explaining
   why AJ found the table empty afterward, and why a brand-new never-used series reproduced the
   identical error (BUILD-11's disproof stands; the mechanism just wasn't what BUILD-13 guessed).

**Resolution:** `CreateSampleBootcamps` now explicitly clears `Bootcamp."No." := '';` after each
`Bootcamp.Init()` call, before setting the other fields. **BUILD-13's self-healing retry loop was
reverted** (AJ Ansari, 2026-09-12) — it solved a problem that never existed via this path, and the
project's own Standards forbid unnecessary/dead code; `InitBootcampNo`/`InitAttendeeNo` are back
to a plain `GetNextNo` assignment.

### Bug 2 — Attendee gets blank Bootcamp No. / "the view is filtered" (BUILD-12 superseded)

**BUILD-12's fix was a provable no-op.** It read `Rec.GetFilter("Bootcamp No.")` in the subform's
`OnNewRecord` without first switching filter groups. Verified against Microsoft Learn's
`Record.FilterGroup()` reference (quoted verbatim): filter group **4 ("Link")** is *"used for the
filtering actions that result from... the SubPageLink Property"* — not group 0 (the default
`GetFilter` reads). The `SubPageLink` filter was never in the group BUILD-12's code was reading;
the assignment was always blank-into-blank.

**Resolution (three parts, all applied):**
1. `ocpfAttendeeSubform.OnNewRecord` now switches to filter group 4 before calling `GetFilter`,
   restoring the previous group afterward.
2. Added a hidden `field("Bootcamp No."; Rec."Bootcamp No.") { Visible = false; }` control to the
   subform's repeater — matching the standard BC pattern (e.g. `Job Task Lines Subform`, which
   always exposes its link field, just hidden).
3. Added `Rec.TestField("Bootcamp No.");` as the first line of `ocpfAttendee.OnInsert` — if the
   link is ever genuinely blank (a second candidate cause the reasoning-role review could not
   fully rule out without a live discriminating test — see below), this now fails loudly with a
   clear, actionable error instead of silently saving a corrupt orphan row.

**Open question, not yet resolved:** whether fix 1 alone was sufficient, or whether the header
(the new Bootcamp) genuinely wasn't committed yet when AJ added the attendee line — in which case
the `TestField` guard in part 3 will fire on retest, and a further fix would be needed on
`ocpfBootcampCard` (the header side), not the subform. **AJ to retest** and report whether: (a) it
now works cleanly, or (b) the new `TestField` error fires (which would confirm the header-timing
theory and point to where the next fix belongs). Also: any existing orphan Attendee rows with a
blank `"Bootcamp No."` from earlier testing should be deleted from the unfiltered Attendees list
before retesting — they're invisible in every filtered view and would confuse the result.

### Also fixed: `.bcquality/` was breaking every compile

Unrelated to either bug, but discovered while re-running the local compile to verify these fixes:
`.bcquality/` (fetched under BUILD-09-era work, actually a project-tooling snapshot, not tracked
in this ChangeLog until now) sat inside this AL project's own root folder, and `alc` recursively
compiles every `.al` file under the project root with no exclusion mechanism — BCQuality's
illustrative `.good.al`/`.bad.al` knowledge snippets aren't real compilable objects, so the
compile was producing 470+ unrelated syntax errors. Moved to `../BootcampClaude.bcquality/`
(outside the project root entirely); runbook updated with this as a general lesson, not just a
one-off fix.

Full extension — 20 files — compiles **0 errors / 0 warnings** with all of the above applied.

**Files affected:** `src/Setup/ocpfBootcampRegSetupWizard.Page.al`,
`src/Attendee/ocpfAttendeeSubform.Page.al`, `src/Attendee/ocpfAttendee.Table.al`,
`src/Bootcamp/ocpfBootcampRegMgt.Codeunit.al`, `.gitignore`, `.bcquality/` → relocated.

**Updated:** TDD — yes (§6.5, §6.11, §6.14). FRD — no.

## Issue BUILD-17 — Package built at 0.0.3.0 (includes BUILD-16)

**Problem:** n/a — routine packaging. `app.json` had already been bumped to `0.0.3.0` by AJ
(BUILD-15) with no package built at that version yet; BUILD-16's fixes needed a package to be
retested live. AJ said "Build it."

**Root cause:** n/a.

**Resolution:** Re-compiled the full extension clean (20 files, 0 errors / 0 warnings) as a
pre-check, then built `out/Bootcamp_Registration_Tracking_0.0.3.0.app` — name and version read
from `app.json` at build time, per the fixed naming rule. The prior `0.0.1.0` and `0.0.2.0`
packages were left untouched next to it (never delete a previous package). Not yet published to
any sandbox — AJ still needs to publish this build and run the BUILD-16 retest, including the
Bug 2 discriminating test (add a line to an already-saved/reopened bootcamp vs. a brand-new one)
and cleaning up orphan Attendee rows with blank Bootcamp No. from earlier testing first.

**Files affected:** `out/Bootcamp_Registration_Tracking_0.0.3.0.app` (new; git-ignored).

**Updated:** TDD — no. FRD — no.

## Issue BUILD-18 — Output folder renamed `out/` → `outputAppPackage/`; Force Sync guidance added

**Problem:** AJ asked that the framework's runbook (1) fix the output-folder name as
`outputAppPackage/` rather than the ad hoc `out/` this project had been using, (2) have the agent
state that folder name plainly at intake and again at every completed build, and (3) always tell
the human whether a completed build needs to be uploaded with Business Central's **Force Sync**
schema option.

**Root cause:** n/a — a runbook/process improvement request, not a defect.

**Resolution:** `CLAUDE.md` updated (framework-level, gitignored in this project per §1.8, not
committed here) — see `RunbookChangelog.md` for the full entry. Summary: `outputAppPackage/` is
now the framework's fixed output-folder name (Packaging & Versioning), mentioned once at intake
(Step 01) and restated plainly at every completed build (Step 09 and any later ad hoc
repackage); a new Force Sync bullet requires flagging, on every completed build, whether its
schema changes are additive-only (safe under BC's default **Add** Schema Sync Mode on the
Extension Management page/admin center) or destructive (needs **Force Sync**, which can cause
data loss) — verified against current Microsoft Learn/release-plan documentation before being
written in, not asserted from memory.

Applied to this project: physically renamed `out/` → `outputAppPackage/` (`git mv` for the
tracked `README.md`; plain `mv` for the three `.app` packages, which are gitignored). All three
prior packages — `0.0.1.0`, `0.0.2.0`, and BUILD-17's `0.0.3.0` — now live at
`outputAppPackage/Bootcamp_Registration_Tracking_<version>.app`; none were deleted. Deleted only
`out/_compile_check.app`, a disposable, unversioned scratch compile-check artifact regenerated by
the compile wrapper on every run, not one of the named release packages the never-delete policy
protects. `.gitignore` updated (`out/*.app` → `outputAppPackage/*.app`).

**Retroactive Force Sync check for BUILD-17's `0.0.3.0` package:** BUILD-16's fixes touched no
table schema at all — no fields or tables added, removed, resized, or retyped; the changes were a
hidden page-level field control, a `TestField` guard in a trigger, and a plain-assignment
procedure body. **This package is safe to upload with the default Add Schema Sync Mode — Force
Sync is not needed for this one.**

**Files affected:** `.gitignore`, `outputAppPackage/` (renamed from `out/`; `README.md` updated),
`out/_compile_check.app` (deleted, disposable). `CLAUDE.md`/`RunbookChangelog.md` (framework-level,
not committed to this project's repo).

**Updated:** TDD — no. FRD — no.

## Issue BUILD-19 — Version bumped directly to 0.0.4.0 (AJ)

**Problem:** n/a.

**Root cause:** n/a — AJ edited `app.json` directly (outside this agent's session) to `0.0.4.0`,
discovered when this session next inspected `git status`. Same pattern as BUILD-15. Consistent
with the flat sequential pre-1.0 build-number scheme (BUILD-10); not flagged as a mismatch.

**Resolution:** Recorded here for continuity. **No package has been built at `0.0.4.0` yet** —
BUILD-17's `outputAppPackage/Bootcamp_Registration_Tracking_0.0.3.0.app` is now one version
behind `app.json`. Flagged to AJ directly rather than silently rebuilding.

**Files affected:** `app.json`.

**Updated:** TDD — no. FRD — no.

## Issue BUILD-20 — Package built at 0.0.4.0

**Problem:** n/a — routine packaging. AJ confirmed the `0.0.4.0` bump (BUILD-19) and said "go
ahead and build a 0.0.4.0."

**Root cause:** n/a.

**Resolution:** Re-compiled the full extension clean (20 files, 0 errors / 0 warnings) as a
pre-check, then built `outputAppPackage/Bootcamp_Registration_Tracking_0.0.4.0.app` — name and
version read from `app.json` at build time. Prior packages (`0.0.1.0` through `0.0.3.0`) left
untouched next to it. **Schema Sync Mode check: no schema changes since `0.0.3.0` — safe to
upload with the default Add sync mode; Force Sync not needed.** Not yet published or retested
live.

**Files affected:** `outputAppPackage/Bootcamp_Registration_Tracking_0.0.4.0.app` (new;
git-ignored).

**Updated:** TDD — no. FRD — no.

## Issue BUILD-21 — BUILD-16 fixes confirmed live: both bugs closed

**Problem:** n/a — positive result. AJ retested `outputAppPackage/
Bootcamp_Registration_Tracking_0.0.4.0.app` on a BC sandbox and reported: "Good news - everything
tested well."

**Root cause:** n/a.

**Resolution:** Both bugs from the original testing round are now confirmed fixed on a live
retest, closing out the corrected diagnoses from BUILD-16:
- Sample-bootcamp "already exists" — `Bootcamp."No." := '';` after each reused `Init()` in
  `CreateSampleBootcamps` holds. Closes BUILD-11 (superseded) / BUILD-13 (superseded) / BUILD-16.
- Attendee line blank Bootcamp No. — the `FilterGroup(4)` read + hidden field control + `TestField`
  guard on `ocpfAttendeeSubform`/`ocpfAttendee` holds. Closes BUILD-12 (superseded) / BUILD-16.

One note carried forward rather than silently closed: AJ's report doesn't explicitly confirm
whether BUILD-16's discriminating test (line added to an already-saved/reopened bootcamp vs. a
brand-new one) was exercised as its own distinct case, or whether "everything" covers it
implicitly. Logged as presumed covered — flag back if either path turns out not to have been
tested. See `TestingFeedback.md` session 2026-09-13 for the full triage record.

**Files affected:** none (documentation only — `docs/TestingFeedback.md`, this entry).

**Updated:** TDD — no. FRD — no.

## Issue STEP08-01 — Gap-Fit Test run; one real code defect found (G-12)

**Problem:** Step 08 (Gap-Fit Test, Fidelity Validation) had not been run. Per §1.7, delegated to
an Opus reasoning-role subagent for a formal FRD vs. TDD vs. as-built three-way comparison, fed
`FRD.md`, `TDD.md`, `ObjectRegister.md`, `ChangeLog.md`, every `.al` file, `app.json`, and
`ProjectParameters.md`. Main role independently re-verified the one code-defect claim (G-12)
against `ocpfBootcamp.Table.al` and BC's own DelayedInsert/field-validation ordering before
trusting it, rather than taking the subagent's report on faith.

**Root cause:** n/a — this is the analysis step itself, not a fix. Full findings, classifications
and proposed resolutions are in `docs/GapAnalysis.md` (20 findings, G-01…G-20).

**Resolution:** `docs/GapAnalysis.md` created. Headline result: documentation is unusually
self-consistent and every prior superseded diagnosis is correctly retained — but **G-12 is a
genuine, independently-verified code defect**: `ocpfBootcamp."Max Seats".OnValidate` recomputes
`"Seats Remaining"` by `Get()`-ing a separate copy of the same record and calling `Modify(false)`
*before* the page/API's own pending write for the field just validated is committed — so the
helper reads the pre-change value and its write is immediately overwritten by the caller's own
save. Deterministic on a Card-created bootcamp whenever `Max Seats` isn't the very first field
entered (the common case), and on any edit to `Max Seats` on an existing bootcamp. Contradicts
FRD F-3/D-8. The wizard's two sample bootcamps look correct only because BUILD-07 already
worked around this same shape of bug *inside the wizard specifically*, by setting every field
before a single `Insert(true)` — masking the defect everywhere else a bootcamp is created or
edited normally.

Also found: five missing `ToolTip`s on the BUILD-09 Activity Cue gap-fill (D-5) — that batch
never ran a Step 05 pre-flight pass at all; a stale API-identity mismatch in the authoritative
`ProjectParameters.md` §1.3 (still shows the pre-BUILD-06 casing); a TDD code sample (§6.15) that
would reproduce a known, already-fixed compile error if regenerated from the TDD alone; and a
cluster of smaller documentation-only drift items (full list in `GapAnalysis.md`). See that
document for every finding, its classification (Intentional/Oversight/Spec stale), and proposed
resolution — code-touching fixes (G-12, G-13) are held for AJ's explicit approval per Operating
Rule 6 before being applied; documentation-only corrections are proposed to land in the same
pass once AJ confirms scope.

**Files affected:** `docs/GapAnalysis.md` (new).

**Updated:** TDD — no (pending — see `GapAnalysis.md` G-01/G-07/G-08/G-09/G-10/G-12). FRD — no
(pending — see `GapAnalysis.md` G-01/G-15/G-16).

## Issue STEP08-02 — All 20 Gap-Fit Test findings resolved

**Problem:** STEP08-01 found 20 documentation/code findings; AJ approved "Fix everything now"
(Recommended option) rather than deferring any of them.

**Root cause:** n/a — this is the resolution pass for STEP08-01's findings, not a new defect.

**Resolution:** All 20 findings applied:

- **Code fixes (Operating Rule 6 approval obtained first):**
  - **G-12** — `ocpfBootcamp."Max Seats".OnValidate` now computes `"Seats Remaining"` in memory
    directly on `Rec` (`Rec.CalcFields("Registered Attendees"); Rec."Seats Remaining" :=
    Rec."Max Seats" - Rec."Registered Attendees";`, guarded on `Rec."No." <> ''`) instead of
    calling `UpdateSeatsRemaining`, which re-`Get()`s the same record and reads a stale
    pre-change value. `UpdateSeatsRemaining` is unchanged and still correct for the four
    `ocpfAttendee` event subscribers, where reading committed state is correct.
  - **G-13** — added `ToolTip` to all 5 fields on `ocpfActivitiesCueExt.TableExt.al`.
  - **G-03** — `ocpfBootcampRegSetup.Page.al`: `UsageCategory = None` → `Administration`, so the
    Setup card is findable via Tell Me (closes an unasked CLAUDE.md §1.6 Q3).
  - Recompiled: **20 files, 0 errors / 0 warnings.**
- **Documentation-only corrections:**
  - `docs/FRD.md` — new F-16 (Activity Cues); F-10 + §6.1 Max Seats row get the "0 = no cap"
    semantic (G-15); D-5 scoped to non-API pages (G-16); §6.3/§6.4/§6.5 gain the three Activity
    Cue objects; §6.6 reworded from "read on all pages" to the actual tabledata-grant design
    (G-04).
  - `docs/TDD.md` — §2/§2.1 M5 module row and object register updated to 5 objects (was 2);
    new §6.18–§6.20 per-object specs for the three gap-fill objects (G-01); §6.3 field 7's rule
    corrected to describe the G-12 fix, including a "never re-`Get()` your own record inside its
    own `OnValidate`" generalizable note; §6.14 corrected to describe the wizard's actual
    hand-written navigation actions, not the originally-planned `actionref`s (G-08), and notes
    `Status`/`Location` rely on `InitValue`/blank (G-09); §6.15's code sample corrected from
    `Image=Persons` to `Image=ContactPerson` (G-07); §4.7's `SeedAmountPaid` note gains its
    as-built dangling-link guard (G-10); §11 traceability gains an F-16 row.
  - `docs/ProjectParameters.md` — §1.3 corrected to the shipped API identity
    (`'onlyCopilotFans'` / `'ocpfBootcampRegistration'`, per BUILD-06) instead of the
    pre-BUILD-06 values; stale §1.2 "must be rewritten" note corrected to past tense; new §1.6
    and §1.8 sections backfilled (never formally asked at intake, since those runbook sections
    didn't exist yet on 2026-09-10); exit-gate checklist and header corrected to reflect the
    sheet's actual confirmed status (G-17).
  - `docs/BuildPlan.md` — §2's stale "`version` stays `1.0.0.0`" corrected to the actual
    `0.0.1.0` pre-release scheme; `out/` → `outputAppPackage/` in §2's folder-structure and
    `.gitignore` rows; §3's historical compile-route narrative annotated (not rewritten) to note
    the later folder rename (G-18).
  - `docs/ObjectRegister.md` — object 60803's status corrected from "Batch 1 part: EnsureSetup
    only" to reflect BUILD-07's completion (G-19).
  - `docs/Roadmap.md` — **new file**, item R-1: no upgrade codeunit exists; scheduled, not fixed,
    with an explicit trigger for when to revisit (G-06).
  - `outputAppPackage/README.md` — noted that VS Code's own `AL: Package` command writes to the
    project root under different naming, not a mistake (G-20).
  - `docs/ChangeLog.md` — BUILD-07's "Updated: TDD — no" line amended with a correction note
    (not rewritten) now that TDD §6.15 has been fixed (G-07).
- **No action needed:** G-02 (deferred to `PostDevTDD.md` at Step 11, as originally proposed —
  minor as-built completions, nothing wrong); G-11 (confirmation only, not a gap).
- **Still deferred to Step 09** (verify live, then fix only if confirmed): **G-14** (cue
  read-permission on the Role Center — flagged as the one item with real blast radius if
  confirmed), G-04's page-execution permission test, G-05 (uninstall orphan check), G-03's Tell
  Me visibility (now testable since the `UsageCategory` fix landed).

This extension is now ready to proceed to **Step 10 (Code Review)**, with the four Step
09-deferred items above still outstanding before PROVE closes out.

**Files affected:** `docs/FRD.md`, `docs/TDD.md`, `docs/ProjectParameters.md`,
`docs/BuildPlan.md`, `docs/ObjectRegister.md`, `docs/Roadmap.md` (new),
`outputAppPackage/README.md`, `docs/GapAnalysis.md` (status updated), this entry;
`src/Bootcamp/ocpfBootcamp.Table.al`, `src/Foundation/ocpfBootcampRegSetup.Page.al`,
`src/RoleCenter/ocpfActivitiesCueExt.TableExt.al`.

**Updated:** TDD — yes (§2, §2.1, §6.3, §6.14, §6.15, §4.7, §6.18–§6.20, §11). FRD — yes (F-10,
F-16, D-5, §6.1, §6.3, §6.4, §6.5, §6.6).

## Issue BUILD-22 — Version bumped to 0.0.5.0; package built (includes STEP08-02)

**Problem:** n/a — routine version bump + packaging. `outputAppPackage/
Bootcamp_Registration_Tracking_0.0.4.0.app` predated the STEP08-02 fixes (most importantly
G-12's real bug fix); AJ approved a Revision-class bump and asked to build immediately.

**Root cause:** n/a.

**Resolution:** `app.json` `version` bumped `0.0.4.0` → `0.0.5.0` — proposed as a Revision
(small correction/hotfix, no new features: G-12's bug fix + G-13/G-03's minor code changes),
consistent with this project's flat sequential pre-1.0 numbering; AJ approved. Recompiled clean
(20 files, 0 errors / 0 warnings), then built
`outputAppPackage/Bootcamp_Registration_Tracking_0.0.5.0.app`. Prior packages (`0.0.1.0` through
`0.0.4.0`) left untouched. **Schema Sync Mode check: no schema changes since `0.0.4.0`
(ToolTip/UsageCategory/trigger-body changes only, no fields or tables added/removed/retyped) —
safe to upload with the default Add sync mode; Force Sync not needed.** Not yet published or
retested live.

**Files affected:** `app.json`,
`outputAppPackage/Bootcamp_Registration_Tracking_0.0.5.0.app` (new; git-ignored).

**Updated:** TDD — no. FRD — no.

## Issue STEP09-01 — Code Review run; three real defects found, one Standards non-compliance confirmed unresolved

**Problem:** Step 09 (Code Review) had not been run. Per §1.7, delegated to an Opus reasoning-role
subagent for a comprehensive review across all 20 objects (code quality, dead code, redundant
code, obsolete references, Standards Anti-Patterns, best practices, BCQuality knowledge-backed
review). Main role independently re-verified the highest-stakes findings (BP-1, BP-2, SC-1, CQ-2)
against the actual source — and, for BP-2, against real Microsoft AL platform behavior via
independent sources — before trusting them.

**Root cause:** n/a — this is the review step itself. Full findings, severities, and proposed
resolutions are in `docs/CodeReview.md`.

**Resolution:** `docs/CodeReview.md` created. Headline results:
- **BP-1 (Moderate, needs a decision):** `SeedAmountPaid`'s `Amount Paid <> 0` guard can't
  distinguish "not supplied" from "deliberately zero" — a comped ($0) registration is silently
  re-billed to the bootcamp's Price on `OnInsert`, contradicting the shipped ToolTip, FRD F-8,
  FRD D-9, and TDD §4.7's own stated no-overwrite guarantee. Three resolution shapes proposed.
- **BP-2 (Moderate, code fix recommended):** `OnAfterModifyAttendee`'s `xRec` comparison is dead
  on every code- or API-driven modify (a real, independently-verified AL platform gotcha — `xRec`
  only holds a true before-image on UI-driven changes), so the *old* bootcamp's `Seats Remaining`
  goes stale on a `PATCH`-style bootcamp reassignment. Same F-3/D-8 contract G-12 protected,
  reappearing on a different trigger.
- **SC-1 / BP-3 (Major, needs a decision):** permission sets grant `tabledata` only, no
  object-execute — Standards §7.3 non-compliance, and this is exactly Step 08's deferred G-04 test,
  which still hasn't been run. Related: G-14's proposed cue-permission guard would be insufficient
  on its own — two of the five Activity Cues are FlowFields the platform calculates outside the
  guarded codeunit entirely.
- Plus 8 minor findings (redundant/drifted page ToolTips, missing `ShowMandatory`, missing
  `DataClassification` on 3 fields, a performance nit, a stale `ObjectRegister.md` note, etc.) —
  full list in `CodeReview.md`.
- **Both existing OCPF BC AL Patterns fixes re-verified as still correctly applied.** Three new
  pattern candidates identified (BP-1, BP-2, BP-3's underlying shapes) and flagged to AJ, not
  added unilaterally.

**Files affected:** `docs/CodeReview.md` (new).

**Updated:** TDD — no (pending AJ's decisions on BP-1/SC-1/BP-3). FRD — no (pending, same).

## Issue STEP09-02 — Step 09 findings resolved: 3 real defects fixed, Standards gap closed

**Problem:** STEP09-01 found 11 substantive findings. AJ approved: BP-1 resolution (a) — seed
Amount Paid once, on bootcamp selection, drop the `OnInsert` re-seed; SC-1/BP-3 — fix now,
verify live after, rather than blocking on a live test first.

**Root cause:** n/a — this is the resolution pass for STEP09-01's findings.

**Resolution:** All applicable findings applied:

- **BP-1** — `SeedAmountPaid` is now called **only** from `"Bootcamp No." OnValidate`; the
  `OnInsert` unconditional re-seed (whose `Amount Paid <> 0` guard couldn't distinguish "not
  supplied" from "deliberately zero," silently re-billing a comped registration) is removed.
  **This required a second, related fix:** `ocpfAttendeeSubform.OnNewRecord` previously set
  `"Bootcamp No."` via a plain field assignment, which never fires `OnValidate` — the normal
  subform registration flow would have stopped seeding Amount Paid entirely. Changed to
  `Rec.Validate("Bootcamp No.", ...)`, guarded on a non-blank filter. Verified the API page
  declares `bootcampNo` before `amountPaid` in field order, so an explicit `amountPaid: 0` in a
  POST body still correctly wins.
- **BP-2** — `xRec` inside `OnAfterModifyAttendee` is not a reliable before-image on a code- or
  API-driven `Modify()` (independently verified against real AL platform behavior via multiple
  sources, since Microsoft's own reference page doesn't spell it out). Fixed with a new
  `OnBeforeModifyEvent` subscriber: `xRec.Get(xRec."No.")`, refreshing `xRec` from the database
  before the write — the documented technique for this exact gotcha, carrying the true prior row
  through to `OnAfterModifyEvent` regardless of caller.
- **SC-1 / BP-3 (closes Step 08's deferred G-04/G-14)** — added explicit `page … = X` execution
  grants on all 8 of this extension's own pages to `OCPF - Bootcamp Read` (inherited by Edit);
  added an `OnOpenPage`-computed `Bootcamp.ReadPermission()` guard on the O365 Activities
  `cuegroup`'s `Visible` property, covering both the two FlowField cues (which a codeunit-only
  guard would have missed entirely) and the three plain-field cues. **Still needs a live,
  non-SUPER-user sandbox test** — fixed now per AJ's choice, not yet verified live.
- **BP-7** — `Seats Remaining` now clamps to 0 whenever `Max Seats <= 0` (no cap, F-10), instead
  of displaying a raw negative subtraction. Refactored into one shared `CalcSeatsRemaining()`
  procedure on `ocpfBootcamp`, called from both the table's own `OnValidate`/`OnInsert` and the
  codeunit's `UpdateSeatsRemaining`, so all three sites agree on one definition.
- **CQ-2** — corrected two Activity Cue ToolTips that described behavior the code didn't
  implement ("upcoming" bootcamps — no such filter exists; "registered this month" — the code
  actually filters on payment date, not registration date).
- **BP-5** — added `DataClassification = CustomerContent` to the three plain Activity Cue fields
  (a `tableextension` has no table-level classification to inherit).
- **BP-4** — added `ShowMandatory = true` to `ocpfAttendeeList`'s `"Bootcamp No."` control (hard
  `TestField`-enforced but previously showed no visual cue).
- **CQ-3** — added `DelayedInsert = true` to `ocpfAttendeeList`, matching its subform sibling.
- **PERF-1** — `CountBelowMinSeats` now calls `SetAutoCalcFields("Registered Attendees")` before
  its loop instead of `CalcFields` per row.
- **R-1** — removed 40 redundant page-level `ToolTip`s across 5 files
  (`ocpfBootcampList`, `ocpfBootcampCard`, `ocpfAttendeeList`, `ocpfAttendeeSubform`,
  `ocpfO365ActivitiesExt`'s cuegroup) that duplicated their table field's own `ToolTip` — bound
  page fields inherit it automatically from runtime 13.0/BC24 onward (this project targets
  17.0), and several had already drifted from the table's wording.
- **R-2 — checked, found not to apply.** The review claimed an unused `using
  Microsoft.RoleCenters;` in `ocpfO365ActivitiesExt.PageExt.al` — that file has no such line;
  independently verified before acting, per this project's own BUILD-11 lesson, and no change
  was needed.
- **`docs/ObjectRegister.md`** — corrected the stale "built (setup table only)" rows for both
  permission sets, which have covered all 3 owned tables since Batch 2.
- **Not fixed, scheduled:** BP-6 (`Confirm()` inside the Attendee insert transaction) and BP-8
  (new-company Assisted Setup registration gap) added to `docs/Roadmap.md` as R-2 and folded
  into R-1 respectively.
- **CQ-1 (API page Captions)** — left as-is; TDD §9.1 already documents this as a deliberate
  AA0101-style divergence from the Standards §4.5 literal example. Recorded here, since no
  ChangeLog entry previously existed for it (unlike BUILD-06's AA0101 divergence, which is
  logged) — accepted, not a defect.

Recompiled clean after every batch of code changes: 20 files, 0 errors / 0 warnings.

**Files affected:** `src/Bootcamp/ocpfBootcampRegMgt.Codeunit.al`, `src/Bootcamp/ocpfBootcamp.Table.al`,
`src/Attendee/ocpfAttendee.Table.al`, `src/Attendee/ocpfAttendeeSubform.Page.al`,
`src/Attendee/ocpfAttendeeList.Page.al`, `src/Bootcamp/ocpfBootcampList.Page.al`,
`src/Bootcamp/ocpfBootcampCard.Page.al`, `src/RoleCenter/ocpfActivitiesCueExt.TableExt.al`,
`src/RoleCenter/ocpfActivityCueMgt.Codeunit.al`, `src/RoleCenter/ocpfO365ActivitiesExt.PageExt.al`,
`src/Permissions/ocpfBootcampRead.PermissionSet.al`, `docs/ObjectRegister.md`, `docs/Roadmap.md`.

**Updated:** TDD — yes (§4 items 3/7/12, §6.11, §6.16, §6.17, §6.18, §6.20, item 11's Step
renumbering). FRD — yes (F-3, F-8, D-8, D-9, §6.6).

---

## Issue BUILD-23 — Version bumped to 0.0.5.1; package built (includes STEP09-02)

**Problem:** n/a — planned packaging step, per ALL ALONG → Packaging & Versioning: a
testing-feedback/review batch that lands clean is a candidate moment to offer a repackage, not
just the narrative Step 09 pass.

**Root cause:** n/a.

**Resolution:** Version bump proposed to AJ via `AskUserQuestion` with the runbook's own category
definitions quoted (Minor vs. Revision) and a recommendation; AJ approved **Revision — `0.0.5.1`**.
Reasoning matched: STEP09-02 added no new feature, field, or object to `app.json` — it is bug
fixes (BP-1 seeding logic, BP-2 `xRec` reliability, BP-7 Seats Remaining clamp), one
security-relevant hardening (SC-1/BP-3 execute grants + cuegroup visibility guard), and cleanup
(R-1 tooltips, CQ-2/BP-4/BP-5/CQ-3/PERF-1) — no new capability a consumer could call that didn't
exist in `0.0.5.0`.

`app.json` bumped `0.0.5.0` → `0.0.5.1` directly by the agent, only after AJ's explicit approval
(never silent, per Operating Rule 6 / Packaging & Versioning). Compiled via the established route
(`alc.dll` from the AL extension's `bin/`, against VS Code's pre-provisioned .NET 10 runtime —
nothing installed): **20 files, 0 errors / 0 warnings.** Package built:
**`outputAppPackage/Bootcamp_Registration_Tracking_0.0.5.1.app`**. No package deleted — every
prior version (`0.0.1.0` through `0.0.5.0`) remains in `outputAppPackage/` untouched.

**Schema Sync Mode:** this build only changes code and metadata — a new event subscriber, a new
table procedure, permission-set grants, `DataClassification`/`ShowMandatory`/`DelayedInsert`
property additions, a page `Visible` property, and tooltip removals. No table, field, primary
key, or data-type change. **Default Add sync mode is sufficient — Force Sync is not needed** for
this upload.

**Files affected:** `app.json` (version only), `outputAppPackage/Bootcamp_Registration_Tracking_0.0.5.1.app`
(new).

**Updated:** TDD — no. FRD — no.

**Not yet done:** AJ needs to publish this package to sandbox and run the live, non-SUPER-user
permission retest that closes SC-1/BP-3 for real (named Step 09/12 test case in
`CodeReview.md`/`TDD.md`/`FRD.md`) — this packaging step builds the fix, it doesn't verify it live.

## Issue STEP10-01 — Step 10 (Update Design Documents): PostDevTDD.md produced, FRD re-baselined

**Problem:** n/a — planned documentation step, per runbook Step 10.

**Root cause:** n/a.

**Resolution:** Produced `docs/PostDevTDD.md` — the as-built architecture reference required by
Step 10, generated by reading the shipped `.al` files directly (not carried forward from
`TDD.md`'s narrative) for every object touched since Step 08/09: `ocpfBootcamp.Table.al`,
`ocpfAttendee.Table.al`, `ocpfBootcampRegMgt.Codeunit.al`, `ocpfAttendeeSubform.Page.al`,
`ocpfAttendeeList.Page.al`, `ocpfBootcampList.Page.al`, both permission sets,
`ocpfActivitiesCueExt.TableExt.al`, `ocpfActivityCueMgt.Codeunit.al`, and
`ocpfO365ActivitiesExt.PageExt.al`. States every rule as current, final truth (no "was X, now Y"
narrative in the main body); moved the full before/after history into a dedicated §12 Deviation
Summary table, cross-referenced to the ChangeLog Issue that produced each change. Original
`TDD.md` retained unmodified as historical design context, per the runbook's explicit rationale
for not replacing it.

**Also found and fixed while re-baselining `FRD.md` against the as-built code (the actual
purpose of this step, not just a documentation exercise):** `FRD.md` D-6 still stated the
pre-BUILD literal API identity (`APIPublisher = 'OnlyCopilotFans'`, `APIGroup =
'ocpf_bootcampRegistration'`) — values that were never actually shipped. The real, as-built
values (`'onlyCopilotFans'` / `'ocpfBootcampRegistration'`, an AA0101 camelCase divergence,
ChangeLog BUILD-06) were already corrected in `ProjectParameters.md` §1.3 at Step 08 (G-17) and
have always been correct in `TDD.md` §1 and `ObjectRegister.md` — but this specific FRD row was
missed by every prior review pass (Step 08's Gap-Fit Test and Step 09's Code Review both audited
other documents' handling of this same drift without catching that FRD D-6 itself still carried
it). Corrected now, with a note explaining what was wrong and why it was missed.

**Files affected:** `docs/PostDevTDD.md` (new), `docs/FRD.md` (D-6 corrected).

**Updated:** TDD — no (original retained unmodified, per Step 10's own rule; `PostDevTDD.md` is
the as-built companion, not an edit to it). FRD — yes (D-6).

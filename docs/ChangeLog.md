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






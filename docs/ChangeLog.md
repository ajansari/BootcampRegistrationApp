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





# Code Review (Step 09) — Bootcamp Registration Tracking

**Phase:** PROVE · **Step:** 09 · **Status:** **All applicable findings resolved 2026-09-13**
(STEP09-02) — AJ approved BP-1's resolution (a) and "fix now, verify after" for SC-1/BP-3;
recompiled clean (20 files, 0/0) after every batch. Not fixed, scheduled: BP-6, BP-8
(`docs/Roadmap.md`). Left as-is, accepted: CQ-1 (already documented in TDD §9.1), R-2 (checked,
did not apply — no such `using` line existed). **Live verification still owed:** SC-1/BP-3's
permission-execute-grant and cuegroup-visibility fixes need a non-SUPER-user sandbox test — a
named Step 12 test case, not closed by this code change alone.
**Date:** 2026-09-13
**Scope:** All 20 `.al` files under `src/`, read in full (not sampled). Package reviewed:
`outputAppPackage/Bootcamp_Registration_Tracking_0.0.5.0.app`.
**Inputs:** `docs/TDD.md`, `docs/FRD.md`, `docs/ChangeLog.md`, `docs/GapAnalysis.md`,
`docs/ObjectRegister.md`; Standards Parts 3/4/6/9/11 (`AL_PTE_Development_Standards_UNIFIED.md`,
read from a sibling project's folder — not present in this repo); the BCQuality knowledge
snapshot (`../BootcampClaude.bcquality/`); `patterns/` (this project's own OCPF BC AL Patterns
library); BC v28.4 symbol files (`.alpackages/`).
**Method:** Comprehensive review per §1.7, run by the **reasoning role** (Opus subagent), fresh
eyes against code this project's own main role wrote. Main role independently re-verified the
highest-stakes findings (BP-1, BP-2, SC-1, CQ-2) against the actual source files — and, for BP-2,
against Microsoft's own AL platform behavior — before trusting them. Findings below are the main
role's write-up of that report.

---

## 1. Code quality

| ID | Finding | Severity | Resolution |
|---|---|---|---|
| CQ-1 | Both API pages' `Caption` (`'Bootcamps'`, `'Attendees'`) match Standards §4.5's own counter-example — it wants a full sentence, since the caption flows into OData `$metadata` as the entity description. TDD §9.1 already codifies this as a deliberate divergence, but no ChangeLog entry records it as such (unlike BUILD-06's AA0101 divergence, which is logged). | Minor | Either write sentence captions, or log the divergence explicitly. Caption-only; no repackage needed alone. |
| CQ-2 | **Two Activity Cue ToolTips describe behavior the code doesn't implement — verified against the actual code.** "Below Min Seats" ToolTip says "active, **upcoming** bootcamps"; `CountBelowMinSeats` filters on `Status = Active` only, no date filter — a long-past bootcamp still counts if its status was never changed. "Bootcamp Revenue This Month" ToolTip says "attendees **registered** this month"; `SumRevenueThisMonth` actually filters on `Paid = true` **and `Payment Date`** in the month (matching TDD §6.18) — an attendee with `Paid = true` but a blank `Payment Date` is silently excluded. | Moderate | Correct the ToolTips to match the code (drop "upcoming"; say "paid this month," not "registered this month"). Text-only. |
| CQ-3 | `ocpfAttendeeList` has no `DelayedInsert`, while its Batch-3 sibling `ocpfAttendeeSubform` (same source table) does. TDD §6.10 matches the code, so this is a design gap, not a code-vs-spec gap. | Minor | Consider `DelayedInsert = true` on `ocpfAttendeeList` for consistency. |

**Formatting/structure:** clean across all 20 files — no tabs, consistent 4-space indent, one `namespace` per file, `AA0215` file naming, all 20 object IDs unique and in range. No template drift found between early (B1) and gap-fill (BUILD-09) batches.

## 2. Dead code

**No issues found.** No empty triggers, no commented-out fields, no `// TODO`. The only `//` comments in the codebase are the two explanatory blocks already required by ALL ALONG → Retain Explanations (the G-12 rationale in `ocpfBootcamp.Table.al`, the filter-group-4 rationale in `ocpfAttendeeSubform.Page.al`).

## 3. Redundant code

| ID | Finding | Severity | Resolution |
|---|---|---|---|
| R-1 | **42 page-level ToolTips duplicate their table field's ToolTip; 22 have already drifted apart from it.** Knowledge-backed (BCQuality `style/tooltip-required-on-page-fields.md`): from BC24/runtime 13.0, bound page fields inherit the table field's ToolTip — a page-level override is a duplicate-maintenance anti-pattern, and this project targets runtime 17.0. Examples of drift found: `Price` (page: generic; table: "seeds Amount Paid"), `Max Seats` (page: "leave at zero for no limit"; table: adds the overbooking-warning detail), `Amount Paid` (page omits the "never overwritten" guarantee the table states), `Location` (page omits the "not linked to warehouse locations" clarification). This also subsumes half of CQ-2 — the cue ToolTip drift is one instance of this same pattern. | Moderate | Delete the redundant page-level `ToolTip` properties on bound fields; let them inherit. Mechanical, text-only, no schema impact. |
| R-2 | `using Microsoft.RoleCenters;` in `ocpfO365ActivitiesExt.PageExt.al` appears unused — `page 1310 "O365 Activities"` is in the global namespace per symbols. Flagged as "appears," not "is," per this project's own BUILD-11 lesson: verify by removing and recompiling, don't trust a static read alone. | Minor | Remove and recompile to confirm before treating as resolved. |
| R-3 | `OnAfterRenameAttendee` does an unconditional `Get`+`CalcFields`+`Modify` round-trip to recompute a value (`Seats Remaining`) that a rename (key-only change) cannot have moved. Harmless, just pointless. | Minor | Guard or leave — low priority. |

## 4. Marked for obsoletion

**No issues found — verified against symbols, not assumed.** Every standard object/member/enum value this extension touches (No. Series table 308 + codeunit 310, Customer table 18, Guided Experience codeunit 1990, Assisted Setup Group / Video Category enums, Activities Cue table 1313, O365 Activities page 1310, Business Manager Role Center page 9022) checked directly against the BC v28.4 symbol packages: zero `ObsoleteState = Pending`/`Removed` references, no subscriptions to obsolete events.

## 5. Standards compliance — Anti-Patterns table (Part 11)

**One failure found; everything else passes.**

| ID | Finding | Severity | Resolution |
|---|---|---|---|
| SC-1 | **Permission sets grant `tabledata` only — no object-execute grants for any of this extension's 12 page/codeunit objects.** Standards §7.3 requires the read-only set to grant execute access on all pages; the shipped sets (`OCPF - Bootcamp Read`/`Edit`) contain only 3 `tabledata` lines each. Corroborated independently by BCQuality (`appsource/permission-sets-cover-setup-and-usage-without-super.md`): *"omitting a tabledata **or execute** grant used by the app's own UI."* **This is exactly the deferred G-04 test from Step 08's Gap-Fit Test — it has not actually been run.** The composition that *is* present is correct (Edit correctly includes Read via `IncludedPermissionSets`, no wildcards, all 3 owned tables covered in both sets — independently re-verified, not just trusted from Step 06). | **Major** | Either add explicit execute grants, or run the deferred non-SUPER-user test live before this step closes — right now "the permission sets are sufficient" is unverified in both directions. See BP-3 below; the two findings share one root fix. |

**Everything else in Part 11 passes:** `DelayedInsert`/`Editable` mutually exclusive and correct on both API pages; `ODataKeyFields = SystemId` on both; no `const()` quoting in scope (correctly N/A per TDD §4.8); no reserved keywords, no `%` in identifiers; longest identifier 20 chars, both entity names ≤ 30; no unverified table numbers; no pending-obsolete references; `NA` localization with no localized standard fields touched; `ApplicationArea = All` throughout non-API pages; no hardcoded publisher/prefix/version. The API pages' Caption-only field metadata was independently re-confirmed as *not* a finding — G-16's FRD D-5 rescoping holds up under BCQuality's own knowledge (`style/tooltip-required-on-page-fields.md` + `style/caption-required-on-page-fields.md` both agree API pages are exempt from the UI-label rule).

## 6. Best practices

| ID | Finding | Severity | Resolution |
|---|---|---|---|
| BP-1 | **`Amount Paid` overwrites a deliberate `0`, contradicting the shipped ToolTip, FRD F-8, FRD D-9, and TDD §4.7's own stated guarantee. Independently re-verified against the actual source — confirmed.** `SeedAmountPaid`'s guard is `if Attendee."Amount Paid" <> 0 then exit;`, called unconditionally from `OnInsert` — *after* the user (or an API caller) may have already deliberately entered `0` for a comped seat. `0` is being used as both "not supplied" and "a legitimate value," and the code cannot tell them apart. **Concrete repro:** register an attendee on a 1500-priced bootcamp, choose the bootcamp (seeds `Amount Paid = 1500`), then type `0` for a comp — `OnInsert` re-seeds it back to `1500`. Same via a `POST` with `"amountPaid": 0`. | **Moderate — needs a decision, not just a fix** | Three options (main role's recommendation is (a)): **(a)** seed only from `OnValidate("Bootcamp No.")`, drop the `OnInsert` call — seeded once, at bootcamp-selection time, never re-seeded; **(b)** keep the `OnInsert` call but gate on a real "not yet seeded" marker instead of `= 0`; **(c)** accept the current behavior and correct the ToolTip/FRD F-8/FRD D-9/TDD §4.7 to say zero re-seeds. (a) and (b) are code changes requiring the full Step 07 cycle; (c) is documentation-only. |
| BP-2 | **The `xRec` comparison in `OnAfterModifyAttendee` is dead on every code- or API-driven modify, leaving the *old* bootcamp's `Seats Remaining` stale. Root cause independently verified against real AL platform behavior, not taken on the subagent's word.** I confirmed via multiple independent sources (a Microsoft community engineering blog, a Microsoft Q&A/community thread, and a `microsoft/AL` GitHub issue — Microsoft's own terse reference page doesn't spell this out) that when a record is modified **from AL code** rather than from a page, `xRec` inside `OnModify`/`OnAfterModifyEvent` is populated as a copy of the *new* `Rec`, not a true pre-modification image — the before-image guarantee only holds for UI-driven changes. **Concrete repro:** `PATCH` an attendee's `bootcampNo` from `BC0001` to `BC0002` via the API — `BC0002`'s seat count recomputes correctly, but the `xRec."Bootcamp No." <> Rec."Bootcamp No."` branch never fires, so `BC0001` keeps counting a seat it no longer holds. Its `Seats Remaining` and the Role Center's "Below Min Seats" cue are both wrong until something else happens to touch that bootcamp — while the live `Registered Attendees` FlowField stays correct, so the two columns visibly disagree. This is the same F-3/D-8 contract G-12 was fixed to protect, reappearing on a different trigger. TDD §4.3 documents the *intent* correctly; the *mechanism* is the platform gotcha. | **Moderate — code fix, recommended, not just flagged** | Don't rely on `xRec` here. Re-read the row's committed prior value before the write (e.g., an `OnBeforeModifyEvent` subscriber that captures the old `"Bootcamp No."` from the database, or a plain `Get()` into a separate variable before `Rec.Modify()` is called at the call site) rather than trusting `xRec`. Verify with the API-PATCH repro above, before and after. Code-touching — full Step 07 cycle. |
| BP-3 | **G-14 (deferred from Step 08) is real, and bigger than the deferred note assumed.** The proposed guard (`if not Bootcamp.ReadPermission() then exit;` inside `UpdateCues`) would not be sufficient: cue fields 60800/60801 are **FlowFields**, calculated by the platform when the cuegroup renders — not through `UpdateCues` at all. A codeunit-level guard leaves two of the five cues still touching tables the signed-in user may not be able to read. | **Moderate-to-major — shares its fix with SC-1, needs the same live-test decision** | Any fix must cover the cuegroup's *visibility*, not just `UpdateCues`'s calculation: compute a `Boolean` from `Bootcamp.ReadPermission()` in `OnOpenPage` and bind the `cuegroup`'s `Visible` to it, in addition to the `UpdateCues` guard. (BCQuality's `security/indirect-permissions-for-elevated-access.md` is the alternative shape if the cues must show for everyone regardless of permissions — not recommended here without a specific reason.) |
| BP-4 | `"Bootcamp No."` on `ocpfAttendeeList` is `NotBlank = true` and hard-enforced by `TestField` in `OnInsert`, but the page control has no `ShowMandatory`. BCQuality (`ui/showmandatory-on-code-required-page-fields.md`) names this exact shape, noting `NotBlank` doesn't reliably mark non-key fields as required in the current client. Combined with CQ-2's UX gap, a user can fill a whole row and get an error naming a field that never looked different from the optional ones. | Minor | Add `ShowMandatory = true` on that control (not needed on the subform's copy — it's hidden and code-populated). |
| BP-5 | Three plain `tableextension` fields (`OCPF Below Min Seats`, `OCPF Registrations This Month`, `OCPF Revenue This Month`) have no `DataClassification`, so they ship as `ToBeClassified`. BCQuality (`privacy/data-classification-required-on-pii-fields.md`): a `tableextension` has no table-level value to inherit, so every Normal field it adds must set its own. **This is the only finding in this review that touches the schema** — but it's additive (adding a property to existing fields), so the next package still uploads with the default **Add** Schema Sync Mode; Force Sync is not needed. | Minor | Add `DataClassification` to the three fields. |
| BP-6 | `Confirm()` (the overbooking prompt) is raised from inside `ocpfAttendee`'s `OnInsert` — inside the write transaction. BCQuality (`performance/avoid-user-prompts-inside-transactions.md`): stalls the transaction and its locks until the user responds. `GuiAllowed()` correctly keeps this off the API path; blast radius is small at this app's concurrency profile. | Minor | Defensible as a `Roadmap.md` item rather than an immediate fix. |
| BP-7 | `Seats Remaining` goes negative on an uncapped bootcamp (`Max Seats = 0` = no cap, per F-10/G-15) — e.g. `-12` with 12 registrations and no cap — with nothing telling the user this is expected. | Minor | Blank/zero it when `Max Seats = 0`, or document the display behavior in the user guide. |
| BP-8 | Assisted Setup registration only happens in `OnInstallAppPerCompany` — confirmed via symbols that `Guided Experience Item` (table 1990) is company-scoped (no `DataPerCompany = false`), so a **new company** created after this extension is already installed in a tenant will not see the wizard in its Assisted Setup list. `Roadmap.md` R-1 already covers the missing Upgrade codeunit for *version* changes; this is the *new-company* dimension, which R-1 doesn't mention. | Minor | Fold into `Roadmap.md` R-1, or split into its own item. |
| PERF-1 | `CountBelowMinSeats` calls `Bootcamp.CalcFields("Registered Attendees")` inside a `FindSet()`/`repeat` loop — one extra query per active bootcamp, every Role Center render. BCQuality (`performance/use-setautocalcfields-for-per-row-flowfields.md`): `Bootcamp.SetAutoCalcFields("Registered Attendees");` before `FindSet()` folds it into one query. (`CalcSums` isn't the right tool — it can't preserve per-row filtering the count needs.) Related but not a separate finding: TDD §6.20 already deliberately declined Microsoft's own page-background-task caching pattern at this app's scale — `SetAutoCalcFields` makes that decision's "the calculation is cheap" assumption actually true rather than aspirational. | Minor | Add `SetAutoCalcFields` before the loop. |

**Best practices that pass — independently re-verified, not just trusted from Step 06:** 100% `Rec.` qualification across all 20 files; all 3 owned tables covered by `tabledata` in both permission sets (Read/Edit composition correct); `DelayedInsert`/`Editable` correct on both API pages; `ODataKeyFields = SystemId` + `systemId`/`lastModifiedDateTime` on both; FlowFields `CalcFields`-ed everywhere they're exposed; the `BootcampNo` key backs both the count FlowField and the delete guard; number-series assignment follows the modern codeunit-310 pattern; all four event subscribers guard with `Rec.IsTemporary()`; `Bootcamp.Get()` always return-checked; errors pass parameters directly to `Error(Label, …)`, never pre-built with `StrSubstNo`; every `Label` with placeholders has a `Comment`. **Both existing OCPF BC AL Patterns fixes (SubPageLink FilterGroup4, Init-doesn't-clear-primary-key) are still correctly applied** — re-verified line by line against the pattern files' own worked examples, not assumed from Step 08.

## 7. BCQuality knowledge-backed review

**Snapshot used:** `../BootcampClaude.bcquality/`, 283 knowledge files, 19 action skills. `knowledge-index.json` absent and `pwsh` not installed on this machine — per Operating Rule 6b, no install was attempted; fell back to path-based discovery by domain folder, which the runbook explicitly permits.

**Dispatch:** Entry routed to the super-skill `microsoft/skills/review/al-code-review.md` (all 16 leaf skills evaluated under it); the community `al-agents-review` skill was correctly skipped on goal-mismatch (this extension defines no BC Agent/Copilot capability).

**Result:** `outcome: completed`, 0 blockers, 1 major (SC-1), 6 minor (BP-2's platform mechanism, R-1, BP-4, BP-5, PERF-1, BP-6) — all folded into the tables above rather than duplicated here.

**Suppressed correctly, worth recording:** a draft finding that three `Label`s declared at local (trigger/procedure) scope should be object-scoped was suppressed by BCQuality's own `style/labels-declared-at-object-scope.md`, which explicitly states a Label being local is not itself a correctness or localization defect — the protocol's precedence rule working as intended, not a gap.

**Checked and clean, not silent:** `performance/do-not-modify-in-onaftergetrecord.md` (UpdateCues never calls `Modify`, so no per-row write — worth a one-line comment for future maintainers, not a finding); `web-services/set-required-api-page-properties.md` (all routing properties + explicit `APIVersion = 'v1.0'` present on both API pages, correctly avoiding an implicit `beta` fallback).

**Informational, for Step 11 documentation (not a code finding):** BC 24+'s OData schema 2.0 default serializes `Status` as the member name (`Active`/`Inactive`/etc.), not the caption — TDD §6.12 already notes this; carry it into `Documentation.md`'s consumer-facing reference explicitly, since a caller pinning `$schemaversion=1.0` would see captions instead.

## 8. Patterns-library verification and new candidates

Both existing pattern fixes **independently re-verified as still correctly applied**, line by line against each pattern file's own worked example — not assumed from Step 08's sign-off.

**Three candidates for a new, third pattern file — flagged for AJ's decision, not added unilaterally** (ALL ALONG → OCPF BC AL Patterns Library: recognizing a candidate is the agent's job, contributing it to the shared library is AJ's call):
1. **`xRec` is not a reliable before-image in a code-driven `OnModify`** (BP-2) — the strongest candidate: a real bug, a verified platform root cause (with citable sources), a failure mode invisible to UI testing and only surfaced via API/automation traffic, and a natural discriminating test (mutate via API, check the old parent) — the same shape the existing two pattern files already use.
2. **A "seed if blank" field can't distinguish "not supplied" from "deliberately zero"** (BP-1) — highly generalizable: any BC extension that seeds a price/quantity/date/discount from a parent record hits this exact sentinel-collision shape, and the failure is always silent and usually financial.
3. **Role Center cue calculations run as the signed-in user — guard both the calculation codeunit and any FlowField cues** (BP-3) — the non-obvious half (a codeunit guard alone misses FlowField-based cues entirely) is exactly the kind of thing this library exists to save the next project from rediscovering.

## 9. Also found: stale documentation outside `src/`

`docs/ObjectRegister.md` rows for permission sets 60890/60891 still say **"built (setup table only)"** — they have covered all three owned tables since Batch 2 (BUILD-02). G-19 corrected object 60803's stale status in the same table during Step 08 and missed these two rows.

---

## Verdict — resolved 2026-09-13 (STEP09-02)

**Step 09 is now closed.** AJ approved BP-1's resolution (a) and "fix now, verify after" for
SC-1/BP-3. All applicable findings applied (BP-1, BP-2, BP-7, SC-1, BP-3, CQ-2, BP-4, BP-5,
CQ-3, PERF-1, R-1, the `ObjectRegister.md` correction) and recompiled clean (20 files, 0/0)
after every batch of changes. R-2 was checked and did not apply — the claimed unused `using`
line doesn't exist in that file. CQ-1 left as-is (already documented as a deliberate divergence
in TDD §9.1). BP-6 and BP-8 scheduled in `docs/Roadmap.md` (R-2, folded into R-1).

**One thing this resolution does not close:** SC-1/BP-3's execute-grant and cuegroup-visibility
fixes are applied but **not yet verified live** — a non-SUPER-user sandbox test remains a named
Step 12 test case. See ChangeLog STEP09-02 for the full resolution record.

**Packaging:** every code-touching fix above needs the full Step 07 cycle (recompile, repackage,
redeploy, retest) before it's considered live — done for recompile (20 files, 0/0); repackage
and redeploy are still owed. BP-5's `DataClassification` addition is the only schema-touching
change, and it's additive — still the default **Add** Schema Sync Mode, Force Sync not needed.

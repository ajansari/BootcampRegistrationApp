# Gap Analysis / Fidelity Validation (Step 08) — Bootcamp Registration Tracking

**Phase:** PROVE · **Step:** 08 · **Status:** **All 20 findings resolved 2026-09-13** — AJ
approved "fix everything now" (Operating Rule 6). Code fixes (G-03, G-12, G-13) applied and
recompiled clean (20 files, 0/0); all documentation-only corrections applied; `docs/Roadmap.md`
created (G-06). See ChangeLog STEP08-02 for the full resolution record.
**Date:** 2026-09-13
**Inputs:** `docs/FRD.md`, `docs/TDD.md`, `docs/ObjectRegister.md`, `docs/ChangeLog.md`
(DEFINE-01 → BUILD-21), every `.al` file under `src/`, `app.json`, `docs/ProjectParameters.md`,
`docs/BuildPlan.md`.
**Method:** Formal three-way comparison — FRD vs. TDD vs. as-built code — per §1.7, run by the
**reasoning role** (Opus subagent), fresh eyes against code this project's own main role wrote.
Findings below are the main role's write-up of that report; every resolution described below as
"fix now" or "proposed" has since been applied — this document is kept as the analysis record,
not updated retroactively to erase what was originally proposed vs. what actually happened.

---

## Category 1 — Object in the FRD but not built

**No gaps.** All 17 FRD-inventory objects exist and match on type, source table, and mutability
(Bootcamp/Attendee/Setup tables, Status enum, both list/card pages + subform, wizard, both API
pages, Install/Mgt codeunits, both permission sets). See the reasoning role's full matrix in the
session transcript; nothing here needs a document change.

## Category 2 — Object built but not in the FRD

| ID | Finding | Classification | Resolution |
|---|---|---|---|
| **G-01** | Role Center Activity Cues (60842/60843/60844 + 5 fields on table 1313 + extension of page 1310) — ChangeLog BUILD-09 explicitly deferred the FRD/TDD fold-in to this step. | **Intentional (gap fill), documentation fold-in now due.** | Add FRD §1.2 item F-16, and rows to §6.3/§6.4/§6.5. Add TDD §6.18–§6.20 + update §2/§2.1/§11. `ObjectRegister.md` already correct. |
| **G-02** | Minor as-built additions in neither document: `AboutTitle`/`AboutText` teaching tips + `Rec.Reset()` on the Setup card; `UsageCategory = None` on `ocpfBootcampCard` (only in ChangeLog BUILD-05). | **Spec stale** — all correct, conventional completions. | Capture in `PostDevTDD.md` (Step 11); no FRD/TDD change needed now. |

## Category 3 — Rule in the FRD the TDD did not implement

| ID | Finding | Classification | Resolution |
|---|---|---|---|
| **G-03** | FRD §9.3 Q6 promises Tell Me discoverability; TDD never assigns `UsageCategory` per page. As built, the Setup card (60802) is `UsageCategory = None` — not findable in Tell Me, only via the Role Center or Assisted Setup. | **Oversight — fix now.** | Set `UsageCategory = Administration` on page 60802 (leave the wizard at `None`; wizards are reached via Assisted Setup, not Tell Me). Closes CLAUDE.md §1.6 Q3, never formally asked for this project (see G-17). |
| **G-04** | FRD §6.6 promises "Read on Bootcamp, Attendee, Setup, **and all this extension's pages**"; TDD §6.16 consciously overrides this (tabledata is the controlling grant; page grants only if Step 09 shows a gap) and code follows the TDD. | **Spec stale, conditional on Step 09.** | Reword FRD §6.6 to describe tabledata grants + the D365 base-permission dependency. Add a named Step 09 green-team case: assign only `OCPF - Bootcamp Read` to a test user and open every page. |
| **G-05** | N-6 (clean uninstall, no orphaned Guided Experience item) is deferred in TDD §4.11 to Step 09 verification; Step 09 hasn't run. | **Intentional deferral, still open.** | Carry as a named Step 09 test case, not a silent assumption. |
| **G-06** | No upgrade codeunit exists. `RegisterAssistedSetup` only runs from `OnInstallAppPerCompany`, so a future change to the wizard's registration (title/description/object ID) will never reach an already-installed tenant. Appears in no document. | **Oversight — schedule, not urgent** (no impact today; becomes real the first time the registration changes). | Record the decision explicitly in the FRD or `PostDevTDD.md` ("no upgrade codeunit needed pre-1.0", or add one before `1.0.0.0`); add to `Roadmap.md` (doesn't exist yet — create it). |

## Category 4 — Rule implemented differently from the TDD

| ID | Finding | Classification | Resolution |
|---|---|---|---|
| **G-07** | TDD §6.15 still shows `action(ocpfAttendeeListAction) { Image=Persons; }`. As built: `Image = ContactPerson` (ChangeLog BUILD-07 documents the change — `AL0482`, two invalid names tried first — but marks "Updated: TDD — no"). A developer regenerating from the TDD alone would reproduce the compile error. | **Oversight — fix now (documentation).** | Correct TDD §6.15's code sample; amend BUILD-07's "Updated" line with a pointer to this correction rather than silently rewriting it. |
| **G-08** | TDD §6.14 describes `actionref`s (`Back`/`Next`/`Finish`, standard `NavigatePage SystemActions`); as built, the wizard uses three hand-written `action()`s in `area(Navigation)` with `Enabled` bindings, and only the `Finish` action exists (no `OnQueryClosePage`). No ChangeLog entry, but the wizard was live-tested end-to-end and works (BUILD-21). | **Spec stale.** | Update TDD §6.14 / capture in `PostDevTDD.md` to describe the pattern actually used. |
| **G-09** | TDD §6.14 says sample bootcamps set `Status := Active` explicitly; code relies on the field's `InitValue = "Active"` instead (same outcome). `Location` left blank (TDD didn't specify it). | **Spec stale (trivial).** | Note in `PostDevTDD.md`. |
| **G-10** | `SeedAmountPaid` has an extra guard not in TDD §4.7 (`if not Bootcamp.Get(...) then exit;`) — strictly better, avoids an error on a dangling link. | **Spec stale (trivial), code is right.** | Note in `PostDevTDD.md`. |
| **G-11** | BUILD-16's three claimed TDD updates (§6.5, §6.11, §6.14's `No." := ''` line) and the `ocpfAttendee.OnInsert` `TestField` guard were independently re-verified line-by-line against the current code. **All four match; no residual drift.** None of the BUILD-16 fixes contradicts the FRD — the primary-key clear and filter-group read are implementation-level corrections to behavior the FRD already promised (F-5, F-13); the `TestField` guard is a stricter enforcement of FRD §6.1's "Bootcamp No. — Required." | **No gap — confirmation only.** | One documentation line worth adding at Step 12: an API caller that omits `bootcampNo` now gets a hard error (correct, but should be stated in `Documentation.md` and FRD §6.1's Attendee row). |

## Category 5 — Implementation contradicts the FRD

| ID | Finding | Classification | Resolution |
|---|---|---|---|
| **G-12** | **`Seats Remaining` goes stale — contradicts F-3/D-8. Highest-priority finding, real code defect.** `ocpfBootcamp."Max Seats".OnValidate` calls `UpdateSeatsRemaining`, which does `Bootcamp.Get()` into a **separate** record and `Modify(false)` — but `OnValidate` runs *before* the page/API's own `Modify`/`Insert` commits the field change, so the helper reads the pre-change value from the database and its write is immediately overwritten by the caller's own save. **Deterministic, user-visible:** create a bootcamp, `Max Seats = 20`, save, reopen → `Seats Remaining` shows **0**. Change `Max Seats` 20→30 on a bootcamp with 5 attendees → expected 25, persisted 15. Self-corrects only the next time an attendee is inserted/modified/deleted (those four subscribers read committed state correctly). The wizard's two sample bootcamps look right only because BUILD-07 already fixed this *inside the wizard* by setting every field before a single `Insert(true)` — masking the same defect everywhere else. | **Oversight — fix now.** Category: FRD rule the TDD implemented incorrectly (the code faithfully follows TDD §6.3; the TDD's own rule is defective). | **Root-cause fix (needs AJ's approval per Operating Rule 6 before applying):** compute in memory inside `OnValidate` instead of round-tripping the database — `Rec.CalcFields("Registered Attendees"); Rec."Seats Remaining" := Rec."Max Seats" - Rec."Registered Attendees";` — leaving `UpdateSeatsRemaining` untouched for the four attendee-side subscribers, where reading committed state is correct. Then update TDD §6.3 and log a new ChangeLog issue. **Generalizable rule to record** (third time this project has hit this shape of bug): never recompute a stored field by re-reading the same record from the database inside its own `OnValidate` — the DB still holds the old value, and the caller's own `Modify` overwrites whatever the subscriber just wrote. Add a Step 09 green-team case: new bootcamp, `Max Seats = 20`, no attendees, reopen, expect `Seats Remaining = 20` (currently absent from the test plan). |
| **G-13** | Activity-Cue fields (`ocpfActivitiesCueExt.TableExt.al`, fields 60800–60804) carry `Caption` but no `ToolTip` — contradicts D-5 ("every table field and every page field has Caption and ToolTip"). BUILD-09 records no Step 05 pre-flight pass at all on this gap-fill batch, which is how this was missed. (The corresponding *page* fields on `ocpfO365ActivitiesExt` do have ToolTips, so the UI itself is unaffected — this is a standards-compliance gap, not user-facing.) | **Oversight — fix now** (five one-line additions). | Add a `ToolTip` to each of the five table-extension fields. Note in the ChangeLog that gap-fill work must get the full Step 05 pre-flight, per Operating Rule 4 — this batch didn't. |
| **G-14** | **Plausible, not confirmed — needs a live test.** Activity Cue calculation (`ocpfActivityCueMgt.UpdateCues`, called from `ocpfO365ActivitiesExt.OnAfterGetRecord`) runs `Bootcamp.FindSet()`, `Attendee.Count()`, `Attendee.CalcSums()` against this app's own tables, which are **not** readable by a user without `OCPF - Bootcamp Read`. Table 1313 (Activities Cue) itself is readable by everyone. A non-SUPER Business Manager who hasn't been assigned either OCPF permission set opens their own landing Role Center and the cue calculation touches tables they can't read. Bears on FRD N-9 ("missing permission → clean, actionable error") and §6.6. Cannot be confirmed without a sandbox. | **Oversight — verify, then fix if confirmed.** | Add a Step 09 red-team case: assign a test user *without* the OCPF sets, open the Role Center. If it errors ungracefully, guard cheaply: `if not Bootcamp.ReadPermission() then exit;` in `UpdateCues`, and consider permission-guarded cue field visibility. |
| **G-15** | `Max Seats = 0` means "no cap" (`ConfirmOverbookingIfNeeded` returns silently when `Max Seats <= 0`, per ChangeLog BUILD-04 item 2, AJ-approved) and the field's own ToolTip says so — but FRD F-10 and the §6.1 Bootcamp field table never state this. BUILD-04 explicitly logged "FRD — no." A real, user-facing business rule a reader of the FRD alone wouldn't know. | **Spec stale — update the FRD.** | Add the "0 = no cap" semantic to F-10 and to the `Max Seats` row in FRD §6.1. |
| **G-16** | D-5's literal "every page field has Caption + ToolTip" excludes what the API pages actually do (Caption only, no ToolTip, no per-field `ApplicationArea`) — but TDD §9.1 explicitly and correctly permits this for API pages (Caption must be self-describing instead), and the FRD was never amended to match. | **Spec stale — code is right.** | Reword D-5 to scope the ToolTip/ApplicationArea requirement to non-API pages, citing N-4 (self-describing captions) for API pages. |

## ChangeLog "Updated: TDD/FRD" audit

Every ChangeLog entry's claim checked independently against the actual document text (not taken
on the entry's word):

| Issue | Claim | Independent verification |
|---|---|---|
| DESIGN-02 | FRD yes, TDD yes | ✓ both confirmed. |
| BUILD-02 | TDD yes | ✓ confirmed. |
| BUILD-04 | TDD yes; FRD no | ✓ TDD confirmed. **FRD "no" is wrong** → G-15. |
| BUILD-05 | TDD no | Acceptable, but `UsageCategory = None` lives only in the ChangeLog → G-02. |
| BUILD-06 | TDD yes | ✓ TDD updated — but `ProjectParameters.md` §1.3 was not → **G-17** (new finding, below). |
| BUILD-07 | TDD no | **Wrong** — TDD §6.15 still shows the old `Image` name → G-07. |
| BUILD-09 | TDD no, deferred to Step 08 | Now due → G-01. |
| BUILD-16 | TDD yes (§6.5, §6.11, §6.14) | ✓ all three verified line-by-line against code → G-11. |
| BUILD-11/12/13 | superseded, retained | ✓ correctly marked, not deleted. |
| BUILD-18/19/20/21 | TDD/FRD no | ✓ correct — packaging/versioning only. |

### G-17 · `ProjectParameters.md` §1.3 contradicts the shipped API identity

The intake sheet — the Operating Rule 1 authoritative source — still reads
`APIPublisher = 'OnlyCopilotFans'`, `APIGroup Prefix = ocpf_`, `APIGroup =
'ocpf_bootcampRegistration'`. The shipped API (BUILD-06, AJ's decision to follow CodeCop AA0101)
is `'onlyCopilotFans'` / `'ocpfBootcampRegistration'`. TDD §1/§9.1 and `ObjectRegister.md` were
updated; the parameter sheet — the document every other document is supposed to derive from —
was not.

**Classification: Oversight (documentation) — fix now.**

**Resolution:** Update `ProjectParameters.md` §1.3 to the shipped values, with an inline pointer
to ChangeLog BUILD-06 noting it's a per-project divergence, not a Standards amendment. Same pass:
§1.2's stale "`app.json` currently declares 50100–50149 and must be rewritten" note (done since
BUILD-00); §1.6 (Onboarding & Discoverability) and §1.8 sections were never added even though
§1.7 was retrofitted — §1.6 Q1/Q2 are answered de facto (wizard = F-13; cues = BUILD-09), Q3
(Departments/Tell Me) was never formally asked (connects to G-03).

### G-18 · `BuildPlan.md` stale in two places

§2 says "`version` stays `1.0.0.0`" (superseded by BUILD-01's `0.0.1.0`); §2/§3 still reference
`out/` (renamed `outputAppPackage/` in BUILD-18, whose "files affected" list omitted
`BuildPlan.md`). **Classification: Spec stale (trivial).** Resolution: two small corrections.

### G-19 · `ObjectRegister.md` row for object 60803 is stale

Status reads "built (Batch 1 part: EnsureSetup only)" although BUILD-07 completed it with
`RegisterAssistedSetup`. **Classification: Spec stale (trivial).** Resolution: one-line update.

## True undocumented drift (reverse sweep — code back to documents)

- **G-20 · Four extra `.app` packages in the project root** (`OnlyCopilotFans_Bootcamp
  Registration Tracking_0.0.1.0.app` … `_0.0.4.0.app` — VS Code's own `AL: Package` default
  naming), alongside the four correctly-named packages in `outputAppPackage/`. Gitignored
  (`/*.app`), presumably from AJ publishing directly via VS Code; no ChangeLog entry mentions
  them. **Classification: Intentional (human's own IDE output) — document, don't delete.**
  Resolution: one line in `outputAppPackage/README.md` noting VS Code's own publish path lands in
  the project root under its own naming; per the never-delete-a-package rule, leave them in
  place.
- **Non-gap observations, carried to Step 10 rather than classified here:**
  `CountRegistrationsThisMonth` bounds `SystemCreatedAt` at `235959T`, dropping any
  sub-second-precision registration in the last second of the month; `CountBelowMinSeats` does a
  `CalcFields` per active bootcamp on every Role Center refresh (fine at this app's scale, worth
  a note against N-5). Codebase is otherwise clean: no TODOs, no empty triggers, no tabs,
  `Rec.`-qualified throughout, and no code path assigns `Status` outside its `InitValue` (D-10/F-4
  hold).
- **Process note, not a gap:** TDD §3 still instructs "compile to 0/0 after each batch," which
  contradicts the current runbook's Operating Rule 4 (single mandatory compile at Step 07). The
  project executed under the older rule; `ProjectMemory.md` records the supersession. Worth one
  line in `PostDevTDD.md` so a future reader doesn't take TDD §3 as current framework policy.
- **`Roadmap.md` does not exist yet.** Needed the moment any item above is classified "schedule"
  (G-06) — both the ALL ALONG document list and `TestingFeedback.md`'s own header reference it.

---

## Verdict

The documentation set is unusually honest and largely self-consistent — every superseded
diagnosis is retained and correctly marked, and **no unexplained divergence from the FRD/TDD was
found anywhere in the business logic.** BUILD-16's fixes are fully reflected in both code and TDD
and contradict nothing either document promises.

Of 20 findings, 19 were documentation-integrity items (mostly small, several trivial) — but
**one (G-12) was a genuine code defect against a signed-off functional requirement**, inherited
straight from the TDD's own prescribed rule; the code faithfully implemented a design-document
bug, which is exactly the class of thing this three-way comparison exists to catch.

**Resolution status — AJ approved "fix everything now" (2026-09-13):**
- **Applied (code, approved per Operating Rule 6):** G-03 (`UsageCategory = Administration`),
  G-12 (`Seats Remaining` computed in memory on `Rec`, no more stale `Get()`/`Modify()`), G-13
  (five `ToolTip`s on the Activity Cue table extension). Recompiled: 20 files, 0 errors / 0
  warnings.
- **Applied (documentation only):** G-01 (FRD F-16 + §6.3/§6.4/§6.5/§6.6; TDD §2/§2.1/§6.18–6.20/
  §11), G-04 (FRD §6.6 reworded to tabledata grants), G-06 (`docs/Roadmap.md` created, item R-1),
  G-07 (TDD §6.15 `Image` corrected; BUILD-07's ChangeLog entry amended with a correction note,
  not rewritten), G-08 (TDD §6.14 describes the actual wizard navigation), G-09/G-10 (TDD §6.14/
  §4.7 notes), G-15 (FRD F-10 + §6.1 "0 = no cap"), G-16 (FRD D-5 scoped to non-API pages), G-17
  (`ProjectParameters.md` §1.3 corrected to shipped values; §1.6/§1.8 backfilled; exit-gate
  checkbox corrected), G-18/G-19 (`BuildPlan.md`, `ObjectRegister.md` stale notes corrected),
  G-20 (`outputAppPackage/README.md` notes VS Code's own root-level package output).
- **G-02, G-11** — no action needed now; G-02 (minor as-built completions) deferred to
  `PostDevTDD.md` at Step 11 as originally proposed; G-11 was a confirmation, not a gap
  (BUILD-16 verified fully consistent).
- **Still deferred to Step 09** (verify, then fix only if confirmed): **G-14** (cue
  read-permission on the Role Center — the one item with real blast radius if confirmed), G-04's
  page-execution test, G-05 (uninstall orphan), G-03's Tell Me visibility (now testable since the
  `UsageCategory` fix landed).

This extension is now ready to proceed to **Step 10 (Code Review)**, with G-14/G-04/G-05/G-03 as
named Step 09 test cases still outstanding before PROVE can close out.

**Files affected:** `docs/FRD.md`, `docs/TDD.md`, `docs/ProjectParameters.md`,
`docs/BuildPlan.md`, `docs/ObjectRegister.md`, `docs/Roadmap.md` (new),
`outputAppPackage/README.md`, `docs/ChangeLog.md` (BUILD-07 amendment, STEP08-02 entry),
`src/Bootcamp/ocpfBootcamp.Table.al` (G-12), `src/Foundation/ocpfBootcampRegSetup.Page.al` (G-03),
`src/RoleCenter/ocpfActivitiesCueExt.TableExt.al` (G-13).

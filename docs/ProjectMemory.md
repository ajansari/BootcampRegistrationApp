# Project Memory — Bootcamp Registration Tracking (BC PTE)

> Short anchor only. The *why* of each decision lives in `ChangeLog.md`; this file says
> *where to look* and *what is owed*.

## Current position

- **Phase:** BUILD → PROVE
- **Step:** 06 complete (all 5 batches). Next: Step 07 troubleshoot/reconcile (no known systemic issues outstanding — see below), then Step 08 (Gap-Fit Test).
- **Status:** **20 objects built (17 planned + 3 gap-fill). Full extension compiles 0 errors / 0 warnings** (20 files, CodeCop + UICop + PerTenantExtensionCop). B1–B5 as originally planned (BUILD-02..07); gap-fill BUILD-09 added Role Center Activity Cues (60842–60844). `app.json` version bumped `0.0.1.0` → `0.0.2.0` (AJ's deliberate Build-position override of the Minor recommendation — BUILD-10), then to `0.0.3.0` directly by AJ (BUILD-15). AJ retested the `0.0.2.0` package live and reported **neither** BUILD-12 nor BUILD-13 actually fixed anything. An Opus (Reasoning role) subagent re-diagnosed both from scratch; both original diagnoses were wrong and both are now corrected and independently verified against Microsoft Learn (BUILD-16): Bug 1 was `Record.Init()` not clearing the primary key across a reused variable (BUILD-13's self-healing retry loop removed as unnecessary, per AJ); Bug 2 was reading `SubPageLink` filters from the default filter group 0 instead of group 4 ("Link"). A separate, unrelated infra bug was found and fixed in the same pass: `.bcquality/` nested inside the project root was breaking every compile (470+ errors from non-compilable snippet files); relocated outside the project root. Recompiled clean, 20 files, 0/0. Package `Bootcamp_Registration_Tracking_0.0.3.0.app` built (BUILD-17) — **not yet published or retested live.** Bug 2's root cause carries an open discriminating-test question (see Open decisions). Compile route: `alc.dll` from terminal against VS Code's pre-provisioned .NET 10 runtime (nothing installed).

## Live documents

| Document | Path | State |
|---|---|---|
| Problem Statement | `docs/ProblemStatement.md` | Signed off (PRE-01) |
| ChangeLog | `docs/ChangeLog.md` | Current through BUILD-07 |
| Project Memory | `docs/ProjectMemory.md` | This file |
| Gap Analysis (PRE-02) | `docs/GapAnalysis-PRE02.md` | Signed off |
| Project Parameters | `docs/ProjectParameters.md` | Confirmed by AJ; §1.7 (Model & Effort Assignment) added 2026-09-12 |
| FRD | `docs/FRD.md` | Signed off (updated in place: D-8/F-3 per ChangeLog DESIGN-02) |
| TDD | `docs/TDD.md` | Signed off; updated for Sanity S-1/S-7 and BUILD-04/05/06 deviations |
| Object Register | `docs/ObjectRegister.md` | **20 objects built** (17 planned + 3 gap-fill Activity Cues, BUILD-09) |
| Sanity Check | `docs/SanityCheck.md` | Signed off |
| Build Plan | `docs/BuildPlan.md` | Batch order executed; compile route = terminal `alc.dll` via VS Code's runtime (superseded Option A) |
| Scaffold | `app.json`, `src/*`, `.gitignore`, git repo | Done — baseline `7e71b33`; Batches 1–5 on top (`ea341d2`…latest) on branch `build/bootcamp-registration` |
| Requirements (pre-BUILD source) | `requirements/bootcamp-registration-extension-requirements.md` | Given input, frozen |

## Open decisions

| # | Decision | Awaiting |
|---|---|---|
| 1 | Confirm whether `.vscode/mcp.json` actually connects the AL MCP server in this Claude Code host (may need a reload) | awaiting: AJ |
| 2 | Bug 2 (blank Bootcamp No.) fix applied (BUILD-16) but root cause not 100% certain from static analysis alone — run the discriminating test (add an attendee line to an already-saved/reopened bootcamp vs. a brand-new one) on retest to confirm; clean up orphan Attendee rows with blank Bootcamp No. from earlier testing first | awaiting: AJ |
| 3 | Publish `out/Bootcamp_Registration_Tracking_0.0.3.0.app` (built BUILD-17) to sandbox and run the BUILD-16 retest | awaiting: AJ |

## Milestone log

- 2026-09-10 — Project kicked off from `requirements/bootcamp-registration-extension-requirements.md`. Four clarifying decisions taken (see `ChangeLog.md` Issue DEFINE-01).
- 2026-09-10 — PRE-01 signed off by AJ.
- 2026-09-10 — PRE-02 gap analysis signed off: no ledger/posted/tax tables (descriptive payment only); No. Series (T308) + Customer (T18) added as references; Location/Topic stay free text; 5 items deferred with reasoning.
- 2026-09-10 — Step 01 intake: identity = Bootcamp Registration Tracking / OnlyCopilotFans / SaaS PTE / ns OCPF.BootcampRegistration / loc NA / prefix ocpf; ID range 60800–60899; permission sets = Yes. See `ChangeLog.md` Issue DEFINE-02.
- 2026-09-10 — DEFINE complete; params confirmed. FRD drafted (F-1…F-15, D-1…D-15). 8 open questions resolved by AJ — see `ChangeLog.md` Issue DESIGN-01.
- 2026-09-10 — FRD signed off. TDD drafted: 17 objects, IDs 60800–60891, 5 batches. Seats Remaining changed from FlowField to subscriber-maintained stored field (ChangeLog DESIGN-02).
- 2026-09-10 — TDD signed off. Sanity Check run: batch plan restructured (core tables ship in one batch — mutual FlowField/TableRelation reference, ChangeLog DESIGN-04); `addlast(sections)` fixed; Customer-delete dangling link accepted.
- 2026-09-10 — Sanity signed off. Step 05: scaffold + git baseline (7e71b33). Compile route = Option A. Step 06: Batch 1 (Foundation) generated, pre-flight clean, handed to AJ for compile.
- 2026-09-10 — Pre-release version scheme: `app.json` `version` set to `0.0.1.0`; increment through the test cycle, roll to `1.0.0.0` at go-live (ChangeLog BUILD-01).
- 2026-09-10 — Batch 1 (Foundation) compiles 0/0. PTE0004 fixed by moving permission sets to Batch 1, scoped to tables built so far and grown per batch (ChangeLog BUILD-02); 4 Foundation files renamed to `ocpf*` (AA0215). Terminal compile via VS Code's provisioned .NET runtime. Commit `ea341d2`.
- 2026-09-10 — Batch 2 (core tables + Mgt codeunit) compiles 0/0. AJ approved 2 TDD deviations (BUILD-04): LookupPageId/DrillDownPageId deferred to Batch 3; `Max Seats <= 0` = no overbooking cap. Lint fixes: AA0244 (shared `Bootcamp` var → locals), AA0240 (email label wording). Commit `6c970e5`.
- 2026-09-10 — Batch 3 (in-client pages) compiles 0/0 (BUILD-05). 4 pages + LookupPageId/DrillDownPageId added to both tables. Card gets `UsageCategory = None` (silences info AW0006). Commit `c6e0bb3`.
- 2026-09-10 — Batch 4 (API pages) compiles 0/0. AJ decided to follow CodeCop AA0101 over the Standards §1.3 literal example: `APIPublisher`/`APIGroup` fully camelCased, dropping the `ocpf_` separator (ChangeLog BUILD-06) — a per-project divergence, not a Standards amendment. Commit `0d12f41`.
- 2026-09-10 — Batch 5 (Wizard, RC pageextension, Install revisit) compiles 0/0 (BUILD-07). **All 17 objects built; full extension 0 errors / 0 warnings.** Caught and fixed a real staleness bug in `CreateSampleBootcamps` before it ever ran (Insert-then-Validate would have persisted `Seats Remaining = 0`) by setting fields before the single `Insert(true)`. BUILD phase (Step 06) done. Commit `5cdd441`.
- 2026-09-10 — First package built: `out/Bootcamp_Registration_Tracking_0.0.1.0.app` (BUILD-08). Not published to any sandbox yet (AJ's choice). Next: publish + Step 09 green/red-team testing when AJ is ready, or Step 07/08 doc reconciliation.
- 2026-09-11 — CLAUDE.md (runbook) updated per AJ's feedback: compile-once cadence (Operating Rule 4), tooling-install rule (6b), new intake §1.6 Onboarding & Discoverability + §1.7 Model/Effort Preference, permission-set coverage enforced at every step (Standards §7.3 cross-refs added to Steps 03/04/05/06/10).
- 2026-09-12 — Gap-fill: Role Center Activity Cues added (ChangeLog BUILD-09) — 5 cues (Active Bootcamps, Unpaid Registrations, Below Min Seats, Registrations This Month, Bootcamp Revenue This Month) via tableextension 60842 + codeunit 60843 + pageextension 60844. 20 files, 0/0. No permission-set change needed (tableextension on a standard table, not a new one).
- 2026-09-12 — Version bumped `0.0.1.0` → `0.0.2.0` for BUILD-09 (ChangeLog BUILD-10). AJ overrode the Minor recommendation deliberately — pre-1.0 test cycle treated as flat sequential builds.
- 2026-09-12 — First manual testing round (`TestingFeedback.md`): 2 findings. Attendee line getting blank Bootcamp No. = real bug, fixed via a defensive `OnNewRecord` on `ocpfAttendeeSubform` (BUILD-12). Sample-bootcamp "already exists" was first misdiagnosed as stale data (BUILD-11) — AJ disproved that with an empty table + a brand-new series reproducing it — corrected diagnosis: both sample inserts computed the same number, second collided, error rolled back both (looks like empty table + "already exists" together). Fixed with self-healing number assignment in `ocpfBootcampRegMgt` (BUILD-13). 20 files, 0/0.
- 2026-09-12 — Package built at `0.0.2.0` (BUILD-14), includes BUILD-09..13. Prior `0.0.1.0` package left untouched in `out/`. Not yet published/retested live.
- 2026-09-12 — Runbook updated: fixed three-role work division (main/light/reasoning), model-agnostic, superseding the earlier "record preference only" default. Wired into Steps 02/03/05/06/07/10 and Testing Feedback Log.
- 2026-09-12 — `app.json` version bumped directly by AJ to `0.0.3.0` (BUILD-15) — no package built at this version yet.
- 2026-09-12 — Runbook (still v2.0.0.0, folded in — AJ's call not to bump until told): added AL MCP Server + BCQuality Knowledge Snapshot support (RunbookChangelog.md). Executed for this project: `.bcquality/` snapshot fetched (commit `35d0966a`, 806 files, tracked in git alongside `.alpackages/`), `scripts/al-mcp-server.sh` (portable wrapper, re-discovers extension/runtime paths at launch) + `.vscode/mcp.json` written. Live-verified the MCP server's real tool list (16 tools) directly via a JSON-RPC handshake — differs from the brief that proposed this (no `al_debug`; several tools it didn't mention). Not yet confirmed connected as a live capability inside any Claude Code session — `claude mcp add` isn't reachable from this session's Bash tool (native VS Code extension host, no CLI on PATH); AJ to confirm whether `.vscode/mcp.json` gets picked up after a reload.
- 2026-09-12 — §1.7 Model & Effort Assignment configured for this project (`ProjectParameters.md` §1.7): Main = Sonnet, Light = Haiku, Reasoning = Opus, via the `Agent` tool. Applies going forward; steps already done were single-model and aren't redone.
- 2026-09-12 — Operating Rule 4 revised again (AJ Ansari): compiling is no longer an automatic part of BUILD at all — per-batch pre-flight now includes symbol verification (every standard-object reference confirmed against the downloaded symbol source), and the compiler is invoked only when AJ explicitly asks. This project's own 5 build batches + gap-fill were already compiled per-batch under the older rule (nothing to redo — code is already compiled clean); applies to any future gap-fill work.
- 2026-09-12 — AJ retested the live `0.0.2.0` package: neither BUILD-12 nor BUILD-13 actually resolved anything. Spun up an Opus (Reasoning role) subagent per §1.7 to re-diagnose both from scratch without editing code; both diagnoses independently verified against Microsoft Learn before trusting them (ChangeLog BUILD-16). Bug 1's real cause: `Bootcamp.Init()` reused across two inserts doesn't clear the primary key, so the second insert skips numbering and collides — fixed with an explicit `Bootcamp."No." := '';` after each `Init()`; BUILD-13's self-healing retry loop removed as unnecessary (AJ's call). Bug 2's real cause: `SubPageLink` filters live in filter group 4 ("Link"), not the default group 0 that BUILD-12's plain `GetFilter()` read — fixed with a `FilterGroup(4)` read (restored after), a hidden `Bootcamp No.` field control on the subform, and a `TestField` guard on `ocpfAttendee.OnInsert` to fail loudly instead of silently saving a blank key. BUILD-12 and BUILD-13's original ChangeLog entries marked superseded, not deleted. Also found and fixed, same pass: `.bcquality/` nested inside the project root was breaking compilation (470+ errors, all inside non-compilable `.good.al`/`.bad.al` snippet files) — relocated to a sibling directory outside the project root; `.gitignore` and `CLAUDE.md` updated to reflect the new location. Recompiled clean: 20 files, 0 errors / 0 warnings. TDD updated (§6.5, §6.11, §6.14).
- 2026-09-12 — Package built at `0.0.3.0` (BUILD-17), includes BUILD-16. Prior `0.0.1.0`/`0.0.2.0` packages left untouched in `out/`. Not yet published/retested live — see Open decisions #2 and #3.

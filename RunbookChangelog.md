# Agentic Development Framework — Changelog

Tracks changes to the **Agentic Development Framework** itself (the agent runbook that drives
DEFINE → DESIGN → BUILD → PROVE) — independent of any single project built with it. The framework
is distributed as a standalone repository; a project built from an earlier copy won't otherwise
know if or how the framework it's using has since changed. Check here for what changed and why.

Entries are grouped by version, newest first, and describe the **cumulative** result of a
version's changes — not the drafting history behind them. If a change was revised multiple times
before the version that introduced it ever shipped, only the final, current form is recorded
here as one entry; incremental churn within a single unreleased version isn't itself
change-worthy. (This is a different convention from a project's own ChangeLog, which exists
specifically to keep a superseded decision on record — see the runbook's ALL ALONG guidance.)

---

## v2.0.0.0 — 2026-09-12

First versioned revision. Everything below was learned during the framework's first real
project (a Business Central bootcamp-registration tracking PTE) and folded back into the
framework itself, dated to when each change actually happened during that project.

### Compile cadence (2026-09-11)

- **Changed — Operating Rule 4.** Previously: compile after every batch, never generate all
  batches first. Now: pre-flight each batch as it's written, but compile the whole extension
  **once**, after every planned batch is generated — not per batch.
- **Added — explicit trade-off note (AJ Ansari, 2026-09-11).** Pre-flight catches per-file
  syntax/style/pattern issues; it cannot catch cross-object semantic errors (forward references
  between batches, permission-set gaps that only fail at publish, type mismatches) — those now
  surface once, at the end, after every batch already exists, rather than one small batch at a
  time. Accepted deliberately because generation speed matters more than catching such an error
  one batch earlier; the strengthened pre-flight checks (see Permission-set coverage, below) are
  what have to catch what per-batch compilation used to catch instead.
- **Changed — Step 05, 06, 07 wording** updated to match: Step 06's actions split into
  "pre-flight per batch" vs. "compile once at the end," with a new Action 7 (see below); Step 06's
  Goal statement and Outputs/Exit gate reworded; Step 07's Inputs now reference "the single
  end-of-batches compile" rather than "per batch."

### Tooling installation (2026-09-11)

- **Added — Operating Rule 6b.** Before concluding a required compiler/runtime is missing and
  reaching for an install, check whether the human's own IDE already provisions one privately for
  the tool in question — e.g. VS Code's AL extension gets its .NET runtime from a companion
  ".NET Install Tool" extension, not a system-wide install, at a path under
  `~/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/`
  on macOS (or the equivalent per-user path elsewhere) — *before* assuming none exists. Installing
  anything is a human-in-the-loop decision (rule 6) regardless of what a fallback option
  elsewhere in the runbook lists as available.
- **Why:** on the pilot project, the agent skipped this search, concluded no .NET runtime existed
  on the machine, and installed a fresh one into `~/.dotnet` without asking — when VS Code had
  already been running the same compiler the whole time via its own private copy. The agent had
  to remove what it installed once this came to light.

### Intake — Step 01 (2026-09-11)

- **Added — §1.6 Onboarding & Discoverability.** Three new intake questions, asked at Step 01
  (not left to emerge mid-DESIGN): should the extension include an **Assisted Setup Wizard**
  (and if so, what it configures); should the Role Center get **Activity Cues** (and if so,
  which ones, their filters, and drill-through targets); should the extension be findable via
  **Departments / "My Business Central"** (and if so, under which department, with which pages).
  A `No` to any is a valid, final answer — not a placeholder to revisit.
- **Why:** discovered mid-project when the human asked "does our app have any activity cue
  tiles?" and the honest answer was no — not because it was rejected, but because nothing in the
  framework had ever asked at intake.

### Permission-set coverage (2026-09-11)

- **Changed — Step 03 (TDD) permission-set guidance.** Added: the batch plan must ship each
  table's `tabledata` grant in the *same batch* that introduces the table — never deferred to a
  later batch.
- **Changed — Step 04 (Sanity Check) checklist.** "Permission sets are planned if enabled"
  strengthened to require every table's `tabledata` grant explicitly enumerated per set, not
  just "permission sets exist."
- **Changed — Step 05 pre-flight checklist.** Added permission-set `tabledata` coverage for
  every table a batch introduces, as its own named check.
- **Added — Step 06 Action 7.** An explicit, non-compiler verification pass before leaving the
  step: every table built across every batch must have a matching `tabledata` grant in both the
  read-only and read/write permission sets. Needed specifically *because* of the compile-cadence
  change above — the platform's own check for this (`PTE0004`) fires only at publish, which now
  happens after Step 06 rather than after each batch.
- **Changed — Step 10 (Code Review) Best Practices bullet.** Added independent re-verification of
  permission-set coverage — don't just trust Step 06's check.
- **Why:** the pilot project's batch plan deferred both permission sets to the final batch (valid
  for a pure compile, but not for a publish-based workflow); publish failed with `PTE0004`
  (missing permission set) on the very first batch, forcing a batch-plan rewrite after code
  already existed. All five of the above exist so the next project catches this at design time
  instead.

### Model & effort assignment — Step 01 §1.7 (2026-09-12)

- **Added — §1.7 Model & Effort Assignment.** New intake question, asked once before DESIGN
  begins: whether to split work across a **fixed three-role division of labor**, kept
  deliberately model-agnostic (no vendor/model names, so the guidance travels to any harness). If
  configured:
  - **Main role** — all BUILD code generation, all actual code edits (including applying what the
    other two roles report), and end-to-end ownership of the project's continuity documents
    (ChangeLog, Object Register, ProjectMemory, TestingFeedback triage).
  - **Light role** — fast, cheap, checklist-driven verification only: per-batch pre-flight
    linting. Reports findings; never edits code.
  - **Reasoning role** — heavier-reasoning, fresh-eyes work: Code Review (Step 10), FRD authorship
    (Step 02), TDD authorship (Step 03), and root-cause troubleshooting/diagnosis (Step 07, and
    PROVE-phase testing-feedback triage). Reports findings/drafts/diagnoses; never edits code or
    the continuity documents itself.
  - The division is fixed regardless of which physical models are assigned to each role: the
    light and reasoning roles investigate, draft, or diagnose; the main role is the only one that
    edits code or owns the continuity documents. This preserves one consistent author/style
    across the codebase (the same concern Step 10 already names: "early and late batches often
    drift — normalize") and keeps root-cause tracing in one continuous thread instead of
    fragmenting across cold hand-offs.
  - **Wired into:** Step 02 (FRD drafted by reasoning role, sign-off unchanged), Step 03 (TDD,
    same pattern), Step 06 Action 5 (per-batch pre-flight done by light role when configured),
    Step 07 (root-cause diagnosis by reasoning role, fix applied by main role), Step 10 (review by
    reasoning role, fixes applied by main role), and the Testing Feedback Log (bug diagnosis is a
    reasoning-role task; a wrong diagnosis is marked superseded in the project's own ChangeLog,
    not deleted).

### AL MCP Server & BCQuality Knowledge Snapshot (2026-09-12)

- **Added — AL MCP Server, as a new ALL ALONG section.** The AL Language extension's standalone
  MCP server (`altool launchmcpserver`) exposes build/publish/symbol/diagnostic tools over MCP,
  so a capable harness can drive them directly instead of shelling out to the compiler by hand.
  Documented as a one-time-per-project bootstrap (locate `altool`, confirm `app.json`/`launch.json`,
  register with the harness's MCP config preferring project scope, verify the connection) plus a
  standing preference thereafter for the MCP tools over an ad hoc terminal wrapper where both are
  available. Wired into Step 05 (bootstrap at scaffold time, alongside the rest of the one-time
  project setup). **Kept harness-agnostic throughout** — no product-specific config format or CLI
  named as a requirement, only "whatever MCP host the agent's harness provides." **Cross-platform
  picture, explicit rather than assumed:** `altool.exe` is a native binary on Windows (invoke it
  directly, no wrapper needed — simpler than macOS/Linux, not harder); on macOS or Linux the
  shipped `.exe` won't run and `altool.dll` must be invoked against a .NET runtime instead — and
  the IDE-provisioned-runtime fallback path itself differs by OS (verified working on macOS this
  project; the Linux path is written from that OS's documented convention, not from an actual
  test on it).
- **Added — BCQuality Knowledge Snapshot, as a new ALL ALONG section.** `microsoft/BCQuality` is
  a curated knowledge base and skill library for BC AL code quality (non-obvious platform rules,
  security/performance/privacy footguns) — content, not a service. Documented as a one-time
  snapshot per project (shallow `git clone` into a project-local folder, `.git` stripped, a
  `SNAPSHOT.json` recording the commit SHA and fetch time), used locally for the rest of the
  project with no further network access, and refreshed only on explicit request (report old vs.
  new commit SHA when it happens). Documents the actual consumption protocol — read `skills/entry.md`
  with an explicit task-context, get back a dispatch record, invoke the named action skill(s),
  read the `read.md`/`do.md` meta-skill contracts on demand, integrate structured findings
  (outcome, per-finding domain/references/confidence, a suppressed list) the same way as any
  other review finding, never applied blind. Wired into Step 05 (bootstrap at scaffold time) and
  Step 10 (an independent review pass alongside the Standards Anti-Patterns check).
- **Why the verification pass mattered:** both sections were checked against the actual installed
  tooling and the upstream repo's own current documentation before being written in, rather than
  transcribed from the brief that proposed them. That check found real drift from the brief: no
  `al_debug` tool exists (several others do that the brief never named); BCQuality's
  agent-consumption reference lives at `docs/agent-consumption.md`, not the repo root; and its
  `custom/` layer exists upstream (with a template `README.md`) rather than only in forks — it's
  simply empty of actual knowledge content. Both sections tell a future reader to re-verify
  against the live source rather than trust a paraphrase, including this one — the upstream repo
  is explicitly under active development.

---

## v1.0.0.0 — baseline

The version the framework was at when the pilot project (Bootcamp Registration Tracking) began.
Assigned this number retroactively — the framework wasn't itself versioned before v2.0.0.0 — as
the starting point every change above is measured against. No changelog entries exist prior to
this point.

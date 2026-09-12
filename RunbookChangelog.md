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

### Compile cadence (2026-09-11 → 2026-09-12)

- **Changed — Operating Rule 4.** Original rule: compile after every batch, never generate all
  batches first. Final form: **no per-batch compile at all.** Every batch is pre-flighted as it's
  written — including a new **symbol verification** check (every reference to a standard/base
  object, field, method, property, or enum value confirmed against the downloaded symbol source,
  falling back to the MS Learn BaseApp docs per Operating Rule 2 when the downloaded symbols don't
  answer). The whole extension compiles exactly **once**, automatically, the moment every planned
  batch (including gap-fill work) is written — this is now Step 07's opening action, not an
  open-ended "whenever the human asks." A human may also request an earlier spot-check compile
  mid-BUILD; that's additional, not a substitute for the one at the end of BUILD.
- **Fixed — every other place that assumed a different compile timing.** A self-consistency
  review the same day found six places still contradicting the tightened rule: Step 05's exit
  gate required a compile before any code existed; Step 07's own outputs/exit gate reinstated the
  "compile clean before BUILD closes" version the rule had just removed; Step 09 listed a
  clean-compiling extension as an *input* to the step that might produce it; the Packaging
  section's repackage trigger ("a batch finishes compiling") could never fire once batches stopped
  compiling; the AL MCP Server bootstrap told the agent to "invoke a build tool" during Step 05
  scaffold setup; and Rule 5 ("zero errors before PROVE") allowed the first compile to happen
  as late as inside Step 09, two steps into PROVE. Resolved by making the single mandatory compile
  a well-defined, always-runs point (Step 07 Action 0) rather than an arbitrarily deferred one —
  Rule 5 is now true by construction instead of contradicted.
- **Why symbol verification, specifically:** a lint pass without it is pattern-matching from the
  same kind of intuition that produces a hallucinated reference in the first place — checking
  against the actual symbols is the one thing that verifies against ground truth instead of a
  plausible-looking guess. This is what closes the gap left by deferring the compiler further.
- **Trade-off, accepted deliberately (AJ Ansari):** even symbol-verified lint cannot catch
  everything a real compile does — cross-file type mismatches, full semantic validation, and rule
  interactions the compiler's own engine resolves are still invisible until an actual compile
  runs. A systemic issue found only at that eventual compile can therefore touch more
  already-written files than catching it earlier would have. Accepted because generation speed
  matters more, and because symbol verification specifically targets the failure mode this
  decision was actually worried about.
- **Changed — Step 05, 06, 07 wording** updated to match throughout: Step 05's pre-flight list
  gains the symbol-verification check; Step 06 no longer compiles at all as part of its own exit
  gate (lint-clean, including symbol verification, is what closes it); Step 07's Inputs now read
  from "whenever compiling is actually triggered" rather than assuming it happens right after
  Step 06; the BUILD phase's own Goal statement was reworded to match.

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
    other two roles report), and end-to-end ownership of the project's continuity documents:
    ChangeLog, Object Register, ProjectMemory, and `TestingFeedback.md` itself (recording sessions
    verbatim, then logging the triage decision once the reasoning role's diagnosis confirms it).
  - **Light role** — fast, cheap, checklist-driven verification only: the Step 05
    post-generation pre-flight pass, **explicitly including symbol verification** (a lookup
    against ground truth, not a judgment call, so it fits the cheap/fast role rather than the
    reasoning role). Reports findings; never edits code.
  - **Reasoning role** — heavier-reasoning, fresh-eyes work: Sanity Check (Step 04), Gap-Fit Test
    (Step 08), Code Review (Step 10), FRD authorship (Step 02), TDD authorship (Step 03), and
    root-cause troubleshooting/diagnosis (Step 07, and diagnosing *why* a PROVE-phase
    testing-feedback report is real). Reports findings/drafts/diagnoses; never edits code or the
    continuity documents itself.
  - The division is fixed regardless of which physical models are assigned to each role: the
    light and reasoning roles investigate, draft, or diagnose; the main role is the only one that
    edits code or owns the continuity documents. This preserves one consistent author/style
    across the codebase (the same concern Step 10 already names: "early and late batches often
    drift — normalize") and keeps root-cause tracing in one continuous thread instead of
    fragmenting across cold hand-offs.
  - **Wired into:** Step 02 (FRD drafted by reasoning role, sign-off unchanged), Step 03 (TDD,
    same pattern), Step 04 and Step 08 (both formal reviews, same pattern as Step 10), Step 05/06
    (the pre-generation pre-flight pass is main-role TDD housekeeping; the post-generation pass is
    light-role), Step 07 (root-cause diagnosis by reasoning role, fix applied by main role),
    Step 10 (review by reasoning role, fixes applied by main role), and the Testing Feedback Log
    (diagnosis is reasoning-role; the main role applies the fix and separately owns the triage
    recording itself — a wrong diagnosis is marked superseded in the project's own ChangeLog, not
    deleted).

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

### Full self-consistency review (2026-09-12)

A dedicated reasoning-role pass (§1.7) read the entire runbook end to end looking for places
where it contradicted itself — separate from, and in addition to, the compile-cadence and
model-role fixes recorded above. Beyond those two (the highest-impact findings), it also found
and fixed:

- **Permission sets: an optional parameter enforced unconditionally.** Parameter 1.2 let a human
  answer `Permission Sets required? No`, but Steps 05/06/10 checked `tabledata` coverage
  unconditionally, and Step 03's own text says `PTE0004` requires it for every table anyway.
  **Resolved (AJ Ansari):** `No` is now stated as valid *only* when the extension introduces zero
  new tables of its own (e.g., a pure page/report extension on standard objects) — the one case
  PTE0004 genuinely doesn't reach. The later unconditional checks are correct as written: they're
  vacuously satisfied when there are no tables, so no wording change was needed there beyond
  noting it explicitly.
- **Cross-reference integrity.** The header's companion-doc scope said "Parts 2–11" while Steps 09
  and 12 cite Part 12 seven times — widened to "Parts 2–12". Rule 6b cited "Rule 6" for
  installing-tooling approval, but Rule 6's own list was a closed enumeration that didn't include
  it — added a fifth item to Rule 6 rather than leave a pointer to something not actually there.
  Two unrelated citations ("AZ AL Dev Tools rules" and "commit each batch separately") both named
  "Appendix C" — flagged as unverified rather than guessed at, since the companion Standards doc
  isn't in this repo to check.
- **Harness/OS residue.** §1.7 states a no-vendor-names policy that Rules 6a/6b then broke without
  marking the product names as adaptable examples — both now explicitly say "substitute whatever
  your own harness/OS provides." Rule 6b's tooling-discovery path was macOS-only despite the AL
  MCP Server section (written later in the same session) already handling Windows/macOS/Linux
  separately — 6b now lists all three. Step 12's `npx @mermaid-js/mermaid-cli` instruction now
  notes it may install on first run and that Rule 6b applies to it.
- **Document inventory.** The ALL ALONG "keep every document current" list named `Documentation`
  but omitted three of Step 12's four mandatory outputs — `UserGuide`, `HumanUnitTestScript`, and
  `Deployment` — added. Also clarified the previously-unstated boundary between `Documentation.md`
  (a developer's quick-start) and `Deployment.md` (an administrator's full install/upgrade/
  uninstall procedure), the same way the runbook already distinguishes `UserGuide` from
  `Documentation`.
- **BCQuality kickoff timing.** Its own section said "fetch at project kickoff"; Step 05 (five
  steps later, in BUILD) said to bootstrap it there. Aligned both on Step 05, since that's where
  the rest of the one-time project scaffold already lives and where this project actually did it.

**Verification pass, same day.** A second, independent reasoning-role instance re-read the whole
document fresh to confirm the fixes above actually held together — not just that each fix existed,
but that the fix pass hadn't introduced anything new. It found two more real issues, both fixed:

- **Self-contradiction in the Step 05 permission-set check.** The parenthetical said a missing
  `tabledata` grant "fails at publish, not at compile, so pre-flight is the only thing that
  catches it **before the mandatory Step 07 compile does**" — which asserts in the same breath
  that the compile both doesn't and does catch it. `PTE0004` is a publish-time check; no compile
  ever catches it. Reworded to say plainly that nothing automated catches it besides pre-flight.
- **"Including gap-fill work" made the mandatory compile's trigger undefined.** Rule 4 said the
  one compile happens once every batch "including gap-fill work" is written — but gap-fill items
  are a **Step 08** (PROVE) output, which runs *after* Step 07's compile. Taken literally, the
  compile would either wait forever for work that can't exist yet at that point, or gap-fill code
  would never get compiled at all. Fixed by scoping the mandatory Step 07 compile to the
  TDD's originally-planned batches only, and stating explicitly that gap-fill — whether ad hoc
  mid-project (as actually happened on the pilot project) or a formal Step 08 output — gets its
  own pre-flight-then-compile pass through the same Step 05/06/07 discipline, when it's actually
  written. Also smoothed two smaller items the same pass flagged: Step 07's Inputs no longer
  overclaim "none yet compiled" (an earlier human-requested spot-check may have already run), and
  its action numbering ("0." followed by "1/2/3") was reworded as plain "first… then…" prose to
  remove the false impression that the compile was a peer of the three troubleshooting questions
  rather than what precedes them.

---

## v1.0.0.0 — baseline

The version the framework was at when the pilot project (Bootcamp Registration Tracking) began.
Assigned this number retroactively — the framework wasn't itself versioned before v2.0.0.0 — as
the starting point every change above is measured against. No changelog entries exist prior to
this point.

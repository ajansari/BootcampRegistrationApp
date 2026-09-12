# BC App Build Routine — Agent Runbook

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

**Version:** 2.0.0.0
**Last Updated:** 2026-09-12

> Version history for this framework lives in `RunbookChangelog.md`, tracked independently of any
> one project built with it — check there for what changed between the version you have and the
> latest.

> **What this is:** A single, ordered routine an AI agent follows to build a new Business Central AL Per-Tenant Extension (PTE) from a business problem through to a tested, documented, deployable app.
>
> **How the agent uses it:** Work the phases in order (DEFINE → DESIGN → BUILD → PROVE). Do not start a step until its predecessor's exit gate is met. Every step lists its **Inputs**, **Actions**, **Outputs**, and **Exit gate**. The *Project Parameters* block in Step 01 is the single source of truth for every name, ID, version, and quoting decision — never hardcode any of those values in AL; always derive them from that block.
>
> **Companion document:** `AL_PTE_Development_Standards_UNIFIED.md`. This runbook drives the *sequence*; that guide holds the detailed *rules* (Parts 2–12, Appendices A–C). References below point to it as **Standards §**.
>
> **Prime directive for the agent:** An ambiguous input produces ambiguous code. If a step's inputs are incomplete or contradictory, stop and ask the human — do not invent rules to fill the gap.

---

## Operating Rules (apply in every phase)

1. **Part 1 is authoritative.** Publisher, prefix, namespace, versions, ID ranges, localization — read them from the Project Parameters block (Step 01) and derive everything else. Never hardcode.
2. **Verify against BC symbol files, not memory.** Table numbers, `using` namespaces, field IDs, `ObsoleteState` — confirm each in the symbol file named in Parameter 1.4. Agent knowledge of BC table numbers is not reliable (Standards §10.5, Appendix B). **Fallback when the downloaded symbols don't answer the question** (a module isn't in `.alpackages`, or you need to browse/discover rather than already knowing what to grep for): the entire BC BaseApp, for the current Business Central Online version, is documented at <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application> — every standard table, field, and field datatype/size. Use it to corroborate or discover; the downloaded symbol file for the target version is still the authoritative source when the two ever disagree.
3. **Phase large scope into batches.** A batch is a self-contained, reviewable increment (by module or document-type group) — designed to be independently correct even though, under Operating Rule 4, it is not compiled on its own to prove it. Define batch boundaries during DESIGN and record them in the TDD (Standards §2 intro, §10.3).
4. **Lint every batch as it's written, including symbol verification. Do not compile per batch — the whole extension compiles exactly once, immediately once every planned batch (including gap-fill work) is written, gating entry to PROVE.** Run the Step 05 pre-flight checklist against each file immediately (Step 05 defines the full list, split into a pre-generation pass and a post-generation pass) — including **symbol verification**: for every reference to a standard/base object, field, method, property, or enum value, verify it against the downloaded symbol source (falling back to the MS Learn BaseApp docs per Operating Rule 2 when the downloaded symbols don't answer), not just against what looks like plausible AL. That check exists specifically against hallucination: a pattern-matching lint pass draws on the same kind of intuition that produces a hallucinated reference in the first place, so checking against the actual symbols is the one thing that verifies against ground truth instead of a plausible-looking guess. Do not invoke the AL compiler as an automatic part of generating batches. The one mandatory compile happens in Step 07, triggered the moment Step 06 finishes — not deferred further, and not skipped. A human may also request an earlier spot-check compile mid-BUILD; that doesn't replace the mandatory one. Whenever a compile does run, treat any error as a systemic signal: fix the rule/template, then every file it touched — across every batch, not only the one where the error surfaced (Standards §9.3, §10.3).
    **Trade-off, accepted deliberately (AJ Ansari, 2026-09-12, superseding the 2026-09-11 "compile once at the end" version of this rule):** even symbol-verified lint cannot catch everything a real compile does — cross-file type mismatches, full semantic validation, and rule interactions the compiler's own engine resolves are still invisible until an actual compile runs. Deferring the first real compile further than before means a systemic issue found late can touch more already-written files than catching it mid-BUILD would have. Accepted because generation speed matters more, and because symbol verification specifically closes the gap this decision was actually worried about — a reference to something that doesn't exist, dressed up as something that does.
5. **Zero errors, zero warnings before PROVE.** Treat warnings as errors during development (Standards §9.4). Satisfied by construction under Rule 4: the one mandatory compile (Step 07) always runs, and must reach 0/0, before Step 08 begins.
6. **Human-in-the-loop is a feature.** Pause for human approval before: writing the first file of a batch, applying a root-cause fix, starting a new batch, finalizing any design document, and installing any tool or runtime.
6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human to *decide something* — pick between design options, approve a version bump, choose a name, resolve an ambiguity — present it through the interactive multiple-choice mechanism the agent's harness provides (e.g., in Claude Code, the `AskUserQuestion` tool — substitute whatever the actual harness offers), with the recommended option first and a short reason on each. A decision buried in a paragraph of chat is easy to miss: it reads like the agent finished and is idling, so the project silently stalls waiting on an answer nobody realised was owed.
    **Use it only for decisions.** Do *not* wrap ordinary progress in it — finishing a step and waiting to be told to start the next one, reporting a clean compile, or handing back a result is normal conversation, not a decision point. Over-using the box makes it noise, which defeats the purpose.
6b. **Don't install tooling without asking — and look harder first.** Before concluding a required compiler/runtime is missing and reaching for an install, check whether the human's own IDE already provisions one privately for the tool in question — e.g., VS Code's AL extension gets its .NET runtime from a companion ".NET Install Tool" extension, not a system-wide install, at a path that differs by OS: `~/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/` on macOS, `~/.config/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/` on Linux, `%APPDATA%\Code\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\` on Windows — check the one matching the actual machine, not just the first one you think of, *before* assuming none exists. If the human's own editor can already do the thing you're about to install a tool for, that's a strong signal the tool already exists somewhere you haven't looked. Installing anything is itself a human-in-the-loop decision (rule 6) regardless of what a fallback option elsewhere in this runbook lists as available — on a real project the agent skipped the search, wrongly installed a fresh runtime, and had to remove it.
7. **Log every deviation immediately.** Any departure from FRD or TDD goes in the ChangeLog before the next batch starts (see *All Along*).

---

# PHASE: DEFINE

Goal: turn a business need into a validated, complete scope and a filled-in parameter sheet — before any design work.

## PRE-01 — State the Problem

**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**
- Write a problem statement: what business outcome is required, who the consumers are (users, other systems, AI tools, BI/reporting), and what is explicitly out of scope.
- Capture the domain vocabulary the design will anchor to (entity names, categories, known pain points).
- Produce an initial entity/object list from stakeholder domain knowledge.
- As the agent: identify duplicates, ambiguous terms, and outdated/legacy terminology in the initial list; ask clarifying questions about scope and consumer use cases. Do not resolve ambiguities silently.

**Outputs:** `ProblemStatement.md` — purpose, scope, out-of-scope, target consumers, initial entity list, open questions.

**Exit gate:** Functional Consultant signs off on the problem statement and initial entity list (Standards §2.2 Stage 1).

## PRE-02 — Structured Gap Analysis

**Inputs:** `ProblemStatement.md` and the initial entity list.

**Actions:** Run the gap analysis checklist against standard BC modules (Standards §8). For every transactional entity, check each category:
- **Analytical detail tables** — sub-ledgers, detailed ledger entries, value entries, registers, audit trails (§8.1).
- **Posted / archived versions** — the posted equivalent of every open document, header *and* lines (§8.2).
- **Reference / lookup tables** — payment terms/methods, currencies, countries, UoM, locations, shipment methods, item categories, salesperson/purchaser codes (§8.3).
- **Secondary document types** — quotes, blanket orders, return orders alongside orders (§8.4).
- **Modern vs. legacy tables** — replace legacy price tables etc. with current equivalents; use modern entity names (§8.5).
- **Tax framework tables** — decide per the target localization; do not assume (§8.6).
- **Global vs. localized scope** — mark each entity as global or jurisdiction-specific.

**Outputs:** Expanded, de-duplicated entity list with each entity tagged (analytical / master / setup / document / posted / lookup), R/W intent noted, and global-vs-localized noted. Gap log: what was added and why.

**Exit gate:** Technical Lead reviews the expanded list; all gaps are closed or explicitly deferred with reasoning (Standards §2.2 Stage 2).

## 01 — Populate the Intake Sheet (Project Parameters)

**Inputs:** Expanded entity list; platform/tenant constraints from the stakeholder; BC symbol file for the target version.

**Actions:** Complete **every** field below. Replace every placeholder. These values override all defaults for the rest of the routine. This block is copied verbatim from `AL_PTE_Development_Standards_UNIFIED.md` Part 1 and is the authoritative source (Standards §1, "Authoritative-source rule").

**Ask first, don't infer.** If `Extension Name`, `Publisher`, `Use Namespace (y/n)`, `Namespace`,
`Localization`, or `AL Object Prefix` (§1.3) still carry placeholder values, ask the human
directly — as these five questions, before writing anything:

1. What is the Extension Name?
2. Who is the Publisher?
3. Should this project use an AL namespace? If yes, what should it be (e.g.
   `<Publisher>.<ExtensionShort>`)?
4. What Localization applies (`W1`, `US`, …)?
5. What AL object prefix should be used?

Do not infer these from context under time pressure (an email domain, a guess at house style) —
that produces exactly the kind of full-project rename this framework has already had to do once
on a real project, after the inferred publisher and prefix turned out to be wrong.

**Then collect Object ID ranges (§1.2) the same way — as a loop, not a single question,** since
there can be more than one range:

1. Ask for the starting Object ID.
2. Ask for the ending Object ID.
3. Show the resulting range and its size (e.g. "80300–80339 — 40 IDs") and ask the human to
   confirm it.
4. Ask: "Are there additional ranges?" (Y/N).
5. If yes, repeat steps 1–4 for the next range. If no, stop — every confirmed range is final.

The first confirmed range is the Primary allocation; every one after it is an Additional
allocation — there can be more than one.

### 1.1 Extension Identity

| Parameter | Placeholder | Guidance & Example |
|---|---|---|
| **Extension Name** | `<ExtensionName>` | App name, not the object prefix. No AL quotes. Written to `app.json "name"`. Example: `ACME APIs` |
| **Publisher** | `<Publisher>` | No AL quotes here. Written to `app.json "publisher"`. Example: `Contoso` |
| **Deployment Target** | `<DeploymentTarget>` | One of the allowed values below. Governs `app.json` and `launch.json`. |
| **Use Namespace (y/n)** | `<UseNamespace>` | Whether this project's AL objects declare a `namespace`. Default `Yes` — omit it only for a deliberate reason (e.g. a target AL/BC version that predates namespaces). If `No`, the `Namespace` row below is N/A and no generated file gets a `namespace` line. |
| **Namespace** | `<Publisher>.<ExtensionShort>` | N/A if Use Namespace = `No`. Otherwise no quotes; PascalCase segments, no spaces. Example: `Contoso.AcmeAPIs` |
| **Localization** | `<Localization>` | No quotes. **Set once here** — Part 5 derives all field/table inclusion from this value. Examples: `W1`, `NA`, `EU`, `US`. |

**Deployment Target — allowed values (choose exactly one):**
- `AppSource` — Microsoft AppSource distribution.
- `SaaS PTE` — Business Central SaaS per-tenant extension.
- `OnPrem PTE` — on-premises per-tenant extension.

**Quoting reference — applies to every AL and config file in the project:**

| Context | Quote style | Example |
|---|---|---|
| `app.json` / `launch.json` values | Standard JSON strings | `"publisher": "Contoso"` |
| AL string property values | Single quotes | `APIPublisher = 'Contoso';` |
| AL object names | Double quotes | `page 90800 "acmeCustomers"` |
| BC source field names containing spaces | Double quotes on the field name | `Rec."Document No."` |

**Worked example:**
- `Extension Name = ACME APIs`
- `Publisher = Contoso`
- `Deployment Target = SaaS PTE`
- `Use Namespace = Yes`
- `Namespace = Contoso.AcmeAPIs`
- `Localization = W1`

### 1.2 Object ID Allocation

Collected as the loop described above — one row per confirmed range, in the order confirmed:

| Block | From | To | Notes |
|---|---|---|---|
| **Primary allocation** | `<fromObjectId>` | `<toObjectId>` | The first range confirmed; the main scope. |
| **Additional allocation 1** *(if any)* | `<additionalFrom1>` | `<additionalTo1>` | Second confirmed range, if the human said yes to "additional ranges?" |
| **Additional allocation N** *(if any)* | … | … | Repeat one row per further "yes" — there is no fixed limit. |

| Parameter | Value | Guidance |
|---|---|---|
| **Permission Sets required?** | `Yes` / `No` | `No` is a valid answer **only when the extension introduces zero new tables of its own** (e.g., a pure page/report extension on standard objects) — the one case where BC PTE publish validation (`PTE0004`) doesn't require an in-package permission set. The moment the project owns even one table, this must be `Yes`; it stops being a free choice. If `Yes`, reserve ≥ 2 IDs inside the primary range and deliver per Standards §7.3. |

> **Rule:** Never use object IDs outside the allocated ranges. Maintain the object register as a separate project artifact. If the project plans any new table, `Permission Sets required` must be `Yes` and they must be planned before code generation — do not accept `No` alongside a table in the entity list without flagging the contradiction back to the human.

**Worked example** (the loop ran twice): starting ID `90800`, ending ID `90899` → shown as
"90800–90899 — 100 IDs," confirmed → "additional ranges?" → Yes → starting ID `91500`, ending ID
`91549` → shown as "91500–91549 — 50 IDs," confirmed → "additional ranges?" → No → stop. Final:
Primary `90800`–`90899`; Additional allocation 1 `91500`–`91549`; Permission Sets required = `Yes`.

### 1.3 Naming & API Parameters

> These values govern every AL object, API registration, and permission set. Do not hardcode them — derive all names from this table. **These parameters directly control the entity-naming patterns used in Standards Part 4.**

| Parameter | Placeholder | Guidance & Example |
|---|---|---|
| **AL Object Prefix** | `<prefix>` | Short, lowercase, no quotes. Used in page names and identifiers. Example: `acme` |
| **APIPublisher** | `'<Publisher>'` | Single quotes in AL page metadata. Example: `'Contoso'` |
| **APIGroup Prefix** | `<prefix>_` | Lowercase prefix + underscore, no AL quotes. Example: `acme_` |
| **APIVersion** | `'v<Major>.<Minor>'` | Single quotes in AL. Example: `'v1.0'` |
| **Namespace** | `<Publisher>.<ExtensionShort>` | Same value as Section 1.1; N/A if Use Namespace = `No`. Example: `Contoso.AcmeAPIs` |
| **Permission Set Prefix** | `<PREFIX> - ` | Uppercase, no AL quotes. Example: `ACME - ` |

**Entity-naming patterns** — all derived from the prefix above (examples use prefix `acme`):

| Element | Pattern | Example |
|---|---|---|
| `APIGroup` | `'<prefix>_<camelCaseGroupName>'` | `'acme_coreFinancial'` |
| `EntityName` (singular) | `<prefix><PascalCaseSingular>` | `'acmeGeneralLedgerEntry'` |
| `EntitySetName` (plural) | `<prefix><PascalCasePlural>` | `'acmeGeneralLedgerEntries'` |
| `ODataKeyFields` | `SystemId` | Always. On every page. |
| Page object name | Same as `EntitySetName`, in double quotes | `page 90801 "acmeGeneralLedgerEntries"` |

- `EntitySetName` and `EntityName` must be ≤ 30 characters **including** the prefix. Apply abbreviations from Standards §6.2 as needed.
- **Singleton tables** (e.g., General Ledger Setup, Company Information): set `EntityName = EntitySetName`. The OData response is a single-entry collection.
- **Legacy vs. modern names:** use the modern BC name in entity identifiers. Example: Table 167 "Job" → `EntityName = '<prefix>Project'`.

### 1.4 Platform & Runtime

| Parameter | Placeholder | Guidance & Example |
|---|---|---|
| **AL Runtime** | `<major.minor>` | No quotes. Set in `app.json "runtime"`. Example: `16.0` |
| **BC Application Minimum** | `<major.minor.build.revision>` | No quotes. Set in `app.json` dependencies. Example: `27.0.0.0` |
| **Recommended BC Version** | `<BC version>` | Informational; validation target. Example: `27.5+` |
| **Symbol Source** | `<BC symbol file version>` | Symbol file used for verification (Appendix B). Example: `BC v27.5 symbol file` |

> Localization is **not** repeated here — it is set once in Section 1.1.

### 1.5 Feature Flags (Fixed — Not a Parameter)

`NoImplicitWith` is **enabled and enforced** on every project. This is a given, not a choice — do not change it.

| Flag | Status | Reason |
|---|---|---|
| `NoImplicitWith` | **Enabled (enforced)** | Requires every field source to be prefixed with `Rec.`, which prevents silent field-scoping bugs where an unqualified field name resolves to the wrong record. Enforcing it project-wide keeps all generated AL consistent and removes a whole class of ambiguous references. |

### 1.6 Onboarding & Discoverability

> These decisions shape real objects — a wizard page, Role Center cue fields, department/Tell Me
> entries — so ask them at intake, not part-way through DESIGN when the object inventory is
> already being drafted around their absence. Ask the same way as the §1.1 identity questions:
> an explicit question each, before assuming an answer either way.

Ask these three questions:

1. Should this extension include an **Assisted Setup Wizard**? If yes, what should it configure
   (e.g., number series, default setup values, sample/demo data, permission set assignment)?
2. Should the Role Center get **Activity Cues** (the numeric tiles summarizing counts that need
   attention — e.g., overdue items, unpaid records)? If yes, which cues, each one's underlying
   filter, and what it opens when clicked?
3. Should this extension be **findable via Departments / "My Business Central"** (the role-based
   menu and Tell Me search surface — a different discovery path than the Role Center)? If yes,
   under which department/category, and which pages should appear there?

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Assisted Setup Wizard** | `<AssistedSetupYN>` | `Yes`/`No`. If `Yes`, list exactly what it configures — not a bare yes. |
| **Activity Cues** | `<ActivityCuesYN>` | `Yes`/`No`. If `Yes`, list each cue: what it counts, its filter, and its drill-through target. |
| **Departments / My Business Central placement** | `<DepartmentsYN>` | `Yes`/`No`. If `Yes`, name the department/category and which pages appear there. |

A `No` to any of these is a valid, final answer — not a placeholder to revisit later. Record the
answer and reasoning in `ProblemStatement.md` or the Project Parameters sheet; a `Yes` answer's
specifics feed the FRD (Step 02) object inventory and the TDD (Step 03) per-object spec directly.

### 1.7 Model & Effort Assignment (Optional)

> Ask once, at intake, before DESIGN begins — Step 02/03 authorship depends on the answer.
> If the human has no preference, skip this: everything runs through the main model, as if this
> section didn't exist.

**Superseded 2026-09-12 (AJ Ansari) — from "record a preference" to a fixed division of labor.**
Earlier guidance here only *recorded* a stated preference as documentation, on the reasoning that
the executing agent can't switch its own model mid-session. That's still true, but it missed the
actual point: the agent *can* delegate a specific, self-contained task to a subagent running a
different model, get a result back, and act on it — a mechanism-agnostic capability, not tied to
any one harness. AJ's decision below uses exactly that, for three fixed roles, kept deliberately
generic (no vendor/model names) since this runbook travels to projects on other harnesses:

Ask: "This framework can split work across up to three roles, each potentially a different model.
Do you want to configure this, or should everything run through one model?"

If configuring, capture three role assignments:

1. **Main role** — does the bulk of the work: all BUILD code generation, all actual code edits
   (including applying what the other two roles report), and end-to-end ownership of the
   project's continuity documents — ChangeLog, Object Register, ProjectMemory, and
   `TestingFeedback.md` itself (recording sessions verbatim, then logging the triage decision —
   implement / schedule / reject — once the reasoning role's diagnosis below confirms it). A
   capable general-purpose model is the right fit here.
2. **Light role** — fast, cheap, checklist-driven verification only: the Step 05
   **post-generation** pre-flight pass (required-property presence, `Rec.`-qualification, dead
   code, indentation, permission-set coverage, and **symbol verification** against the downloaded
   source). Symbol verification belongs here deliberately, not with the reasoning role: it's a
   lookup against ground truth, not a judgment call, so the fast/cheap role handles it fine.
   Reports findings; never edits code itself. A fast, lower-cost model is the right fit here.
3. **Reasoning role** — heavier-reasoning, fresh-eyes work: Sanity Check (Step 04), Code Review
   (Step 10), Gap-Fit Test (Step 08), FRD authorship (Step 02), TDD authorship (Step 03), and
   root-cause troubleshooting/diagnosis (Step 07, and diagnosing *why* a PROVE-phase testing-feedback
   report is real, before the main role triages and records it). Reports findings, drafts, or
   diagnoses; never edits code or the continuity documents itself. A stronger-reasoning model is
   the right fit here.

**The division of labor is fixed regardless of which physical models are assigned to each role.**
The light and reasoning roles investigate, draft, or diagnose; the main role is the *only* one
that edits code and the *only* one that owns the continuity documents end to end. This keeps one
consistent author/style across the codebase — the same discipline Step 10 already asks for
internally ("early and late batches often drift — normalize") — and keeps root-cause tracing in
one continuous thread instead of fragmenting across cold hand-offs. A role holder's output is
always relayed back and integrated by the main role; never applied blind.

**How to delegate a role in practice** (adapt to whatever mechanism the executing agent's own
harness provides for running a task under a different model): hand the role-holder the specific
inputs its task needs — the relevant project documents, the code or finding in question, the
standing checklist — plus a pointer to this runbook itself, since every rule in it applies to
whichever role is acting, not only the main role.

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Model/role assignment** | `<ModelRolesYN>` | `No` (default — one model for everything) or a 3-row table: Main role / Light role / Reasoning role → the model assigned to each. |

**Outputs:** The completed Project Parameters block (above, all placeholders replaced); an empty **Object Register** artifact seeded with the allocated ID ranges.

**Exit gate:** No placeholder remains. Deployment Target is one allowed value. Namespace matches between 1.1 and 1.3, or both are correctly N/A if Use Namespace = `No`. Localization is set. If Permission Sets required = `Yes`, ≥ 2 IDs are reserved in the primary range. §1.6's three questions are each answered `Yes`/`No` with specifics recorded for any `Yes`. §1.7 is answered or explicitly skipped. Human confirms the sheet.

---

# PHASE: DESIGN

Goal: a complete FRD and a self-sufficient TDD, both validated for BC feasibility and internal consistency, before any code.

## 02 — Craft the Functional Requirements Document (FRD)

**Role:** if §1.7 role assignment is configured, drafted by the **reasoning role**, fed
`ProblemStatement.md`, the expanded entity list, and Project Parameters; the main role integrates
the draft (saves it, does the ChangeLog/ProjectMemory bookkeeping) and takes it to the human for
sign-off. Sign-off is unchanged either way — it's the human's, never the drafting role's.

**Inputs:** `ProblemStatement.md`, expanded entity list + gap log, Project Parameters.

**Actions:** Write the FRD in business language — *what* the extension does and *why*, not *how* (Standards §2.1). It must capture:
- Purpose and scope; explicit out-of-scope list.
- Business objectives and the value delivered.
- Target consumers (users, systems, AI tools, reports).
- Platform requirements (BC version, deployment model, compatibility) — from Parameters 1.1 and 1.4.
- Design rules — the non-negotiable constraints governing every object.
- Entity / object inventory — every object with source table, type, and read vs. read/write designation (use the mutability rules in Standards §4.2).
- Non-functional requirements — compilation cleanliness, performance, compliance, deployment.

Then **review and validate against the DEFINE artifacts:** every entity in the expanded list appears in the FRD inventory (or is listed as deferred with a reason); every consumer use case from PRE-01 is addressed. For every platform capability the FRD assumes, verify BC can actually do it — do not write requirements based on assumed platform behavior.

**Outputs:** `FRD.md`.

**Exit gate:** FRD + Dev Manager sign-off. Every DEFINE-phase entity is accounted for. No unverified platform assumptions remain (Standards §2.2 Stage 4).

## 03 — Craft the Technical Design Document (TDD)

**Role:** if §1.7 role assignment is configured, drafted by the **reasoning role**, fed `FRD.md`,
Project Parameters, and the symbol file; the main role integrates the draft and takes it to the
human for sign-off, same as Step 02.

**Inputs:** `FRD.md`, Project Parameters, BC symbol file (Parameter 1.4).

**Actions:** Translate the FRD's *what* into a precise *how*. The TDD must be self-sufficient: a developer or agent who has never seen the project must be able to produce every object correctly from the TDD alone (Standards §2.3). Include:
- **System identity** — Publisher, namespace, prefix, APIPublisher, APIGroup prefix, APIVersion, AL runtime, BC minimum, object ID ranges (all from Part 1).
- **Module grouping** — cluster entities into cohesive functional modules; assign each module a contiguous ID sub-block with a growth buffer (min 20% unallocated) and a tail block for cross-module additions (Standards §7.1–§7.2).
- **Batch / phase plan** — which modules or document-type groups are built in which order; smallest and simplest batch first (Standards §10.3).
- **Per-object spec** — for every object: ID, type, name, source table name *and* verified source table number, `PageType`, `APIPublisher`, `APIGroup`, `EntityName`, `EntitySetName`, `ODataKeyFields = SystemId`, and exactly one of `DelayedInsert = true` / `Editable = false` per §4.2.
- **Per-field spec** — every field by source name and camelCase identifier, with each conversion decision shown (Standards §6.1); which fields are excluded and why (Standards Part 5, driven by the Localization parameter); abbreviations applied (Standards §6.2); reserved-keyword resolutions (Standards §6.3).
- **Computed-field pattern, decided per field, not defaulted:** a `FlowField` is always read-only and always live-recalculated — it cannot be overridden. A field that should *suggest* a value but let the user override it (e.g. a price or date derived from other fields) must be a real **stored** field, seeded by an `OnValidate`/`OnInsert` trigger, that never overwrites a value the user has already entered — the same pattern as an R-1-style suggested-date rule. Decide and state explicitly which pattern each calculated-looking field uses; do not reach for `FlowField` out of habit when "auto-populated but editable" is what's actually wanted.
- **`SourceTableView` filters** — for every document-type-filtered page, with the correct `const()` quoting (quote only multi-word enum values) (Standards §4.3).
- **`using` directives** — the exact namespace for every object, copied from the symbol file (Standards §3.1, §5.4).
- **Standard object template** — the exact AL API page pattern every generated object must follow (Standards §3.3).
- **Special design notes** — singletons (`EntityName = EntitySetName`), header/line pairs as two top-level pages, high-volume tables, naming conflicts.
- **Permission sets** — if Parameter 1.2 = `Yes` (mandatory the moment the project owns any table — see Parameter 1.2): a read-only set and a read/write set (including the read-only set), both with IDs from the allocated range and names from the Permission Set Prefix (Standards §7.3). **The batch plan must ship each table's `tabledata` grant in the same batch that introduces the table — never deferred to a later batch.** BC PTE publish validation (`PTE0004`) requires every table in a published package to be covered by an in-package permission set; finding this at publish instead of at TDD time forces a batch-plan rewrite after code already exists (a real project hit exactly this and had to pull its permission sets forward from its last batch to its first).

**Outputs:** `TDD.md`; updated **Object Register** with every planned object and its ID.

**Exit gate:** Technical Lead sign-off. Self-sufficiency check passes: no rule requires knowledge outside the document (Standards §2.2 Stage 5).

## 04 — Sanity Check and Validation

**Role:** if §1.7 role assignment is configured, this review is done by the **reasoning role** —
same rationale as Step 10: fresh eyes catch what the author of the FRD/TDD is least likely to see
in their own work. The reasoning role reports findings; the main role resolves them and updates
the documents.

**Inputs:** `FRD.md`, `TDD.md`, BC symbol file.

**Actions:** Run a formal structured review — not a read-through — answering: **(A)** Can BC actually do everything the FRD asks? **(B)** Does the TDD fully and correctly implement the FRD? What will the object structure look like when built? Record each check, its finding, and any resolution in a document. Work the checklist (Standards §2.4):

- [ ] Every FRD entity maps to at least one TDD object.
- [ ] Every TDD object has a valid ID inside an allocated range (Parameter 1.2).
- [ ] Every source table number is verified against the symbol file (not estimated).
- [ ] Every field complies with the Localization parameter and Standards Part 5.
- [ ] Every obsolete / pending field is excluded.
- [ ] Every `using` namespace is sourced from the symbol file.
- [ ] All document-type-filtered pages use the correct `const()` quoting pattern.
- [ ] All entity names ≤ 30 characters; all field identifiers ≤ 30 characters.
- [ ] Read vs. read/write designations match the mutability rules in Standards §4.2.
- [ ] Growth buffers are planned within each module block (Standards §7.2).
- [ ] Permission sets are planned if enabled (Parameter 1.2) — **with every table's `tabledata` grant explicitly enumerated per set**, not just "permission sets exist," and each grant assigned to the same batch that introduces its table (Standards §7.3).
- [ ] Every entity's deletion behavior (block-if-referenced / cascade / allow) is explicitly decided and stated — not left to whatever the template defaults to. This includes fields on *other* tables (including standard BC tables extended via `tableextension`) that reference this entity by `TableRelation`: deciding a table's deletion behavior means re-checking every known referencing field, not just this app's own child tables.

**Outputs:** `SanityCheck.md` — every check, finding, resolution.

**Exit gate:** 0 blocking issues; every gap resolved; Technical Lead sign-off. Issues found here cost hours; the same issues found during BUILD cost days (Standards §2.2 Stage 6).

---

# PHASE: BUILD

Goal: generate AL batch by batch, lint clean — including symbol verification — as you go, without compiling per batch. The whole extension compiles exactly once, the moment every planned batch is written (Step 07) — fix root causes, not symptoms, when that surfaces anything.

## 05 — Plan the Code

**Inputs:** `TDD.md` (module grouping + batch plan), Object Register.

**Actions:**
- Confirm the object build order: which objects are built in which batch, smallest/simplest module first (Standards §10.3).
- Within a batch, order objects so lookup/reference tables precede the entities that reference them.
- Prepare the scaffold: `app.json` (name, publisher, runtime, BC dependency, `"features": ["NoImplicitWith"]`), `launch.json`, folder structure per module.
- Bootstrap the AL MCP Server and the BCQuality knowledge snapshot for this project if not
  already done (ALL ALONG) — both are one-time-per-project setup, cheapest to do alongside the
  rest of the scaffold rather than as an afterthought once BUILD is underway.
- Write the pre-flight validation checks to run for each batch — this is the canonical checklist every other reference to "the Step 05 checklist" in this runbook means; if you're re-stating it elsewhere, point here rather than re-enumerating. Split into two passes, since some checks are only possible before generation and some only after:
  - **Pre-generation** (on the TDD's planned names/fields, before any file exists — main role): identifier length ≤ 30, entity/EntitySet name length ≤ 30, reserved-keyword scan, localization field-range filter, `ObsoleteState` filter.
  - **Post-generation** (on the actual generated files — light role, if §1.7 role assignment is configured): required-property presence, `Rec.`-qualification (`NoImplicitWith`), dead-code check (no empty triggers, no `// TODO`, no commented-out fields), 4-space indentation with no tabs, permission-set `tabledata` coverage for every table the batch introduces (Standards §7.3 — a table missing this fails at publish, not at compile, so pre-flight is the only thing that catches it before the mandatory Step 07 compile does; vacuously satisfied if this project introduces no tables — see Parameter 1.2), and **symbol verification** — every reference to a standard/base BC table, page, codeunit, method, property, or enum value confirmed against the downloaded symbol source, falling back to the MS Learn BaseApp docs per Operating Rule 2 when the downloaded symbols don't answer, not assumed correct because it looks like plausible AL (Operating Rule 4).

**Outputs:** Batch plan (ordered), project scaffold, pre-flight validation script/checklist (both passes).

**Exit gate:** Batch order agreed with the human; scaffold is structurally complete (`app.json` fields populated, dependencies declared, folders created — not compiled, per Operating Rule 4); pre-flight checks ready.

## 06 — Code Generation

**Inputs:** `TDD.md`, Project Parameters, symbol file, batch plan, pre-flight checks.

**Actions — per batch, in order:**
1. Pause for human approval before writing the first file.
2. Extract source-table and field data for this batch's objects from the symbol file.
3. Run the Step 05 **pre-generation** pre-flight pass on the planned names/fields (main role — this is TDD housekeeping, distinct from the file-level lint in Action 5 below); fix the TDD before generating if anything fails.
4. Generate the batch's AL files from the standard template (Standards §3.3), substituting only Part 1 values. Every file: one `namespace`, one `using` (from symbol file), `ODataKeyFields = SystemId`, exactly one of `DelayedInsert = true` / `Editable = false`, and `Caption` + `ToolTip` + `ApplicationArea = All` on every field (Standards §3.1–§3.4, §4.1–§4.6). Captions and ToolTips written as self-describing schema for API consumers (Standards §4.5–§4.6). No dead code, no empty triggers, no commented-out fields, no `// TODO` (Standards §3.5).
5. **Run the Step 05 post-generation pre-flight pass on the batch immediately** — dot the i's, cross the t's on each file as you go: required-property presence, `Rec.`-qualification, dead code, indentation, permission-set coverage, and symbol verification, plus a manual read against the AZ AL Dev Tools rules (Appendix C — see the caveat on this citation under ALL ALONG → Retain Explanations). If §1.7 role assignment is configured, this pass is done by the **light role** — it reports findings only, it does not edit code; the main role applies every fix. **Do not invoke the AL compiler** (Operating Rule 4).
6. Do not proceed to the next batch until this one's pre-flight (including symbol verification) is clean. Do not compile per batch. Once every planned batch (including any gap-fill work) is generated, move to Step 07 — that step opens with the one mandatory compile (Operating Rule 4); it is not optional and not deferred further.
7. **Before moving past this step, verify permission-set coverage explicitly** — don't just trust that it was "planned." Check that every table built across every batch has a matching `tabledata` grant in both the read-only and read/write permission sets (Standards §7.3; vacuously satisfied if this project introduces no tables — see Parameter 1.2). This is a design-time check, independent of whether or when a compile happens: `PTE0004` (missing permission set) only fires at **publish**. A real project didn't catch this until publish and had to rewrite its batch plan as a result — catch it here instead.

**Outputs:** Generated AL files for every batch, each lint-clean including symbol verification; updated Object Register; ChangeLog entries for any deviation. The extension is **not** compiled as part of this step (Operating Rule 4) — that happens next, in Step 07.

**Exit gate:** Every planned object generated; each batch's pre-flight (including symbol verification) was clean before the next began; permission-set coverage verified for every table (Action 7). A clean compile is **not** required to close this gate — Step 06 hands off directly into Step 07's mandatory compile.

## 07 — Troubleshoot, Iterate

**Role:** if §1.7 role assignment is configured, root-cause diagnosis (the three questions below)
is done by the **reasoning role**; the main role applies the resulting fix and does the
ChangeLog/TDD bookkeeping. Same division for any bug surfaced later during PROVE-phase testing
(see Testing Feedback Log, ALL ALONG) — diagnosis is a reasoning-role task, fixing is the main
role's.

**Inputs:** Every batch from Step 06 (all lint-clean, none yet compiled); the symbol-verified lint findings accumulated across BUILD; `TDD.md`; ChangeLog.

**Actions:**
0. **Compile the whole extension once** (Operating Rule 4 — check for an already-provisioned runtime before installing anything, Operating Rule 6b). This is the mandatory compile the rest of BUILD deferred to this exact point; it is not optional and does not move further. If the human separately requested an earlier spot-check compile mid-BUILD, that was additional, not a substitute — this one still runs.

For every error or warning the compile surfaces, ask the three questions (Standards §9.3, §10 troubleshooting mindset):
1. **One-off or pattern?** Search all generated files for the same class of issue before fixing one instance.
2. **Where did it come from?** Trace to the generation rule, the TDD template, or the source data.
3. **What rule should have caught it?** Fix that rule or the pre-flight check.

Then: fix the **root cause** (rule / template / filter), regenerate the affected files, re-compile, and log the issue + resolution in the ChangeLog before moving on. Update the TDD whenever a rule changes. Pause for human approval of each root-cause diagnosis before applying it.

**Outputs:** All batches compiling with **0 errors, 0 warnings**; ChangeLog current; TDD updated for every rule change.

**Exit gate:** Full extension compiles clean; no known systemic issue outstanding; ChangeLog and TDD reconciled (Standards §9.4).

---

# PHASE: PROVE

Goal: prove the built code matches intent, is clean, is packaged and tested, and is fully documented.

## 08 — Gap-Fit Test, Fidelity Validation

**Role:** if §1.7 role assignment is configured, this three-way comparison is done by the
**reasoning role**; the main role applies the resulting classification (Intentional / Oversight /
Spec stale) to the actual documents.

**Inputs:** `FRD.md`, `TDD.md`, the built AL, ChangeLog.

**Actions:** Run a formal three-way comparison — FRD vs. TDD vs. as-built (Standards §11.4). Answer: does the written code follow the TDD and the FRD? What changed? Why? For each gap:
- Object in the FRD but not built — intentional or oversight?
- Object built but not in the FRD — scope creep or gap fill?
- Rule in the FRD the TDD did not implement — TDD gap.
- Rule implemented differently from the TDD — is there a ChangeLog entry?
- Implementation decision that contradicts the FRD — FRD update needed.

Classify every gap as **Intentional** (document the reasoning), **Oversight** (fix now or schedule), or **Spec stale** (code is right, update the FRD/TDD).

**Outputs:** `GapAnalysis.md` — every gap, its classification, its resolution. Gap-fill work items (built with the same discipline as main batches, using reserved growth IDs — Standards §11.6).

**Exit gate:** Every gap classified and resolved or scheduled; no unexplained divergence from FRD/TDD.

## 09 — Package and Test the App

**Inputs:** Clean-compiling extension; permission sets (if Parameter 1.2 = `Yes`).

**Actions:**
- Build the `.app` package, named `<ExtensionName, spaces → underscores>_<version>.app` — e.g.
  `IP_Tracking_1.0.0.0.app` — derived from `app.json` at build time, never hardcoded (see
  "Packaging & Versioning" under ALL ALONG for the full policy, and for when to offer packaging
  and when to bump the version — both apply throughout the project, not only here).
- Confirm `app.json` identity, runtime, and dependencies match Part 1.
- Publish to a BC sandbox tenant.
- Run green-team (happy path) tests: `$metadata` returns the expected schema; read a collection; read a single record by `SystemId`; create a record on an editable endpoint; update a field; confirm a read-only endpoint rejects writes (Standards §12.1).
- Run red-team (boundary) tests: write to a read-only endpoint; send a non-existent field; send an invalid key; delete a record with dependencies; call with missing permissions — confirm each fails *gracefully with a clean, actionable error* (Standards §12.1).
- Verify permission sets: read-only set grants read on all pages; read/write set includes it plus write on editable pages; document the underlying `D365` base permissions consumers also need (Standards §7.3).

**Outputs:** `.app` package; test-run record (green + red team results); deployment verification notes.

**Exit gate:** App publishes cleanly; all green-team tests pass; all red-team tests fail gracefully.

## 10 — Code Review

**Role:** if §1.7 role assignment is configured, this review is done by the **reasoning role** —
fresh eyes matter here specifically, since the agent that wrote the code is the one least likely
to notice its own batch-to-batch drift. The reasoning role reports findings; the main role applies
every fix and normalizes whatever drift the findings call out.

**Inputs:** The full built extension; `TDD.md`; Standards Parts 3, 4, 6, 9, 11.

**Actions:** Comprehensive review across all objects (Standards §11.5). Check for:
- **Code quality** — every object follows the standard template; structure, naming, and formatting identical across all batches (early and late batches often drift — normalize).
- **Dead code** — empty triggers, commented-out blocks, placeholder `// TODO` (Standards §3.5).
- **Redundant code** — duplicate field exposures, duplicate `using` directives, objects more complex than needed.
- **"Marked for obsoletion"** — any reference to a field, table, procedure, or event with `ObsoleteState = Pending` or `Removed`; any subscription to an obsolete event (Standards §5.2–§5.3). Exclusion is unconditional — no version check, no exception.
- **Standards compliance** — run the full Anti-Patterns table (Standards Part 11) against the codebase.
- **Best practices** — `Rec.` prefix everywhere (`NoImplicitWith`), required metadata present, correct `DelayedInsert` / `Editable` per data mutability, every table covered by both permission sets' `tabledata` grants (re-verify independently — don't just trust Step 06 Action 7).
- **BCQuality knowledge-backed review** (ALL ALONG) — invoke the local BCQuality snapshot's
  `skills/entry.md` dispatch flow against the built extension as an additional, independent pass
  alongside the Standards Anti-Patterns check above. Integrate its findings the same way as every
  other finding here: knowledge-backed findings and the agent's own findings both surface, fixes
  land through the normal ChangeLog/root-cause discipline, nothing is applied blind.

**Outputs:** `CodeReview.md` — findings by dimension, severity, and resolution. Fixes applied at the rule level where a pattern repeats, with ChangeLog entries.

**Exit gate:** All critical findings resolved; dead-code scan 100% clean across every file (Standards §11.2); no obsolete references remain.

## 11 — Update Design Documents

**Inputs:** `TDD.md`, `FRD.md`, ChangeLog, `GapAnalysis.md`, `CodeReview.md`.

**Actions:**
- Produce a new **as-built TDD version** (`PostDevTDD.md`) reflecting the architecture as actually implemented: final system identity, final object inventory with all properties, every naming convention and abbreviation as applied, all special cases and exceptions, and a deviation summary that references the ChangeLog (Standards §2.1, §11.3).
- Produce a new **FRD baseline** for future development: fold in every implementation decision that diverged from the original FRD — even where the implementation is better — so the next planning session starts from truth, not a stale spec (Standards §11.4 key lesson).

**Outputs:** `PostDevTDD.md` (as-built reference), updated `FRD.md` (new baseline). Original TDD retained as historical context; ChangeLog is the bridge between them.

> **Why the two documents are treated differently — there is deliberately no `PostDevFRD.md`.**
> The TDD gets a *new* file because the gap between "what we told it to build" and "what got
> built" is itself information worth keeping side by side; the original TDD is also the artifact
> the code was generated from, so it stays as evidence. Requirements are not like that: there is
> exactly one current answer to "what should this app do," and a second, stale copy of it is
> actively misleading to the next planner — which is the whole point of re-baselining. So the FRD
> is updated **in place**, not duplicated.
>
> **Because the FRD is updated in place, add a pointer to its pre-BUILD version** in the FRD's
> own header — the commit hash that holds it, plus how to list its revisions. Otherwise the
> original TDD sits in `docs/` where anyone finds it while the original FRD is only reachable by
> someone who already knows to go looking, which is the one thing this asymmetry genuinely costs.

**Exit gate:** As-built TDD is complete enough to regenerate the system from; FRD reflects reality; Dev Manager review.

## 12 — Document the Code

**Inputs:** `PostDevTDD.md`, the built AL, test-run record from Step 09.

**Actions:**
- **Generate the reference documentation from the code, not from memory** (Standards §12.2). Parse every API page: extract IDs, source tables, editability, filters, and every field's identifier / source name / description / R/W status. Produce a structured reference — one section per object, one row per field — plus: a **quick-start** guide (get the API working fast — auth, one request, one response; not the full install procedure, see `Deployment.md` below for that), authentication and URL patterns (Standards Appendix A), `$filter` / `$select` examples, create/update/delete examples, explicit limitations, common integration patterns, troubleshooting table.
- **Draw the schema as a Mermaid diagram**, generated from the actual objects, not from memory. Include every table this app owns *and* every standard/base table it touches — via `TableRelation`, `tableextension`, or a `pageextension`'s `RunPageLink` — so a reader sees the whole relationship graph, not just the app's own corner of it. An ER diagram (`erDiagram`) is the usual fit; note cardinality and which side is the standard object.
- **Render the diagram to prove it parses — never ship one you have not seen render.** Markdown happily stores a syntactically invalid diagram: it looks fine in the source file and simply fails to draw wherever it is finally viewed, so the defect is invisible until a reader hits it. Extract the fenced block and run it through a renderer (e.g. `npx @mermaid-js/mermaid-cli -i diagram.mmd -o diagram.svg`, or whatever renderer is already available — this may download a package on first run, so Operating Rule 6b applies: confirm one is already usable, or ask, rather than installing anything unprompted); a parse error exits non-zero and names the line. On a real project a diagram shipped with `PK_FK` as a key constraint — not valid Mermaid, which accepts `PK`, `FK`, `UK`, or comma-separated `PK,FK` — and never rendered anywhere until it was actually tested.
- **Write the human unit test script** — a step-by-step manual test walkthrough a person can execute: endpoint by endpoint, the happy-path and boundary cases from Step 09, expected result for each. A well-written test script is ~70% of a user guide (Standards §12.1).
- Write the **user guide** as `UserGuide.md` — **Markdown, in the repo, always** (HTML with `@media print` rules only as an *additional* branded/print deliverable, never instead of the Markdown; Standards §12.5). This is a **separate document from `Documentation.md`** and must not be folded into it: `Documentation.md` is the integration/API reference written for a developer or BI consumer, whereas the user guide is written for the person clicking around in Business Central — what the feature is for, how to do each task in order, what each field means in business terms, and what to do when something is refused. If the only "user guide" produced is an API reference, this action has not been done.
- Write one-page **deployment instructions** as `Deployment.md`, for an administrator: version requirements, install procedure, which permission sets map to which roles, verification steps, uninstall (Standards §12.3). Distinct from `Documentation.md`'s quick-start: this is the full admin install/upgrade/uninstall procedure, not a fast path to a first API call.

**Outputs:** `Documentation.md` (consumer/API reference, includes the Mermaid schema diagram), `HumanUnitTestScript.md`, **`UserGuide.md`** (end-user, Markdown), `Deployment.md`. Four documents — check all four exist before claiming the step is complete.

**Exit gate:** Reference is generated from actual code and current; test script executable by a non-developer; Dev Manager review; app ready for user acceptance testing.

---

# ALL ALONG — Continuous Discipline (every phase, every step)

Run these in parallel with the phased work — they are not a final step.

## Document

- Keep every required project document current as work proceeds, not retroactively (Standards §2.1): `ProblemStatement`, `FRD`, `TDD`, `SanityCheck`, `PostDevTDD`, `ChangeLog`, `GapAnalysis` / `CodeReview`, `Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`, `TestingFeedback`, `Roadmap`, `ProjectMemory` — all four Step 12 outputs (`Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`) belong on this list, not just the first of them.
- Maintain the **Object Register** as a standalone artifact — every object, its ID, module, source table, and R/W status — updated as objects are planned and built (Standards §1.2).

## Track Changes — the ChangeLog

Every deviation from FRD or TDD — human or agent — is logged **before the next batch begins** (Standards §10.4). It is the ground truth for what was actually built and why. Entry format (Standards §10.4):

```
## Issue <BatchID>-<SeqNo> — <Short Description>
**Problem:** What was wrong or missing.
**Root cause:** Why it happened.
**Resolution:** What was changed.
**Files affected:** List of changed files or template rules.
**Updated:** TDD, FRD, or both — yes/no.
```

**Name the person, not a role.** When a decision, a "hold off," or a preference is attributed to a human, write their actual name ("AJ decided X") — never a generic placeholder like "the human" or "the user." A role-noun silently assumes exactly one person exists on the project; the moment there's a second contributor, "the human decided X" stops answering the only question that phrase exists to answer — decided by *whom*. This applies throughout the TDD, FRD, and ChangeLog, not just here.

## Retain Explanations

- When the agent flags something (an obsolete field, an ambiguous name, a scope question), record the flag, **who** decided and what they decided, and the reasoning — not just the outcome.
- Every root-cause fix records the diagnosis, not only the patch, so the same class of error cannot recur in a later batch.
- Commit each batch to version control separately, before the next begins, with a message that references its ChangeLog entries (Standards Appendix C — **unverified against the companion doc, which isn't in this repo; Step 06's pre-flight action also cites "Appendix C" for the AZ AL Dev Tools linter rules, a different subject — confirm both against the actual Standards doc rather than assuming they're the same appendix**).

## Testing Feedback Log

Human testing and review surfaces real feedback throughout PROVE (and sometimes earlier, on a
demo) — a list of things to change, in the tester's own words, not yet triaged into decisions.
This is distinct from both of the above: the ChangeLog records *decisions and reasoning*; the
Step 09 test-run record captures *automated* green-team/red-team pass/fail. Neither preserves
what the human actually said before it becomes a summary of what the human said.

- Record every testing/feedback session in `TestingFeedback.md` — date, what was tested, and the
  tester's findings/requests **verbatim**, before they are triaged.
- Triage each item explicitly: implement now (its own ChangeLog Issue), schedule for later
  (`Roadmap.md`), or reject (record why, in the same log).
- Cross-reference in both directions: the `TestingFeedback.md` entry links to the ChangeLog
  Issue(s) or Roadmap item(s) it produced, so the raw ask and the eventual decision both remain
  traceable independently.
- **Role (§1.7):** diagnosing *why* a reported bug happens is a **reasoning-role** task, same as
  Step 07. The **main role** applies the fix once the diagnosis is confirmed, and separately owns
  the triage act itself — recording the implement/schedule/reject decision in `TestingFeedback.md`
  and cross-referencing the ChangeLog/Roadmap entry it produced. Don't skip straight to a patch on
  a guess — this is exactly where a wrong first diagnosis is cheapest to catch, and a wrong one
  should stay in the log marked superseded, not be quietly deleted, the same as any other
  ChangeLog correction.

## Project Memory — `docs/ProjectMemory.md` (required, in-repo)

Continuity must not depend on which agent, machine, or tool picks the project up next.
`docs/ProjectMemory.md` is a required project artifact, committed to version control like every
other document here — **not** an agent's own external/cross-session memory feature, which is
tied to one machine's file path and invisible to git, to a teammate, and to any other tool or
agent that opens this repo.

- **Keep it short — an anchor, not a narrative.** Current phase/step, where each live document
  lives, any decision awaiting sign-off, and a one-line pointer per past milestone. The full
  story of *why* a decision was made belongs in `ChangeLog.md`; `ProjectMemory.md` just says
  *where to look*. If it starts reading like a second ChangeLog, trim it.
- **Every row in "Open decisions" names who it's awaiting** — `(awaiting: <name>)`. This is not
  redundant with `git blame`: blame tells you who last edited the line, not who the project is
  actually waiting on for a forward-looking decision. With a single contributor every row will
  say the same name — write it anyway, so the convention is already in place the day a second
  person joins.
- Update it at the close of every step or batch — the same moment the ChangeLog gets its entry.
- If the executing agent *also* has its own persistent cross-session memory capability, that
  memory may point at `docs/ProjectMemory.md` (e.g. "always read this file first") but must not
  duplicate its content. A fact that lives only in an agent's private memory and nowhere in
  `docs/ProjectMemory.md` or the other project documents does not count as recorded — the file
  in the repo is the one a different agent, a teammate, or a fresh clone can actually read.

## Packaging & Versioning

Packaging (Step 09's "build the `.app`") and version bumps recur throughout BUILD and PROVE —
every batch or testing-feedback round that lands clean is a candidate moment, not just the one
narrative pass through Step 09.

**Package naming — fixed, not a judgment call.** Every package is named
`<ExtensionName, spaces → underscores>_<version>.app` — read `name` and `version` from `app.json`
at build time, never hardcoded in the build script or typed by hand. Example: extension name
`IP Tracking`, version `1.0.0.0` → `IP_Tracking_1.0.0.0.app`.

**Never delete a previous package. NEVER.** Every repackage writes a new, uniquely-named file
next to the old ones — it does not replace, overwrite, or "clean up" anything already in the
output folder, even one that looks superseded by a newer version. This applies to the build
script itself and to the agent running it: no `rm`, no "let me tidy this up first," not even as
a seemingly-harmless pre-build habit. On a real project this was violated exactly that way — a
manual `rm -f out/*.app` run *before* the build, purely out of habit, deleted the previous
version's package. It was recovered only because the output folder isn't git-tracked but the
*source* is: the exact prior commit was checked out, rebuilt, and the file regenerated —
functionally identical, not a true undelete. That recovery path will not always exist. Pruning
old packages, if it ever happens, is a decision the human makes explicitly, never an automatic
or "helpful" action by the agent.

**Offer to (re-)package — use judgment on *when*, not *whether* to ask.** When a meaningful,
testable unit of change is done — a batch reaching lint-clean, the mandatory Step 07 compile
succeeding, or a testing-feedback fix verified — ask whether to rebuild the package now. The
right granularity is the same one that already governs a ChangeLog entry and its own commit — if
the change was significant enough for those, it's significant enough to offer a fresh package
for. Don't ask after every trivial or doc-only edit; don't silently skip asking after a real
batch either.

**Version bumps require a proposal and approval — never a silent edit to `app.json`.** Propose
a specific bump with reasoning, then wait for confirmation before changing anything:
- **Major** — a breaking or structural change (e.g. renaming the whole extension, removing
  something a consumer could already be relying on). Rare, especially pre-release.
- **Minor** — new features, fields, or objects added in a backward-compatible way. This is the
  common case for a testing-feedback batch.
- **Build** — a repackage of the same feature set with no new functionality — a re-verification
  build, an environment change, or simply "package this again as-is."
- **Revision** — a small correction or hotfix discovered while testing a specific package, with
  no new features.

**Push back on a premature ask — don't just comply.** If asked to package while known errors or
an unfinished batch stand, or asked for a version bump that doesn't match the size of what
actually changed (a one-field tweak billed as Major; a breaking change billed as a Revision),
say so plainly and recommend the right action instead of silently doing what was literally
asked. If the human insists anyway, get an explicit override and proceed — but the mismatch must
be named first, not absorbed silently.

## AL MCP Server

The AL Language extension ships a standalone MCP server (`altool launchmcpserver`) exposing AL
build/publish/symbol/diagnostic tools over the Model Context Protocol, so any MCP-capable agent —
not only VS Code — can drive them directly instead of shelling out to the compiler by hand. It is
not a background service: nothing runs until an MCP host spawns it, and it exits when the host
tears it down.

**Bootstrap once per new project** (idempotent — check for an existing registration before
adding a duplicate):
1. Locate `altool` inside the installed AL extension (its `bin/` folder) — it is not necessarily
   on `PATH`. **On Windows**, `altool.exe` is a native binary — invoke it directly, no wrapper
   needed. **On macOS or Linux**, the shipped `.exe` is Windows-only and won't run; invoke
   `altool.dll` against a .NET runtime instead (prefer one already on `PATH`; otherwise check
   whatever the IDE already privately provisions for its own AL tooling before installing
   anything — Operating Rule 6b — noting that path itself differs by OS, e.g. VS Code's own
   per-extension runtime storage lives under a different directory on macOS than on Linux).
2. Confirm the project has a valid `app.json` and, if any MCP tool will publish or download
   symbols from a live server, a `launch.json` with the target environment configured.
3. Register the server with whatever MCP host the agent's harness provides, preferring
   project-scoped config so it travels with the repository. Generic stdio descriptor (adapt keys
   to the host's config format):
   ```json
   { "type": "stdio", "command": "<path to a runtime>", "args": ["<path to altool.dll>", "launchmcpserver", "--transport", "stdio"] }
   ```
   The command also accepts one or more AL project paths as positional arguments, and flags for
   package cache path, ruleset, code analyzers, and output folder — check `altool launchmcpserver
   --help` against the installed version rather than assuming a fixed flag set, since this
   surface can grow between AL extension releases.
4. Verify the connection by listing available tools — a lightweight capability check, not a
   project compile. Compiling the actual extension is not automatic anywhere in BUILD (Operating
   Rule 4); do not use this verification step as a backdoor to it.
5. Tools reaching a live BC cloud environment (publish, downloading non-global symbols) trigger
   an interactive sign-in the first time they're needed, cached for the session; log out when the
   task reaching the cloud is done.

**Standing use during development:** once registered, prefer the MCP build/publish/symbol tools
over an ad hoc terminal compiler invocation where the harness makes both available — they're the
first-party path and are kept current with the extension, where a hand-rolled wrapper script
isn't. Re-verify the tool surface (names, arguments) against the installed version rather than
trusting a prior project's notes about it, since this is actively developed and can change
between AL extension releases.

## BCQuality Knowledge Snapshot

BCQuality (`microsoft/BCQuality` on GitHub) is a curated knowledge base and skill library for BC
AL code quality — not an MCP server, not a running endpoint, just markdown knowledge files (the
non-obvious platform rules: CodeCop specifics, security/performance/privacy footguns, etc.) plus
skills that define how an agent should search and apply that knowledge during review. It
augments review judgment; it does not replace it — an agent's own findings are still valid and
should still be surfaced even without a knowledge-file citation.

**Snapshot strategy — one-time per project, refreshed only on request:**
- Do **not** install it as a plugin, even where the host supports one, and do not keep one
  long-lived copy shared unrefreshed across many unrelated projects — that's how it goes stale
  for all of them at once.
- Do fetch a full, current snapshot from the repo's default branch exactly once, at Step 05
  (alongside the rest of the project scaffold — see Step 05's own bootstrap bullet), into a
  project-local folder (e.g. `.bcquality/`) — mirroring the repo's own layout
  (`skills/`, `microsoft/`, `community/`, `custom/`, `docs/`), via a shallow clone
  (`git clone --depth 1`) rather than fetching hundreds of files individually. **Tell the human
  you're doing this** — it's not a silent background check. Strip `.git` from the snapshot
  (it's a content copy, not a live checkout) and write a small `SNAPSHOT.json` alongside it
  recording the commit SHA and fetch timestamp, so a refresh later has something to diff against
  and report.
- Whether `.bcquality/` is committed to the project repo or kept as a local, gitignored cache is
  a project convention call — for a project that already tracks other vendored/fetched
  dependencies for reproducibility (e.g. downloaded symbol packages), track this the same way.
- Refresh **only** when the human explicitly asks (e.g. "refresh BCQuality," "get the latest").
  Re-run the fetch in full, overwrite the existing snapshot, and report plainly: "updated from
  `<old sha>` to `<new sha>`" or "already up to date." The repo is under active development with
  breaking changes possible at any time — that's expected, and exactly why refreshes are
  human-triggered rather than silent.

**Using the snapshot — this is a documented protocol, not something to improvise (verify against
the snapshot's own `docs/agent-consumption.md` before relying on a paraphrase, including this
one, since the repo's own conventions are the authority and can move):**
1. Read `skills/entry.md` from the local snapshot and follow it with an explicit task-context
   (goal, inputs available, technologies, BC version, enabled layers) — resolving BCQuality's own
   instructions/knowledge against the snapshot root, and the actual review target against the
   project's own files. Entry returns a **dispatch record** naming which action skill(s) to run;
   if it returns `no-match` or `failed`, return that record as-is rather than inventing a review.
2. Read the meta-skill contracts (`skills/read.md`, `skills/do.md`, and `skills/write.md` only if
   authoring new knowledge) on demand, not upfront.
3. Invoke each dispatched action skill from the snapshot's layers (`microsoft/skills/`,
   `community/skills/`); for a full code review this is typically the super-skill at
   `microsoft/skills/review/al-code-review.md`, which composes per-domain leaf skills
   (security, performance, privacy, style, etc.) under the same folder.
4. Each action skill runs the same four-step pattern (Source → Relevance → Worklist → Action),
   filtering knowledge files by frontmatter (`bc-version`, `domain`, `technologies`, `countries`,
   `application-area`) across every enabled layer, higher-precedence layers suppressing lower per
   `read.md`. A prebuilt `knowledge-index.json` accelerates discovery when present; when absent
   (the normal state for a static snapshot with no indexer run against it), skills fall back to
   plain path-based discovery by domain folder — review still works either way.
5. Findings come back in the shape `do.md` defines: outcome (`completed` / `not-applicable` /
   `no-knowledge` / `partial` / `failed`), findings with a human-readable `domain` label, structured
   `references` (knowledge-file path, optional commit SHA) for knowledge-backed findings, an empty
   `references: []` for the agent's own findings (capped at `medium` confidence), and a
   `suppressed` list of anything layer precedence overrode. Integrate this into the project the
   same way any other Code Review finding is integrated (Step 10) — never applied blind.

No network access is needed for any of the above once the snapshot exists; only the initial fetch
and an explicit refresh touch the network.

---

## Stage ↔ Step Map

| Standards §2.2 Stage | This runbook step |
|---|---|
| 1 — Problem Space | PRE-01 |
| 2 — Gap Analysis | PRE-02 |
| 3 — Architecture | 01 (parameters) + 03 (module grouping, ID allocation, phase plan) |
| 4 — FRD | 02 |
| 5 — TDD | 03 |
| 6 — SanityCheck | 04 |
| 7 — Implementation | 05 + 06 + 07 |
| 8 — Code Review | 08 + 10 |
| 9 — Documentation | 11 + 12 |
| 10 — Deployment | 09 (sandbox) → post-routine production deploy per `Deployment.md` |

---

*Routine created by AJ Ansari, Microsoft MVP, OnlyCopilotFans. Update this runbook when the framework or the standards change.*


# BC App Build Routine — Agent Runbook

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

> **What this is:** A single, ordered routine an AI agent follows to build a new Business Central AL Per-Tenant Extension (PTE) from a business problem through to a tested, documented, deployable app.
>
> **How the agent uses it:** Work the phases in order (DEFINE → DESIGN → BUILD → PROVE). Do not start a step until its predecessor's exit gate is met. Every step lists its **Inputs**, **Actions**, **Outputs**, and **Exit gate**. The *Project Parameters* block in Step 01 is the single source of truth for every name, ID, version, and quoting decision — never hardcode any of those values in AL; always derive them from that block.
>
> **Companion document:** `AL_PTE_Development_Standards_UNIFIED.md`. This runbook drives the *sequence*; that guide holds the detailed *rules* (Parts 2–11, Appendices A–C). References below point to it as **Standards §**.
>
> **Prime directive for the agent:** An ambiguous input produces ambiguous code. If a step's inputs are incomplete or contradictory, stop and ask the human — do not invent rules to fill the gap.

---

## Operating Rules (apply in every phase)

1. **Part 1 is authoritative.** Publisher, prefix, namespace, versions, ID ranges, localization — read them from the Project Parameters block (Step 01) and derive everything else. Never hardcode.
2. **Verify against BC symbol files, not memory.** Table numbers, `using` namespaces, field IDs, `ObsoleteState` — confirm each in the symbol file named in Parameter 1.4. Agent knowledge of BC table numbers is not reliable (Standards §10.5, Appendix B). **Fallback when the downloaded symbols don't answer the question** (a module isn't in `.alpackages`, or you need to browse/discover rather than already knowing what to grep for): the entire BC BaseApp, for the current Business Central Online version, is documented at <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application> — every standard table, field, and field datatype/size. Use it to corroborate or discover; the downloaded symbol file for the target version is still the authoritative source when the two ever disagree.
3. **Phase large scope into batches.** A batch is a self-contained, compilable, reviewable increment (by module or document-type group). Define batch boundaries during DESIGN and record them in the TDD (Standards §2 intro, §10.3).
4. **Compile after every batch — never generate all batches first.** Treat one compiler error as a systemic signal: fix the rule/template, then every file it touched (Standards §9.3, §10.3).
5. **Zero errors, zero warnings before PROVE.** Treat warnings as errors during development (Standards §9.4).
6. **Human-in-the-loop is a feature.** Pause for human approval before: writing the first file of a batch, applying a root-cause fix, starting a new batch, and finalizing any design document.
6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human to *decide something* — pick between design options, approve a version bump, choose a name, resolve an ambiguity — present it through the interactive multiple-choice mechanism the agent's harness provides (in Claude Code, the `AskUserQuestion` tool), with the recommended option first and a short reason on each. A decision buried in a paragraph of chat is easy to miss: it reads like the agent finished and is idling, so the project silently stalls waiting on an answer nobody realised was owed.
    **Use it only for decisions.** Do *not* wrap ordinary progress in it — finishing a step and waiting to be told to start the next one, reporting a clean compile, or handing back a result is normal conversation, not a decision point. Over-using the box makes it noise, which defeats the purpose.
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
| **Permission Sets required?** | `Yes` / `No` | If `Yes`, reserve ≥ 2 IDs inside the primary range and deliver per Standards §7.3. |

> **Rule:** Never use object IDs outside the allocated ranges. Maintain the object register as a separate project artifact. If `Permission Sets required = Yes`, plan them before code generation.

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

**Outputs:** The completed Project Parameters block (above, all placeholders replaced); an empty **Object Register** artifact seeded with the allocated ID ranges.

**Exit gate:** No placeholder remains. Deployment Target is one allowed value. Namespace matches between 1.1 and 1.3, or both are correctly N/A if Use Namespace = `No`. Localization is set. If Permission Sets required = `Yes`, ≥ 2 IDs are reserved in the primary range. Human confirms the sheet.

---

# PHASE: DESIGN

Goal: a complete FRD and a self-sufficient TDD, both validated for BC feasibility and internal consistency, before any code.

## 02 — Craft the Functional Requirements Document (FRD)

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
- **Permission sets** — if Parameter 1.2 = `Yes`: a read-only set and a read/write set (including the read-only set), both with IDs from the allocated range and names from the Permission Set Prefix (Standards §7.3).

**Outputs:** `TDD.md`; updated **Object Register** with every planned object and its ID.

**Exit gate:** Technical Lead sign-off. Self-sufficiency check passes: no rule requires knowledge outside the document (Standards §2.2 Stage 5).

## 04 — Sanity Check and Validation

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
- [ ] Permission sets are planned if enabled (Parameter 1.2).
- [ ] Every entity's deletion behavior (block-if-referenced / cascade / allow) is explicitly decided and stated — not left to whatever the template defaults to. This includes fields on *other* tables (including standard BC tables extended via `tableextension`) that reference this entity by `TableRelation`: deciding a table's deletion behavior means re-checking every known referencing field, not just this app's own child tables.

**Outputs:** `SanityCheck.md` — every check, finding, resolution.

**Exit gate:** 0 blocking issues; every gap resolved; Technical Lead sign-off. Issues found here cost hours; the same issues found during BUILD cost days (Standards §2.2 Stage 6).

---

# PHASE: BUILD

Goal: generate AL that compiles clean, one batch at a time, fixing root causes not symptoms.

## 05 — Plan the Code

**Inputs:** `TDD.md` (module grouping + batch plan), Object Register.

**Actions:**
- Confirm the object build order: which objects are built in which batch, smallest/simplest module first (Standards §10.3).
- Within a batch, order objects so lookup/reference tables precede the entities that reference them.
- Prepare the scaffold: `app.json` (name, publisher, runtime, BC dependency, `"features": ["NoImplicitWith"]`), `launch.json`, folder structure per module.
- Write the pre-flight validation checks to run before each batch is delivered: identifier length ≤ 30, entity name length ≤ 30, reserved-keyword scan, localization field-range filter, `ObsoleteState` filter, required-property presence.

**Outputs:** Batch plan (ordered), project scaffold, pre-flight validation script/checklist.

**Exit gate:** Batch order agreed with the human; scaffold compiles empty; pre-flight checks ready.

## 06 — Code Generation

**Inputs:** `TDD.md`, Project Parameters, symbol file, batch plan, pre-flight checks.

**Actions — per batch, in order:**
1. Pause for human approval before writing the first file.
2. Extract source-table and field data for this batch's objects from the symbol file.
3. Run pre-flight validation on the planned names/fields; fix the TDD before generating if anything fails.
4. Generate the batch's AL files from the standard template (Standards §3.3), substituting only Part 1 values. Every file: one `namespace`, one `using` (from symbol file), `ODataKeyFields = SystemId`, exactly one of `DelayedInsert = true` / `Editable = false`, and `Caption` + `ToolTip` + `ApplicationArea = All` on every field (Standards §3.1–§3.4, §4.1–§4.6). Captions and ToolTips written as self-describing schema for API consumers (Standards §4.5–§4.6). No dead code, no empty triggers, no commented-out fields, no `// TODO` (Standards §3.5).
5. **Lint and compile the batch immediately** — dot the i's, cross the t's on each file as you go. Run the pre-compilation checklist (Standards §9.1) and the AZ AL Dev Tools linter (Appendix C). Indentation: 4 spaces per level, no tabs (Standards §9.2).
6. Do not proceed to the next batch until this one compiles with 0 errors / 0 warnings and pre-flight is clean.

**Outputs:** Compiled AL files for each batch; updated Object Register; ChangeLog entries for any deviation.

**Exit gate:** Every planned object generated; each batch compiled clean before the next began.

## 07 — Troubleshoot, Iterate

**Inputs:** Compiler/linter output per batch; `TDD.md`; ChangeLog.

**Actions:** For every error or warning, ask the three questions (Standards §9.3, §10 troubleshooting mindset):
1. **One-off or pattern?** Search all generated files for the same class of issue before fixing one instance.
2. **Where did it come from?** Trace to the generation rule, the TDD template, or the source data.
3. **What rule should have caught it?** Fix that rule or the pre-flight check.

Then: fix the **root cause** (rule / template / filter), regenerate the affected files, re-compile, and log the issue + resolution in the ChangeLog before the next batch. Update the TDD whenever a rule changes. Pause for human approval of each root-cause diagnosis before applying it.

**Outputs:** All batches compiling with **0 errors, 0 warnings**; ChangeLog current; TDD updated for every rule change.

**Exit gate:** Full extension compiles clean; no known systemic issue outstanding; ChangeLog and TDD reconciled (Standards §9.4).

---

# PHASE: PROVE

Goal: prove the built code matches intent, is clean, is packaged and tested, and is fully documented.

## 08 — Gap-Fit Test, Fidelity Validation

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

**Inputs:** The full built extension; `TDD.md`; Standards Parts 3, 4, 6, 9, 11.

**Actions:** Comprehensive review across all objects (Standards §11.5). Check for:
- **Code quality** — every object follows the standard template; structure, naming, and formatting identical across all batches (early and late batches often drift — normalize).
- **Dead code** — empty triggers, commented-out blocks, placeholder `// TODO` (Standards §3.5).
- **Redundant code** — duplicate field exposures, duplicate `using` directives, objects more complex than needed.
- **"Marked for obsoletion"** — any reference to a field, table, procedure, or event with `ObsoleteState = Pending` or `Removed`; any subscription to an obsolete event (Standards §5.2–§5.3). Exclusion is unconditional — no version check, no exception.
- **Standards compliance** — run the full Anti-Patterns table (Standards Part 11) against the codebase.
- **Best practices** — `Rec.` prefix everywhere (`NoImplicitWith`), required metadata present, correct `DelayedInsert` / `Editable` per data mutability.

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
- **Generate the reference documentation from the code, not from memory** (Standards §12.2). Parse every API page: extract IDs, source tables, editability, filters, and every field's identifier / source name / description / R/W status. Produce a structured reference — one section per object, one row per field — plus: quick-start deployment guide, authentication and URL patterns (Standards Appendix A), `$filter` / `$select` examples, create/update/delete examples, explicit limitations, common integration patterns, troubleshooting table.
- **Draw the schema as a Mermaid diagram**, generated from the actual objects, not from memory. Include every table this app owns *and* every standard/base table it touches — via `TableRelation`, `tableextension`, or a `pageextension`'s `RunPageLink` — so a reader sees the whole relationship graph, not just the app's own corner of it. An ER diagram (`erDiagram`) is the usual fit; note cardinality and which side is the standard object.
- **Render the diagram to prove it parses — never ship one you have not seen render.** Markdown happily stores a syntactically invalid diagram: it looks fine in the source file and simply fails to draw wherever it is finally viewed, so the defect is invisible until a reader hits it. Extract the fenced block and run it through a renderer (`npx @mermaid-js/mermaid-cli -i diagram.mmd -o diagram.svg`); a parse error exits non-zero and names the line. On a real project a diagram shipped with `PK_FK` as a key constraint — not valid Mermaid, which accepts `PK`, `FK`, `UK`, or comma-separated `PK,FK` — and never rendered anywhere until it was actually tested.
- **Write the human unit test script** — a step-by-step manual test walkthrough a person can execute: endpoint by endpoint, the happy-path and boundary cases from Step 09, expected result for each. A well-written test script is ~70% of a user guide (Standards §12.1).
- Write the **user guide** as `UserGuide.md` — **Markdown, in the repo, always** (HTML with `@media print` rules only as an *additional* branded/print deliverable, never instead of the Markdown; Standards §12.5). This is a **separate document from `Documentation.md`** and must not be folded into it: `Documentation.md` is the integration/API reference written for a developer or BI consumer, whereas the user guide is written for the person clicking around in Business Central — what the feature is for, how to do each task in order, what each field means in business terms, and what to do when something is refused. If the only "user guide" produced is an API reference, this action has not been done.
- Write one-page **deployment instructions** for an administrator: version requirements, install procedure, which permission sets map to which roles, verification steps, uninstall (Standards §12.3).

**Outputs:** `Documentation.md` (consumer/API reference, includes the Mermaid schema diagram), `HumanUnitTestScript.md`, **`UserGuide.md`** (end-user, Markdown), `Deployment.md`. Four documents — check all four exist before claiming the step is complete.

**Exit gate:** Reference is generated from actual code and current; test script executable by a non-developer; Dev Manager review; app ready for user acceptance testing.

---

# ALL ALONG — Continuous Discipline (every phase, every step)

Run these in parallel with the phased work — they are not a final step.

## Document

- Keep every required project document current as work proceeds, not retroactively (Standards §2.1): `ProblemStatement`, `FRD`, `TDD`, `SanityCheck`, `PostDevTDD`, `ChangeLog`, `GapAnalysis` / `CodeReview`, `Documentation`, `TestingFeedback`, `Roadmap`, `ProjectMemory`.
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
- Commit each batch to version control separately, before the next begins, with a message that references its ChangeLog entries (Standards Appendix C).

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

**Offer to (re-)package — use judgment on *when*, not *whether* to ask.** When a batch, a
testing-feedback round, or a defect fix finishes compiling to 0 errors / 0 warnings and
represents a meaningful, testable unit of change, ask whether to rebuild the package now. The
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


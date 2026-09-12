# Agentic Development Framework — Schematics

Visual companion to the runbook (see `CLAUDE.md` for the authoritative text, `RunbookChangelog.md`
for its version history). These diagrams are a reading aid, not a source of truth — if a diagram
and the runbook text ever disagree, the runbook wins and this file is stale and needs updating.

Every diagram below was extracted and rendered through `@mermaid-js/mermaid-cli` before being
committed here, per the same discipline the runbook itself requires at Step 12 ("never ship a
diagram you have not seen render"). Markdown can store a syntactically invalid Mermaid diagram
that looks fine in the source and simply fails to draw wherever it's viewed — that check is what
catches it before a reader does.

**Shape legend, used consistently across every diagram below:**

| Shape | Meaning |
|---|---|
| `(( stadium ))` | Start / end point of a flow |
| `[ rectangle ]` | An action, step, or process |
| `[/ parallelogram /]` | Input or output (data, a document) |
| `{{ hexagon }}` | An exit gate / checkpoint |
| `{ diamond }` | A decision point |
| `[[ subroutine ]]` / dashed box | A cross-cutting concern (ALL ALONG) |

**Color legend** (role diagrams and BUILD only): blue = Main role, green = Light role,
purple = Reasoning role. Where §1.7 role assignment isn't configured, every colored step is done
by the single running model instead.

---

## 1. High-Level Overview

The whole framework in one picture: four phases in sequence, with ALL ALONG's continuous
discipline running underneath every one of them.

```mermaid
flowchart LR
    Problem(["Business Problem"]) --> DEFINE["DEFINE<br/>Scope the problem,<br/>fill in parameters"]
    DEFINE --> DESIGN["DESIGN<br/>FRD + self-sufficient TDD"]
    DESIGN --> BUILD["BUILD<br/>Generate AL, lint,<br/>one mandatory compile"]
    BUILD --> PROVE["PROVE<br/>Test, review, document,<br/>package"]
    PROVE --> Deployed(["Deployed, Documented App"])

    AllAlong[["ALL ALONG<br/>Continuous Discipline"]]
    AllAlong -.-> DEFINE
    AllAlong -.-> DESIGN
    AllAlong -.-> BUILD
    AllAlong -.-> PROVE

    classDef phase fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    classDef allalong fill:#fdf0d5,stroke:#c99a3a,stroke-width:1px;
    class DEFINE,DESIGN,BUILD,PROVE phase;
    class Problem,Deployed endpoint;
    class AllAlong allalong;
```

---

## 2. Deeper Level — Full Step & Gate Flow

Every step across all four phases, in order, with the exit gate that must be met before the next
one can start (the runbook's own rule: "do not start a step until its predecessor's exit gate is
met").

```mermaid
flowchart TD
    subgraph DEFINE["PHASE: DEFINE"]
        direction TB
        PRE01["PRE-01<br/>State the Problem"] --> G_PRE01{{"Functional Consultant<br/>signs off"}}
        G_PRE01 --> PRE02["PRE-02<br/>Structured Gap Analysis"]
        PRE02 --> G_PRE02{{"Technical Lead reviews,<br/>gaps closed/deferred"}}
        G_PRE02 --> S01["01 — Populate Intake Sheet<br/>(Project Parameters, incl. §1.6/§1.7)"]
        S01 --> G_S01{{"No placeholders,<br/>human confirms sheet"}}
    end

    subgraph DESIGN["PHASE: DESIGN"]
        direction TB
        S02["02 — Craft FRD"] --> G_S02{{"Dev Manager sign-off"}}
        G_S02 --> S03["03 — Craft TDD"]
        S03 --> G_S03{{"Technical Lead sign-off,<br/>self-sufficiency check"}}
        G_S03 --> S04["04 — Sanity Check"]
        S04 --> G_S04{{"0 blocking issues"}}
    end

    subgraph BUILD["PHASE: BUILD"]
        direction TB
        S05["05 — Plan the Code"] --> G_S05{{"Batch order agreed,<br/>scaffold structurally complete"}}
        G_S05 --> S06["06 — Code Generation<br/>(per-batch loop, no compile)"]
        S06 --> G_S06{{"Every batch pre-flight clean,<br/>permission-set coverage verified"}}
        G_S06 --> S07["07 — Troubleshoot, Iterate<br/>(the one mandatory compile)"]
        S07 --> G_S07{{"0 errors / 0 warnings"}}
    end

    subgraph PROVE["PHASE: PROVE"]
        direction TB
        S08["08 — Gap-Fit Test"] --> G_S08{{"Every gap classified,<br/>resolved or scheduled"}}
        G_S08 --> S09["09 — Package and Test"]
        S09 --> G_S09{{"Publishes cleanly,<br/>green/red-team pass"}}
        G_S09 --> S10["10 — Code Review"]
        S10 --> G_S10{{"Critical findings resolved,<br/>dead-code scan clean"}}
        G_S10 --> S11["11 — Update Design Documents"]
        S11 --> G_S11{{"As-built TDD complete,<br/>FRD reflects reality"}}
        G_S11 --> S12["12 — Document the Code"]
        S12 --> G_S12{{"4 docs exist,<br/>ready for UAT"}}
    end

    G_S01 --> S02
    G_S04 --> S05
    G_S07 --> S08

    classDef step fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    class PRE01,PRE02,S01,S02,S03,S04,S05,S06,S07,S08,S09,S10,S11,S12 step;
    class G_PRE01,G_PRE02,G_S01,G_S02,G_S03,G_S04,G_S05,G_S06,G_S07,G_S08,G_S09,G_S10,G_S11,G_S12 gate;
```

---

## 3. Phase Schematics

### 3.1 DEFINE

```mermaid
flowchart TD
    Start(["Stakeholder conversation,<br/>business need in plain language"]) --> PRE01

    subgraph PRE01["PRE-01 — State the Problem"]
        direction LR
        In1[/"Inputs:<br/>Stakeholder notes"/] --> Act1["Actions:<br/>Write problem statement,<br/>capture vocabulary,<br/>initial entity list,<br/>flag ambiguities"] --> Out1[/"Output:<br/>ProblemStatement.md"/]
    end
    PRE01 --> Gate1{{"Exit gate:<br/>Functional Consultant<br/>signs off"}}

    Gate1 --> PRE02
    subgraph PRE02["PRE-02 — Structured Gap Analysis"]
        direction LR
        In2[/"Inputs:<br/>ProblemStatement.md,<br/>initial entity list"/] --> Act2["Actions:<br/>Run gap checklist —<br/>analytical, posted, lookup,<br/>secondary docs, legacy vs.<br/>modern, tax, global/local"] --> Out2[/"Output:<br/>Expanded entity list<br/>+ gap log"/]
    end
    PRE02 --> Gate2{{"Exit gate:<br/>Technical Lead reviews,<br/>gaps closed or deferred"}}

    Gate2 --> S01
    subgraph S01["01 — Populate the Intake Sheet"]
        direction LR
        In3[/"Inputs:<br/>Expanded entity list,<br/>symbol file"/] --> Act3["Actions:<br/>§1.1 Identity, §1.2 ID ranges,<br/>§1.3 Naming/API, §1.4 Platform,<br/>§1.6 Onboarding/Discoverability,<br/>§1.7 Model & Effort Assignment<br/>— ask, don't infer"] --> Out3[/"Output:<br/>Project Parameters,<br/>Object Register (seeded)"/]
    end
    S01 --> Gate3{{"Exit gate:<br/>No placeholders remain,<br/>human confirms sheet"}}

    Gate3 --> Next(["to DESIGN, Step 02"])

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    class In1,Out1,In2,Out2,In3,Out3 io;
    class Act1,Act2,Act3 act;
    class Gate1,Gate2,Gate3 gate;
    class Start,Next endpoint;
```

### 3.2 DESIGN

```mermaid
flowchart TD
    Start(["from DEFINE,<br/>Project Parameters confirmed"]) --> S02

    subgraph S02["02 — Craft the FRD"]
        direction LR
        In1[/"Inputs:<br/>ProblemStatement.md,<br/>expanded entity list,<br/>Project Parameters"/] --> Act1["Actions (Reasoning role):<br/>Write business language —<br/>what & why, not how.<br/>Validate against DEFINE"] --> Out1[/"Output:<br/>FRD.md"/]
    end
    S02 --> Gate1{{"Exit gate:<br/>Dev Manager sign-off,<br/>every entity accounted for"}}

    Gate1 --> S03
    subgraph S03["03 — Craft the TDD"]
        direction LR
        In2[/"Inputs:<br/>FRD.md, Project Parameters,<br/>symbol file"/] --> Act2["Actions (Reasoning role):<br/>System identity, module grouping,<br/>batch plan, per-object/field spec,<br/>permission sets — must be<br/>self-sufficient"] --> Out2[/"Output:<br/>TDD.md,<br/>Object Register updated"/]
    end
    S03 --> Gate2{{"Exit gate:<br/>Technical Lead sign-off,<br/>self-sufficiency check"}}

    Gate2 --> S04
    subgraph S04["04 — Sanity Check and Validation"]
        direction LR
        In3[/"Inputs:<br/>FRD.md, TDD.md,<br/>symbol file"/] --> Act3["Actions (Reasoning role):<br/>Formal review — can BC do this?<br/>Does TDD implement FRD?<br/>Work the checklist"] --> Out3[/"Output:<br/>SanityCheck.md"/]
    end
    S04 --> Gate3{{"Exit gate:<br/>0 blocking issues,<br/>Technical Lead sign-off"}}

    Gate3 --> Next(["to BUILD, Step 05"])

    Note["Main role integrates every draft<br/>(saves file, ChangeLog/ProjectMemory<br/>bookkeeping) and carries it to the<br/>human for sign-off — the Reasoning<br/>role never owns sign-off"]
    Note -.-> S02
    Note -.-> S03
    Note -.-> S04

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#e6dbf7,stroke:#7d52a8,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    classDef note fill:#fdf0d5,stroke:#c99a3a,stroke-width:1px,stroke-dasharray: 3 3;
    class In1,Out1,In2,Out2,In3,Out3 io;
    class Act1,Act2,Act3 act;
    class Gate1,Gate2,Gate3 gate;
    class Start,Next endpoint;
    class Note note;
```

### 3.3 BUILD

The phase most reshaped by this project's own lessons: no per-batch compile, symbol-verified
lint instead, and exactly one mandatory compile once every planned batch exists.

```mermaid
flowchart TD
    Start(["from DESIGN,<br/>TDD signed off"]) --> S05

    subgraph S05["05 — Plan the Code"]
        direction LR
        In1[/"Inputs:<br/>TDD.md, Object Register"/] --> Act1["Actions:<br/>Confirm batch order,<br/>prepare scaffold,<br/>bootstrap AL MCP Server<br/>+ BCQuality snapshot,<br/>write pre-flight checks<br/>(pre-gen + post-gen passes)"] --> Out1[/"Output:<br/>Batch plan, scaffold,<br/>pre-flight checklist"/]
    end
    S05 --> Gate1{{"Exit gate:<br/>Batch order agreed,<br/>scaffold structurally complete<br/>(not compiled)"}}

    Gate1 --> S06

    subgraph S06["06 — Code Generation (repeats per batch)"]
        direction TB
        B1["Pause for human approval,<br/>then generate batch's AL files<br/>from standard template"]
        B1 --> PreGen["Pre-generation pre-flight<br/>(Main role): identifier length,<br/>reserved keywords, localization,<br/>ObsoleteState — on planned<br/>names/fields; fix TDD if needed"]
        PreGen --> PostGen["Post-generation pre-flight<br/>(Light role): required props,<br/>Rec.-qualification, dead code,<br/>indentation, permission-set<br/>coverage, symbol verification —<br/>reports findings, Main role fixes"]
        PostGen --> PermCheck["Verify permission-set coverage<br/>across ALL batches so far<br/>(Light role) — design-time check,<br/>independent of compiling"]
        PermCheck --> MoreBatches{"More batches<br/>in the plan?"}
        MoreBatches -- "Yes" --> B1
    end
    MoreBatches -- "No — every planned<br/>batch generated" --> Gate2{{"Exit gate:<br/>Every batch pre-flight clean,<br/>permission-set coverage verified<br/>— NO compile required here"}}

    Gate2 --> S07
    subgraph S07["07 — Troubleshoot, Iterate"]
        direction LR
        Compile["FIRST: compile the whole<br/>extension once — the one<br/>mandatory compile (Op. Rule 4)"] --> Q{"Errors or<br/>warnings?"}
        Q -- "Yes" --> Diag["Reasoning role diagnoses:<br/>one-off or pattern? where<br/>from? what rule missed it?"]
        Diag --> Fix["Main role fixes root cause,<br/>regenerates files, re-compiles,<br/>logs ChangeLog + updates TDD"]
        Fix --> Compile
        Q -- "No" --> Clean["0 errors / 0 warnings"]
    end
    S07 --> Gate3{{"Exit gate:<br/>Full extension compiles clean,<br/>ChangeLog & TDD reconciled"}}

    Gate3 --> Next(["to PROVE, Step 08"])

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef light fill:#d9f2d9,stroke:#4a9b4a,stroke-width:1px;
    classDef reasoning fill:#e6dbf7,stroke:#7d52a8,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    classDef decision fill:#fde2e2,stroke:#c0504d,stroke-width:1px;
    class In1,Out1 io;
    class Act1,B1,Fix act;
    class PostGen,PermCheck light;
    class PreGen act;
    class Diag reasoning;
    class Gate1,Gate2,Gate3 gate;
    class Start,Next,Clean endpoint;
    class MoreBatches,Q decision;
```

### 3.4 PROVE

```mermaid
flowchart TD
    Start(["from BUILD,<br/>extension compiles 0/0"]) --> S08

    subgraph S08["08 — Gap-Fit Test, Fidelity Validation"]
        direction LR
        In1[/"Inputs:<br/>FRD.md, TDD.md,<br/>built AL, ChangeLog"/] --> Act1["Actions (Reasoning role):<br/>Three-way comparison —<br/>FRD vs. TDD vs. as-built.<br/>Classify every gap"] --> Out1[/"Output:<br/>GapAnalysis.md,<br/>gap-fill work items"/]
    end
    S08 --> Gate1{{"Exit gate:<br/>Every gap classified,<br/>resolved or scheduled"}}

    Gate1 --> GapFill{"Any gap-fill<br/>work items?"}
    GapFill -- "Yes" --> GapCycle["Own pass through<br/>Step 05/06/07 discipline —<br/>pre-flight, then compile<br/>(Operating Rule 4)"]
    GapCycle --> S09
    GapFill -- "No" --> S09

    subgraph S09["09 — Package and Test the App"]
        direction LR
        In2[/"Inputs:<br/>Clean-compiling extension,<br/>permission sets if any tables"/] --> Act2["Actions:<br/>Build .app (name/version from<br/>app.json), publish to sandbox,<br/>green-team + red-team tests,<br/>verify permission sets"] --> Out2[/"Output:<br/>.app package,<br/>test-run record"/]
    end
    S09 --> Gate2{{"Exit gate:<br/>Publishes cleanly,<br/>green tests pass,<br/>red tests fail gracefully"}}

    Gate2 --> S10
    subgraph S10["10 — Code Review"]
        direction LR
        In3[/"Inputs:<br/>Full built extension,<br/>TDD.md, Standards"/] --> Act3["Actions (Reasoning role):<br/>Code quality, dead code,<br/>obsolete refs, anti-patterns,<br/>permission-set re-verify,<br/>BCQuality knowledge-backed review"] --> Out3[/"Output:<br/>CodeReview.md"/]
    end
    S10 --> Gate3{{"Exit gate:<br/>Critical findings resolved,<br/>dead-code scan 100% clean"}}

    Gate3 --> S11
    subgraph S11["11 — Update Design Documents"]
        direction LR
        In4[/"Inputs:<br/>TDD.md, FRD.md, ChangeLog,<br/>GapAnalysis.md, CodeReview.md"/] --> Act4["Actions:<br/>New PostDevTDD.md (as-built);<br/>update FRD.md in place<br/>(new baseline)"] --> Out4[/"Output:<br/>PostDevTDD.md,<br/>updated FRD.md"/]
    end
    S11 --> Gate4{{"Exit gate:<br/>As-built TDD regenerable,<br/>FRD reflects reality"}}

    Gate4 --> S12
    subgraph S12["12 — Document the Code"]
        direction LR
        In5[/"Inputs:<br/>PostDevTDD.md, built AL,<br/>Step 09 test-run record"/] --> Act5["Actions:<br/>Generate reference docs +<br/>Mermaid ER diagram (render it!),<br/>human test script, UserGuide.md,<br/>Deployment.md"] --> Out5[/"Output:<br/>4 documents:<br/>Documentation, UserGuide,<br/>HumanUnitTestScript, Deployment"/]
    end
    S12 --> Gate5{{"Exit gate:<br/>Reference generated from code,<br/>ready for UAT"}}

    Gate5 --> Done(["Deployed, Documented App"])

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef reasoning fill:#e6dbf7,stroke:#7d52a8,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    classDef decision fill:#fde2e2,stroke:#c0504d,stroke-width:1px;
    class In1,Out1,In2,Out2,In3,Out3,In4,Out4,In5,Out5 io;
    class Act2,Act4,Act5,GapCycle act;
    class Act1,Act3 reasoning;
    class Gate1,Gate2,Gate3,Gate4,Gate5 gate;
    class Start,Done endpoint;
    class GapFill decision;
```

---

## 4. Cross-Cutting Schematics

These two aren't tied to a single phase — ALL ALONG runs underneath every phase, and the
Model & Effort Assignment (§1.7) role split, if configured, applies wherever a **Role:** note
appears in the runbook.

### 4.1 ALL ALONG — Continuous Discipline

```mermaid
flowchart LR
    subgraph Phases["The four phases, running in sequence"]
        direction LR
        DEFINE["DEFINE"] --> DESIGN["DESIGN"] --> BUILD["BUILD"] --> PROVE["PROVE"]
    end

    subgraph Continuous["ALL ALONG — every phase, every step"]
        direction TB
        Doc["Document<br/>keep every required doc<br/>current, not retroactively"]
        Change["Track Changes — ChangeLog<br/>every FRD/TDD deviation logged<br/>before the next batch"]
        Retain["Retain Explanations<br/>who decided, and why —<br/>not just the outcome"]
        Test["Testing Feedback Log<br/>verbatim findings, triaged<br/>explicitly, cross-referenced"]
        Mem["Project Memory<br/>docs/ProjectMemory.md —<br/>anchor, not a narrative"]
        Pack["Packaging & Versioning<br/>never delete a package;<br/>propose bumps, don't apply silently"]
        MCP["AL MCP Server<br/>bootstrap once, prefer its<br/>tools over ad hoc terminal use"]
        BCQ["BCQuality Knowledge Snapshot<br/>fetch once, refresh only<br/>on explicit request"]
    end

    Continuous -.-> DEFINE
    Continuous -.-> DESIGN
    Continuous -.-> BUILD
    Continuous -.-> PROVE

    classDef phase fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef discipline fill:#fdf0d5,stroke:#c99a3a,stroke-width:1px;
    class DEFINE,DESIGN,BUILD,PROVE phase;
    class Doc,Change,Retain,Test,Mem,Pack,MCP,BCQ discipline;
```

### 4.2 Model & Effort Assignment (§1.7)

```mermaid
flowchart TD
    Config{"§1.7 configured?"}
    Config -- "No (default)" --> OneModel["Everything runs through<br/>one model, as if §1.7<br/>didn't exist"]
    Config -- "Yes" --> ThreeRoles["Fixed three-role division —<br/>fixed regardless of which<br/>physical models are assigned"]

    ThreeRoles --> Main
    ThreeRoles --> Light
    ThreeRoles --> Reasoning

    subgraph Main["MAIN ROLE"]
        direction TB
        MainWork["All BUILD code generation<br/>All actual code edits<br/>(incl. applying what Light/<br/>Reasoning report)<br/>End-to-end ownership of:<br/>ChangeLog, Object Register,<br/>ProjectMemory, TestingFeedback.md"]
    end

    subgraph Light["LIGHT ROLE"]
        direction TB
        LightWork["Step 05 post-generation<br/>pre-flight pass only —<br/>required props, Rec.-qualification,<br/>dead code, indentation,<br/>permission-set coverage,<br/>symbol verification<br/>Reports findings; never edits code"]
    end

    subgraph Reasoning["REASONING ROLE"]
        direction TB
        ReasonWork["Sanity Check (04), Gap-Fit<br/>Test (08), Code Review (10),<br/>FRD authorship (02), TDD<br/>authorship (03), root-cause<br/>troubleshooting (07), diagnosing<br/>testing-feedback reports<br/>Reports findings/drafts/diagnoses;<br/>never edits code or continuity docs"]
    end

    Main -.->|"relays fixes back into"| Codebase[("The codebase &<br/>continuity documents")]
    Light -.->|"findings relayed to"| Main
    Reasoning -.->|"findings/drafts/diagnoses<br/>relayed to"| Main

    classDef decision fill:#fde2e2,stroke:#c0504d,stroke-width:1px;
    classDef main fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef light fill:#d9f2d9,stroke:#4a9b4a,stroke-width:1px;
    classDef reasoning fill:#e6dbf7,stroke:#7d52a8,stroke-width:1px;
    classDef store fill:#f2f2f2,stroke:#888,stroke-width:1px;
    class Config decision;
    class OneModel store;
    class ThreeRoles main;
    class MainWork main;
    class LightWork light;
    class ReasonWork reasoning;
    class Codebase store;
```

---

*Generated from `CLAUDE.md` v2.0.0.0 (2026-09-12). If the runbook changes in a way that affects
the phase/step/role structure, regenerate the affected diagram(s) here and re-render before
committing — don't hand-edit a diagram without checking it still parses.*

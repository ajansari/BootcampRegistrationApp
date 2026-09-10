# Build Plan (Step 05) — Bootcamp Registration Tracking

**Phase:** BUILD · **Step:** 05 — Plan the Code · **Status:** Awaiting human agreement on batch
order + compilation route
**Date:** 2026-09-10
**Inputs:** `docs/TDD.md` (§2 modules, §3 batch plan, §9 templates, §10 pre-flight),
`docs/ObjectRegister.md`, `docs/SanityCheck.md`.

---

## 1. Confirmed batch build order

From `TDD.md` §3 (restructured by Sanity Check S-7). Within each batch, reference/lookup objects
precede referrers.

| Batch | Delivers | Objects (in build order) | Depends on |
|---|---|---|---|
| **1 — Foundation** | Status enum; Setup singleton + page; Install codeunit (setup-ensure only); **both permission sets (scoped to the setup table; grown per batch — ChangeLog BUILD-02)** | 60800 `ocpfBootcampStatus` → 60801 `ocpfBootcampRegSetup` (table) → 60802 `ocpfBootcampRegSetup` (page) → 60803 `ocpfBootcampRegInstall` → 60890 `OCPF - Bootcamp Read` → 60891 `OCPF - Bootcamp Edit` | standard: `No. Series` (308) |
| **2 — Core tables & logic** | Both core tables + Mgt codeunit, complete (all fields, triggers, `OnDelete` guard, seeding, overbooking confirm, seat maintenance + 4 subscribers); **add `ocpfBootcamp` + `ocpfAttendee` `tabledata` lines to 60890/60891 (P-15)** | 60800/60801 (exist) → 60810 `ocpfBootcamp` (table) + 60820 `ocpfAttendee` (table) + 60813 `ocpfBootcampRegMgt` (written together — mutual reference) → grow 60890/60891 | Batch 1; standard: `No. Series` cod 310, `Customer` 18 |
| **3 — In-client pages** | Bootcamp list + card (card embeds Attendees subpart); Attendee list + subform | 60822 `ocpfAttendeeSubform` → 60821 `ocpfAttendeeList` → 60811 `ocpfBootcampList` → 60812 `ocpfBootcampCard` | Batch 2 |
| **4 — API** | Bootcamp API page; Attendee API page | 60830 `ocpfBootcamps` → 60831 `ocpfAttendees` | Batch 2 |
| **5 — Wizard, Navigation, Permissions** | Assisted Setup Wizard; Business Manager RC pageextension; revisit Install for Guided Experience registration; **final review/top-up of 60890/60891 (they already exist from Batch 1)** | 60840 `ocpfBootcampRegSetupWizard` → 60841 `ocpfBusinessMgrRCExt` → revisit 60803 → review 60890/60891 | Batches 1–4; standard: `Guided Experience` cod 1990, page 9022 |

Rule: **generate one batch, lint + compile it to 0/0, commit it, then start the next.** Never
generate all batches first (runbook Operating Rule 4).

## 2. Scaffold (this step)

| Item | State |
|---|---|
| `app.json` | **Rewritten** — `name` = `Bootcamp Registration Tracking`, `publisher` = `OnlyCopilotFans`, `idRanges` = `60800–60899`, `runtime` = `17.0`, `application` = `28.0.0.0`, `features` = `["NoImplicitWith"]`, `brief`/`description` filled. `version` stays `1.0.0.0`. |
| `.vscode/launch.json` | Kept as-is — SaaS cloud sandbox `opcSandbox` (matches Deployment Target `SaaS PTE`). |
| Folder structure | `src/Foundation`, `src/Bootcamp`, `src/Attendee`, `src/Api`, `src/Setup`, `src/RoleCenter`, `src/Permissions`; `out/` for packages (git-ignored, never pruned). |
| `.gitignore` | Ignores `out/*.app` and editor cruft; **keeps `.alpackages/`** in the repo (exact v28.4 symbols → reproducible build). |
| `.alpackages/` | Present: Base App 28.4.53241, System App 28.4.53241, Business Foundation 28.4.53241, Application 28.4.53241, System 28.0.53984. |
| Version control | `git init`; work on branch `build/bootcamp-registration` (not the default branch). Each batch = its own commit referencing its ChangeLog Issue id. |

### 2.1 Known scaffold risk (resolve at first compile)

- **`dependencies: []`.** `No. Series` (table 308 / codeunit 310) lives in the Microsoft
  **Business Foundation** app. Modern AL usually resolves the first-party application stack
  (System App + Base App + Business Foundation) transitively from `"application": "28.0.0.0"`,
  so no explicit dependency is declared. **If the first compile reports `No. Series` unresolved**,
  add an explicit dependency on Business Foundation (id/publisher/version read from
  `.alpackages/Microsoft_Business Foundation_28.4.53241.53312.app`) and log it as a ChangeLog
  Issue BUILD-01. This is the single most likely first-compile failure.

## 3. Compilation route — **decision needed**

`alc.dll` ships in the AL extension (`~/.vscode/extensions/ms-dynamics-smb.al-18.0.2732683/bin/`)
but it is a framework-dependent **.NET 10** assembly and this machine has **no `dotnet` runtime**
(none on PATH, none bundled). So the agent cannot run `alc` locally as things stand. Options:

| Option | What it means |
|---|---|
| **A — AJ compiles in VS Code** | After each generated batch, AJ runs AL: Package (or Ctrl+Shift+B) in VS Code and pastes the Problems output back. The agent root-causes per Step 07, fixes, AJ re-compiles. Slowest round-trip but zero setup. |
| **B — Install .NET 10 + run `alc` headless** | Agent (with approval) installs the .NET 10 runtime (e.g. via the dotnet-install script) and invokes `dotnet alc.dll /project:. /packagecachepath:.alpackages /out:out/…app` after each batch itself. Fast iteration; needs a one-time ~200 MB runtime install. |
| **C — CI / sandbox pipeline** | If AJ has a pipeline (GitHub Actions with the AL compiler, or `bccontainerhelper`) that compiles on push, batches are validated there. |

Pre-flight validation (§4) runs regardless of which option is chosen.

> **Decision (AJ, 2026-09-10): Option A.** AJ compiles each generated batch in VS Code and
> returns the Problems output. The agent runs pre-flight (§4) before handoff, then root-causes
> any compiler/linter findings per Step 07.
>
> **Superseded (AJ, 2026-09-10): terminal compile, no install.** VS Code's `.NET Install Tool`
> extension (`ms-dotnettools.vscode-dotnet-runtime`) had already provisioned a private .NET 10
> runtime for the AL extension at
> `~/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet/10.0.12~arm64~aspnetcore/dotnet`.
> The agent runs `dotnet alc.dll /project:. /packagecachepath:.alpackages /out:out/…app`
> against that runtime after each batch (with CodeCop + UICop + PerTenantExtensionCop analyzers).
> Nothing is installed on the machine. A throwaway user-local runtime install under `~/.dotnet`
> was made and then removed when this pre-existing runtime was found. Wrapper script lives in the
> session scratchpad, not the repo.

## 4. Pre-flight validation checklist (run before delivering each batch)

Per `TDD.md` §10. Applied to the batch's planned objects/fields **before** generating, and
re-checked on the generated files.

| # | Check | How |
|---|---|---|
| P-1 | Object IDs within 60800–60899, none reused | cross-check against `ObjectRegister.md` |
| P-2 | Every identifier ≤ 30 chars (fields, objects, API entity names incl. `ocpf`) | scan |
| P-3 | No field identifier is an AL reserved keyword | scan against keyword list |
| P-4 | `namespace OCPF.BootcampRegistration;` is the first non-comment line of every `.al` file | grep |
| P-5 | Every `using` is one actually referenced, and copied from the symbol namespace in `TDD.md` §5 | grep + eyeball |
| P-6 | Every table field: `Caption` + `ToolTip` present | grep per `field(` |
| P-7 | Every non-API page field: `ApplicationArea = All` + `ToolTip` | grep |
| P-8 | Every API page: `ODataKeyFields = SystemId` + exactly one of `DelayedInsert = true` / `Editable = false`; every API field has a `Caption` | grep |
| P-9 | No obsolete reference (`ObsoleteState`, `NoSeriesManagement`, legacy price tables) | grep |
| P-10 | No dead code: no empty `trigger`, no `// TODO`, no commented-out field lines | grep |
| P-11 | Every field source reference is `Rec.`-qualified (or explicit var) — `NoImplicitWith` | eyeball each trigger |
| P-12 | 4-space indent, no tab characters | `grep -nP '\t'` returns nothing |
| P-13 | Localization: no `#if`/country gating introduced (NA, but no localized fields) | grep `#if` |
| P-14 | Labels for every user-facing message; `Comment` on labels with placeholders | grep `Error(`/`Confirm(`/`Message(` |
| P-15 | Every table introduced in this batch has a matching `tabledata` line in a permission set shipped in the same batch (PTE0004 — ChangeLog BUILD-02) | grep each new `table` id against `src/Permissions/*.al` |
| P-16 | Every `.al` file is named `<ObjectName>.<Type>.al` (CodeCop AA0215) | compare filename to object name |

## 5. Exit gate (Step 05)

- [x] Batch order agreed (AJ, 2026-09-10) — §1
- [x] Compilation route chosen: Option A (AJ compiles in VS Code) — §3
- [x] Scaffold prepared: `app.json` rewritten, folders created, `.gitignore` set, git baseline `7e71b33`
- [x] Pre-flight checklist ready (§4)
- [ ] Scaffold "compiles empty" — AJ to confirm an empty build of the rewritten `app.json` succeeds in VS Code (or first real batch serves as the check)

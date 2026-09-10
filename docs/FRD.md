# Functional Requirements Document — Bootcamp Registration Tracking (BC PTE)

**Phase:** DESIGN · **Step:** 02 · **Status:** Awaiting FRD + Dev Manager sign-off
**Date:** 2026-09-10 · **Author:** Claude (agent), for AJ Ansari

**Pre-BUILD version pointer:** This FRD is updated **in place** during PROVE (Step 11). Its
original pre-BUILD text is preserved in version control — after the first commit, list its
revisions with `git log --follow -- docs/FRD.md` and check out the commit tagged/noted in Step 11.
(No `PostDevFRD.md` is ever created — see runbook Step 11 rationale.)

**Upstream artifacts:** `requirements/bootcamp-registration-extension-requirements.md` (frozen
input), `docs/ProblemStatement.md`, `docs/GapAnalysis-PRE02.md`, `docs/ProjectParameters.md`.

---

## 1. Purpose and scope

### 1.1 Purpose

Business Central has no structured way to run bootcamp training events. This per-tenant extension
gives staff one place to:

- define each bootcamp (topic, venue, date, price, seat limits, viability threshold, lifecycle
  status);
- register attendees against a bootcamp and capture their contact details and an optional link
  to an existing customer;
- record, per attendee, whether payment was received, when, and how much, and whether they
  attended;
- see at a glance how full a bootcamp is (seats remaining) and where it stands (status).

An Assisted Setup Wizard prepares the feature for first use (numbering, optional sample data).
Read/write API endpoints let external systems, BI, and AI tooling work with the same data.

### 1.2 In scope

| # | Capability |
|---|---|
| F-1 | Create, view, edit, and delete **Bootcamp** records, each identified by a number from a No. Series. |
| F-2 | Capture on a bootcamp: Topic, Location, Bootcamp Date (single day), Price, Max Seats, Min Seats (Go/No-Go), Status. |
| F-3 | Show **Seats Remaining** on a bootcamp = Max Seats − current attendee count, maintained automatically and never entered by a user. Also expose a live **Registered Attendees** count. |
| F-4 | **Status** is a manual label (Active / Inactive / Completed / Canceled). No automated transitions of any kind. |
| F-5 | Register one or more **Attendee** records against a bootcamp, each identified by a number from a No. Series and carrying its parent Bootcamp No. |
| F-6 | Capture on an attendee: Name, Email Address, Phone Number, Company. |
| F-7 | Optionally link an attendee to an existing **Customer** (single optional lookup; no relationship-type selector, no Contact/Vendor links). |
| F-8 | Capture on an attendee: Paid (yes/no), Payment Date, Amount Paid. Amount Paid defaults from the bootcamp Price on creation but stays editable and is never auto-overwritten after the user changes it. |
| F-9 | Capture on an attendee: Attended (yes/no). No check-in timestamp. |
| F-10 | Registering an attendee **past Max Seats** shows a confirmable warning; the user may proceed (deliberate overbooking is allowed). |
| F-11 | Deleting a bootcamp that still has attendees is **blocked** with a clear error; the user must remove the registrations first. |
| F-12 | A single-instance **Bootcamp Registration Setup** record holds the No. Series for Bootcamp and for Attendee. |
| F-13 | An **Assisted Setup Wizard** guides an admin through choosing/creating those No. Series and can optionally create one or two sample bootcamps. It is registered in the **Assisted Setup** list, shows a completion state, and is re-runnable. |
| F-14 | In-client UI: Bootcamp list and card, an Attendee list plus an Attendee subpage on the bootcamp card, the Setup page, and the wizard. A navigation entry is added to the **Business Manager Role Center**. |
| F-15 | **API v1.0** read/write endpoints for Bootcamp and for Attendee, for external systems, BI, and AI tooling. |

### 1.3 Out of scope

- Automatic status changes based on the bootcamp date or any other logic (F-4 is manual only).
- Enforced go/no-go: nothing happens automatically when registrations are below Min Seats.
- Hard seat-limit enforcement (F-10 warns, never blocks).
- Check-in timestamps; multi-day / date-range bootcamps.
- The Relationship Type selector and any link to **Contact** or **Vendor** (removed per AJ) —
  only the optional Customer link remains.
- Configurable default values on the Setup record (default status, default seat counts, etc.).
- Any payment posting, invoicing, G/L or ledger-entry integration. Paid / Payment Date / Amount
  Paid are descriptive fields only.
- Currency handling — all amounts are in the company's local currency; no Currency Code field.
- Tax fields of any kind (no VAT/tax posting groups, no tax area).
- API exposure of the Setup record or the wizard.
- Waitlist management.

## 2. Business objectives and value

| Objective | Value delivered |
|---|---|
| One system of record for bootcamps and registrations | Removes spreadsheets/ad-hoc tracking; everyone sees the same data inside BC. |
| Visibility of fill rate and viability | Staff can see seats remaining and whether a bootcamp has cleared its go/no-go threshold, and act (promote, or cancel) before the date. |
| Payment and attendance tracking per attendee | A simple, auditable record of who paid, how much, and who showed up — without building a billing system. |
| Fast, guided first-time setup | The wizard gets a new customer productive in minutes and is re-runnable if numbering needs to change. |
| Open data surface | External registration forms, BI dashboards, and AI assistants can read and write bootcamp/attendee data through a stable v1.0 API. |

## 3. Target consumers

| Consumer | Needs | Surface |
|---|---|---|
| Training coordinator / back-office staff | Set up bootcamps; register attendees; mark paid/attended; watch seats remaining and go/no-go. | Bootcamp list/card, Attendee subpage & list (in-client). Business Manager Role Center entry. |
| Administrator / implementer | One-time (or repeat) configuration of numbering; optional sample data. | Assisted Setup Wizard + Bootcamp Registration Setup page. |
| External systems / integration middleware | Push registrations in from a web form; keep an external roster in sync. | API v1.0 — `ocpfBootcamps`, `ocpfAttendees` (read/write). |
| BI / reporting | Fill rate, revenue-paid, attendance analysis. | API v1.0 (read). |
| AI tooling | Query and update bootcamp/attendee data conversationally. | API v1.0 (read/write). |

## 4. Platform requirements

| Item | Requirement |
|---|---|
| Product | Microsoft Dynamics 365 Business Central |
| Deployment model | SaaS per-tenant extension (PTE) |
| BC application minimum | 28.0.0.0 |
| Recommended / validation target | BC 28.4 or newer |
| AL runtime | 17.0 |
| Dependencies | Base Application, System Application, Business Foundation (for `No. Series`), Application — all satisfied by a standard BC 28.4 online tenant. No third-party dependencies. |
| Localization | NA. No country-specific or tax fields are introduced, so the extension is effectively world-wide. |
| Namespace | `OCPF.BootcampRegistration` |
| Feature flag | `NoImplicitWith` enabled and enforced. |

**Verified platform capabilities** (checked against the BC v28.4 symbol files, see
`GapAnalysis-PRE02.md` and Step 04):

- `No. Series` (table 308) + `No. Series` codeunit (310) in `Microsoft.Foundation.NoSeries`
  provide numbering — `GetNextNo`, `PeekNextNo`, `TestManual`.
- `Customer` (table 18) in `Microsoft.Sales.Customer` is the link target.
- `Guided Experience` codeunit (1990) in `System.Environment.Configuration` provides
  `InsertAssistedSetup`, `IsAssistedSetupComplete`, `CompleteAssistedSetup`, `Run` — supports
  F-13.
- `Business Manager Role Center` (page 9022) in `Microsoft.Finance.RoleCenters` is extensible
  for F-14.
- API pages with `APIPublisher` / `APIGroup` / `EntityName` / `EntitySetName` /
  `ODataKeyFields = SystemId` are the standard mechanism for F-15.
- A `FlowField` `CalcFormula = count(...)` provides the live `Registered Attendees` count; `Seats Remaining` is a subscriber-maintained stored field (D-8).
- A table `OnDelete` trigger provides F-11 (block on delete).
- A page/table `OnInsert` or field `OnValidate` seeding a stored field provides F-8 (Amount Paid
  default that does not overwrite user input).

No requirement in this document depends on unverified platform behavior.

## 5. Design rules (non-negotiable)

| # | Rule |
|---|---|
| D-1 | Every name, ID, version, prefix, namespace, and API value is derived from `docs/ProjectParameters.md`. Nothing in that block is hardcoded elsewhere. |
| D-2 | All object IDs fall within **60800–60899**. |
| D-3 | Every AL object declares `namespace OCPF.BootcampRegistration` and the exact `using` directives for the standard objects it references, copied from the symbol file. |
| D-4 | `NoImplicitWith` is on. Every field reference is `Rec.`-qualified (or an explicit variable). |
| D-5 | Every table field and every page field has `Caption` and `ToolTip`; every page field has `ApplicationArea = All`. Captions/ToolTips are written to be self-describing for an API consumer who never sees the BC UI. |
| D-6 | API pages: `ODataKeyFields = SystemId`; exactly one of `DelayedInsert = true` (editable) or `Editable = false` (read-only) per §7 mutability. `APIPublisher = 'OnlyCopilotFans'`, `APIGroup = 'ocpf_bootcampRegistration'`, `APIVersion = 'v1.0'`. |
| D-7 | No dead code: no empty triggers, no commented-out fields, no `// TODO`. |
| D-8 | Seats Remaining is a **non-editable field maintained automatically** by `ocpfAttendee` table event subscribers (OnAfterInsert/Modify/Delete/Rename) and by the Bootcamp `Max Seats` `OnValidate`; users and API callers never write it. A companion `FlowField` **`Registered Attendees`** gives the live count. *(Original D-8 required a pure FlowField; AL `FlowField` `CalcFormula` cannot express "Max Seats minus a count", so a subscriber-maintained stored field is used — see ChangeLog Issue DESIGN-02.)* |
| D-9 | Amount Paid is a **stored** field seeded on insert from the bootcamp Price; the seeding logic must not overwrite a value the user (or an API caller) has already supplied. |
| D-10 | Status is a project `enum` with values Active / Inactive / Completed / Canceled and no others; no code changes a bootcamp's status automatically. |
| D-11 | Bootcamp `OnDelete` blocks deletion when any Attendee references it (F-11). The optional Customer link on Attendee is a `TableRelation` only — deleting a Customer is BC's own concern and is not extended here. |
| D-12 | Money fields (`Price`, `Amount Paid`) use `Decimal` with `AutoFormatType = 1` (LCY). No Currency Code. |
| D-13 | Email Address uses the standard email field pattern (`ExtendedDatatype = EMail`, and reasonable format validation on entry); it is not a mandatory field. |
| D-14 | Zero compiler errors and zero warnings before the PROVE phase; warnings are treated as errors during development. |
| D-15 | Two permission sets ship: a read-only set and a read/write set that includes it, named with the `OCPF - ` prefix, IDs from the allocated range. |

## 6. Entity / object inventory

Object IDs and exact source-table numbers are fixed in the TDD (Step 03); this inventory fixes
*what* exists and its read/write nature (Standards §4.2 mutability rules).

### 6.1 New tables (owned by this extension)

| Entity | Type | Purpose | Mutability | Key |
|---|---|---|---|---|
| **Bootcamp** | table | The training event master. | **Read/Write.** Users create and maintain bootcamps. | `No.` (Code[20], from No. Series) |
| **Attendee** | table | One person's registration against one bootcamp. | **Read/Write.** Users create and maintain registrations. | `No.` (Code[20], from No. Series) — with `Bootcamp No.` as an indexed non-key field and `TableRelation` to Bootcamp |
| **Bootcamp Registration Setup** | table | Singleton configuration (the two No. Series codes). | **Read/Write, in-client only.** Not exposed via API. One record. | primary key `Code` (empty), singleton pattern |

#### Bootcamp — fields (business view)

| Field | Meaning | Notes |
|---|---|---|
| No. | Identifier | From `Bootcamp Nos.` No. Series. |
| Topic | Subject/title of the bootcamp | Free text. |
| Location | Where it is held | Free text (a venue/city), **not** a warehouse Location link. |
| Bootcamp Date | The single day it runs | One date; no start/end range. |
| Price | Standard price per attendee | LCY decimal. Feeds the Attendee Amount Paid default. |
| Max Seats | Maximum attendees allowed | Integer. |
| Min Seats (Go/No-Go) | Minimum registrations for the bootcamp to be viable | Integer. Informational — nothing automated. |
| Registered Attendees | Count of attendee registrations | FlowField, read-only. |
| Seats Remaining | Max Seats − Registered Attendees | Non-editable, auto-maintained stored field (D-8). |
| Status | Active / Inactive / Completed / Canceled | Manual only (D-10). |

#### Attendee — fields (business view)

| Field | Meaning | Notes |
|---|---|---|
| No. | Identifier | From `Attendee Nos.` No. Series. |
| Bootcamp No. | The bootcamp registered for | Required; `TableRelation` to Bootcamp; drives delete-block (D-11). |
| Name | Attendee full name | Free text. |
| Email Address | Attendee email | Email datatype, optional (D-13). |
| Phone Number | Attendee phone | Text. |
| Company | Attendee's company | Free text. |
| Customer No. | Optional link to an existing customer | `TableRelation` to Customer; may be blank. |
| Paid | Payment received? | Boolean. |
| Payment Date | Date payment was received | Date; expected only when Paid = true (not enforced). |
| Amount Paid | Amount actually paid | LCY decimal; defaults from bootcamp Price on insert, editable, never auto-overwritten (D-9). |
| Attended | Did the person attend? | Boolean; no timestamp. |

#### Bootcamp Registration Setup — fields (business view)

| Field | Meaning |
|---|---|
| Bootcamp Nos. | No. Series used to number bootcamps. |
| Attendee Nos. | No. Series used to number attendees. |

### 6.2 New enum

| Object | Values |
|---|---|
| **Bootcamp Status** | Active, Inactive, Completed, Canceled (non-extensible unless a later need arises). |

### 6.3 New pages

| Page | Type | For | Editable? |
|---|---|---|---|
| Bootcamp List | List | Bootcamp | Yes |
| Bootcamp Card | Card | Bootcamp, with an Attendees subpage | Yes |
| Attendees (subpage) | ListPart | Attendee, filtered to the shown bootcamp | Yes |
| Attendee List | List | Attendee (all, standalone) | Yes |
| Bootcamp Registration Setup | Card (single instance) | Bootcamp Registration Setup | Yes |
| Assisted Setup Wizard | NavigatePage (wizard) | guided configuration | n/a |
| Bootcamp API | API | Bootcamp | Yes (read/write) |
| Attendee API | API | Attendee | Yes (read/write) |

### 6.4 New codeunits

| Codeunit | Responsibility |
|---|---|
| Install / Setup registration | On install/company init: ensure the Setup record exists; register the wizard with Guided Experience (F-13). |
| Bootcamp Registration Mgt. | Numbering (`GetNextNo`), Amount Paid seeding helper (D-9), Max Seats warning check (F-10), wizard "apply settings" and "create sample data" actions. |

### 6.5 Standard objects referenced (not modified except where noted)

| Object | Number | Use | Access |
|---|---|---|---|
| No. Series | table 308 | Numbering source for Bootcamp and Attendee | Read |
| No. Series (codeunit) | codeunit 310 | `GetNextNo` / `TestManual` / `PeekNextNo` | Read |
| Customer | table 18 | Optional Attendee link | Read |
| Guided Experience | codeunit 1990 | Register/track the wizard | Read/execute |
| Business Manager Role Center | page 9022 | **Extended** (pageextension) to add a Bootcamps navigation entry + wizard link (F-14) | Modified (additive) |

### 6.6 Permission sets

| Set | Grants |
|---|---|
| `OCPF - Bootcamp Read` | Read on Bootcamp, Attendee, Bootcamp Registration Setup and all this extension's pages. |
| `OCPF - Bootcamp Edit` | Includes `OCPF - Bootcamp Read` plus insert/modify/delete on the three tables. |

Consumers also need the relevant standard `D365 BUS FULL ACCESS` / `D365 BASIC` base
permissions and read access to `Customer` and `No. Series`; this is documented, not granted here.

## 7. Data mutability (Standards §4.2)

| Table | API mutability | Reasoning |
|---|---|---|
| Bootcamp | Read/Write (`DelayedInsert = true` on the API page) | Master data users and integrations both create/maintain. |
| Attendee | Read/Write (`DelayedInsert = true`) | Registrations arrive from web forms and staff alike. |
| Bootcamp Registration Setup | Not exposed via API. In-client editable. | Configuration, changed rarely by an admin. |
| Seats Remaining / Registered Attendees (fields) | Read-only everywhere. | Derived / auto-maintained values (D-8). |

## 8. Non-functional requirements

| # | Requirement |
|---|---|
| N-1 | Compiles with **0 errors, 0 warnings** (warnings-as-errors) before PROVE. |
| N-2 | Every generated object follows the one standard template; structure/naming/formatting identical across all batches. 4-space indent, no tabs. |
| N-3 | No reference anywhere to a field/table/procedure/event marked `ObsoleteState = Pending` or `Removed`, and no subscription to an obsolete event. |
| N-4 | API responses are self-describing: every exposed field carries a meaningful Caption and ToolTip. |
| N-5 | Seats Remaining and Amount Paid seeding perform acceptably on a bootcamp with a few hundred attendees (FlowField count is indexed on `Bootcamp No.`). |
| N-6 | The extension installs and uninstalls cleanly on a BC 28.4 sandbox; uninstall leaves no orphaned Guided Experience item (cleanup on `OnUninstall`/via the platform). |
| N-7 | Deleting a bootcamp with attendees fails **gracefully** with an actionable message (not a raw platform error). |
| N-8 | All identifiers ≤ 30 characters; all entity names ≤ 30 characters including the `ocpf` prefix. |
| N-9 | Red-team API calls (write to read-only field, unknown field, bad key, delete with dependencies, missing permission) each fail with a clean, actionable error. |

## 9. Validation against the DEFINE artifacts

### 9.1 Every DEFINE entity is accounted for

| `GapAnalysis-PRE02.md` §4 entity | FRD location |
|---|---|
| Bootcamp | §6.1 (table), §6.3 (pages), §6.5 (API) |
| Attendee | §6.1 (table), §6.3 (pages + subpage), §6.5 (API) |
| Bootcamp Registration Setup | §6.1 (table), §6.3 (page) — API-excluded per §1.3 |
| Bootcamp Status (enum) | §6.2 |
| Assisted Setup Wizard | §6.3 (page), §6.4 (codeunits), F-13 |
| No. Series (T308) + codeunit 310 | §6.5 |
| Customer (T18) | §6.5, Attendee `Customer No.` field |

No DEFINE entity is dropped. Deferred items from `GapAnalysis-PRE02.md` §6 (Currency, Payment
Method, Topic lookup, go/no-go automation, hard seat enforcement) remain deferred and are listed
in §1.3.

### 9.2 Every PRE-01 consumer use case is addressed

| Consumer (ProblemStatement §4) | Addressed by |
|---|---|
| Training coordinator / back-office staff | F-1…F-11, F-14 |
| Administrator / implementer | F-12, F-13 |
| External systems / middleware | F-15 (read/write) |
| BI / reporting | F-15 (read) |
| AI tooling | F-15 (read/write) |

### 9.3 Open questions from ProblemStatement §8 — resolved

| # | Question | Resolution (AJ, 2026-09-10) |
|---|---|---|
| 1 | Wizard discoverability | **Register in Assisted Setup** (Guided Experience), with completion state, re-runnable. F-13. |
| 2 | Bootcamp deletion behavior | **Block if attendees exist.** D-11, F-11, N-7. |
| 3 | Max Seats enforcement | **Warn but allow.** F-10. |
| 4 | Seats Remaining basis | Count of **all** attendee records for the bootcamp (attendees have no per-record status). D-8. |
| 5 | Amount Paid default | **Stored, seeded on insert, never auto-overwritten** — not a FlowField. D-9. |
| 6 | Role Center placement | **Business Manager Role Center** pageextension + Tell-Me. F-14. |
| 7 | Email field | Standard email datatype with entry validation; optional. D-13. |
| 8 | Target version | Build targets the supplied **BC v28.4** symbols; BC minimum 28.0.0.0. §4. |

### 9.4 No unverified platform assumptions

Every capability the FRD relies on is listed in §4 "Verified platform capabilities" with its
symbol-file object. Exact source-table numbers and `using` namespaces are re-verified per object
in Step 04.

---

**Exit gate (Step 02):** FRD + Dev Manager sign-off. Every DEFINE-phase entity accounted for
(§9.1). No unverified platform assumptions (§9.4).

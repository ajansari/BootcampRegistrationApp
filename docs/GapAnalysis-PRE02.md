# Structured Gap Analysis (PRE-02) — Bootcamp Registration Tracking

**Phase:** DEFINE · **Step:** PRE-02 · **Status:** Awaiting Technical Lead review
**Date:** 2026-09-10
**Inputs:** `docs/ProblemStatement.md`, initial entity list (§6 there), Standards §8 checklist.
**Symbol source:** BC v28.4 (`.alpackages/` — Base Application 28.4.53241, Business Foundation
28.4.53241, System Application 28.4.53241).

> This is the DEFINE-phase gap analysis (expanded entity list + gap log). It is **not**
> `docs/GapAnalysis.md`, which is the Step 08 as-built three-way comparison.

---

## 1. Transactional entities assessed

| Entity | Nature | Notes |
|---|---|---|
| **Bootcamp** | Master record with a lightweight lifecycle label. Not a posting document. | Parent of Attendee. |
| **Attendee** | Child record (registration) under a Bootcamp. Not a posting document line. | Payment/attendance fields are descriptive. |

No entity in this extension posts, generates ledger entries, or has an open→posted lifecycle.

## 2. Standards §8 checklist

### §8.1 Analytical detail tables (sub-ledgers, detailed ledger entries, value entries, registers, audit trails)
**Finding:** None applicable. Neither Bootcamp nor Attendee posts anything. "Paid", "Payment
Date", "Amount Paid" are descriptive fields the user maintains by hand; there is no payment
document, no G/L impact, and therefore no sub-ledger, value entry, register, or audit-trail
table to add.
**Resolution:** No analytical tables. Recorded as an explicit scope decision, not an oversight.
System-level change tracking (`Database Activity`/telemetry) is out of scope.

### §8.2 Posted / archived versions (posted equivalent of every open document — header and lines)
**Finding:** None applicable. A Bootcamp is not an open document; its Status
(Active/Inactive/Completed/Canceled) is a manual label with no posting step (ProblemStatement §3,
requirements §3). There is no "Posted Bootcamp" or "Posted Attendee", and no archive requirement.
**Resolution:** No posted or archive tables.

### §8.3 Reference / lookup tables (payment terms/methods, currencies, countries, UoM, locations, shipment methods, item categories, salesperson/purchaser codes)
| Candidate | Decision | Reason |
|---|---|---|
| **No. Series** (`table 308 "No. Series"`, namespace `Microsoft.Foundation.NoSeries`) | **ADD as reference.** The Setup table gets two `Code[20]` fields (`Bootcamp Nos.`, `Attendee Nos.`) with `TableRelation = "No. Series"`. Numbering uses `codeunit 310 "No. Series"` (`GetNextNo` / `TestManual` / `PeekNextNo`). | Numbering decision in ProblemStatement §7 requires it. Modern Business Foundation API — not the legacy `NoSeriesManagement` codeunit. |
| **Customer** (`table 18 Customer`, namespace `Microsoft.Sales.Customer`) | **ADD as reference (read).** Optional `Customer No.` `Code[20]` on Attendee, `TableRelation = Customer`. | ProblemStatement §7 — single optional Customer link. |
| **Currency** | **Deferred.** No `Currency Code` field. Price and Amount Paid are in local currency (LCY). | No multi-currency in requirements; no posting. Documented assumption. |
| **Payment Method / Payment Terms** | **Deferred.** No link from Attendee. | No posting, no invoice; "Paid" is a plain flag. Revisit only if payment integration is added later. |
| **Location** (`table 14 Location`) | **Do NOT link.** Bootcamp "Location" stays free text (`Text[100]`). | Standard `Location` is a warehouse/inventory location — wrong semantics for "the venue/city where the bootcamp is held". |
| **Bootcamp Topic lookup table** | **Deferred.** "Topic" stays free text (`Text[100]`). | Requirements treat topic as a free-form subject/title. An optional topic lookup for reporting consistency is noted as a future enhancement, not this build. |
| Countries, UoM, Shipment Methods, Item Categories, Salesperson/Purchaser | **N/A.** | No addresses, no items, no sales-rep concept in scope. |

### §8.4 Secondary document types (quotes, blanket orders, return orders alongside orders)
**Finding:** N/A. A Bootcamp is not an order and has no quote / blanket / return sibling. An
Attendee registration has no draft/quote analog.
**Resolution:** No secondary document types.

### §8.5 Modern vs. legacy tables
**Finding:** Clean.
- Customer link targets the modern `table 18 Customer` (not `Contact`, per AJ's decision).
- Bootcamp "Price" is a single decimal field on the Bootcamp record — **not** a price list;
  legacy `Sales Price` / modern `Price List Line` are not involved.
- Numbering uses the modern `Microsoft.Foundation.NoSeries` objects (T308/T309/Codeunit 310),
  not the obsolete `NoSeriesManagement` codeunit.
**Resolution:** No legacy tables referenced.

### §8.6 Tax framework tables (per target localization)
**Finding:** Localization is expected to be **W1** (to be confirmed in Step 01). Amount Paid is a
descriptive gross figure with no invoice, no VAT calculation, no posting.
**Resolution:** **No tax fields.** No VAT Bus./Prod. Posting Groups, no Tax Area Code, no Tax
Group. Recorded as an explicit decision. If a future build adds invoicing, tax scoping must be
redone against the then-current localization.

### §8.7 Global vs. localized scope
**Finding:** Every entity (Bootcamp, Attendee, Bootcamp Registration Setup, Bootcamp Status enum)
is **global** — no jurisdiction-specific entity or field. Consistent with W1.

## 3. Supporting / non-table gaps

| Gap | Decision |
|---|---|
| **Bootcamp Status** enum | Confirmed as a project enum: `Active`, `Inactive`, `Completed`, `Canceled`. Extensible = false unless a reason emerges. |
| **Seats Remaining** | Not a new table. FlowField on Bootcamp: `Max Seats` − `Count(Attendee WHERE "Bootcamp No." = Bootcamp."No.")`. Read-only by nature (see ProblemStatement §8 open Q5 — this one *is* a FlowField; the editable-with-default field is Attendee "Amount Paid"). |
| **Assisted Setup Wizard** | Guided page + a codeunit for "apply settings / create sample data". No table of its own; writes to Setup and inserts Bootcamp rows. Guided Experience registration = open question 1 (DESIGN). |
| **Sample data** | Created by the wizard's finish action via the same `Bootcamp` table — no seed table, no XML demodata package. |
| **No. Series seeding** | The wizard (or Setup page assist-edit) may create the two No. Series if they don't exist. To be specified in TDD. |

## 4. Expanded, de-duplicated entity list

| # | Entity | Tag | R/W intent | Global/Local | Source | Surfaces |
|---|---|---|---|---|---|---|
| 1 | **Bootcamp** | master | Read/Write | Global | New (this PTE) | List page, Card page, API page (v1.0, R/W) |
| 2 | **Attendee** | document (child of Bootcamp) | Read/Write | Global | New (this PTE) | List page + ListPart under Bootcamp card, API page (v1.0, R/W) |
| 3 | **Bootcamp Registration Setup** | setup (singleton) | Read/Write — **in-client only, no API** | Global | New (this PTE) | Setup page (+ assisted-setup action) |
| 4 | **Bootcamp Status** | enum (supporting) | n/a | Global | New (this PTE) | — |
| 5 | **Assisted Setup Wizard** | page + codeunit (no table) | n/a | Global | New (this PTE) | Guided page; launched from Setup page (and possibly Assisted Setup list — open Q1) |
| 6 | **No. Series** (T308) + No. Series Line (T309) + No. Series codeunit (Cod310) | lookup / reference | Read | Global | `Microsoft.Foundation.NoSeries` (Business Foundation) | TableRelation on Setup; numbering logic |
| 7 | **Customer** (T18) | lookup / reference | Read | Global | `Microsoft.Sales.Customer` (Base Application) | Optional TableRelation on Attendee |

De-duplication notes:
- "Attendee" and "Registration" in the requirements are the **same** entity → standardized to
  **Attendee**.
- The three linked-record fields implied by the requirements body (Contact / Customer / Vendor)
  collapse to **one** optional Customer link (AJ decision).
- "Relationship Type" option field — **removed** (AJ decision); not an entity or a field.

## 5. Gap log — what changed vs. the PRE-01 initial list

| Change | Type | Reason / §ref |
|---|---|---|
| Confirmed **no** analytical / ledger / register / audit tables | Explicit decision | §8.1 — payment tracking is descriptive |
| Confirmed **no** posted / archive tables | Explicit decision | §8.2 — no posting lifecycle |
| Confirmed **no** tax framework fields | Explicit decision | §8.6 — no invoicing, W1 |
| Added single-currency (LCY) assumption; **no** Currency Code field | Explicit decision | §8.3 |
| Bootcamp **Location** = free text, not linked to `Location` (T14) | Explicit decision | §8.3 — wrong semantics |
| Bootcamp **Topic** = free text; optional topic lookup table deferred | Deferred | §8.3/§8.5 |
| Payment Method / Payment Terms link on Attendee deferred | Deferred | §8.3 — no posting |
| No. Series (T308/T309) + No. Series codeunit (Cod310) added as reference; TableRelation on Setup | Added | §8.3 — numbering decision |
| Customer (T18) confirmed as the (only) link target; modern table, not Contact | Confirmed | §8.5 |
| "Attendee"/"Registration" de-duplicated to one entity | De-dup | naming |
| Setup table + Wizard explicitly marked **out of the API surface** | Scope clarification | ProblemStatement §3 |
| Seats Remaining confirmed as a FlowField (not a table, not an editable field) | Clarification | §3 above |

## 6. Deferred items (carried forward, with reasoning)

| Item | Deferred because | Revisit when |
|---|---|---|
| Currency Code on Bootcamp/Attendee | Single-currency customer, no posting | Multi-currency or invoicing is requested |
| Payment Method / Payment Terms on Attendee | No payment document in scope | Payment posting / AR integration is added |
| Bootcamp Topic lookup table | Requirements treat topic as free text | Reporting needs consistent topic values |
| Automatic go/no-go handling on Min Seats | Explicitly out of scope (requirements §3, §4) | Customer asks for automation |
| Max Seats enforcement on registration | Requirements silent; "no automated logic" tone | Confirmed in Step 02 (open Q3) |

---

**Exit gate (PRE-02):** Technical Lead reviews the expanded list; every gap is closed or
explicitly deferred with reasoning (Standards §2.2 Stage 2). The deferred items in §6 are the
complete deferral set.

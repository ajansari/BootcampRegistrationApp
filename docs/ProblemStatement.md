# Problem Statement — Bootcamp Registration Tracking (BC PTE)

**Phase:** DEFINE · **Step:** PRE-01 · **Status:** Awaiting Functional Consultant sign-off
**Date:** 2026-09-10
**Author:** Claude (agent), for AJ Ansari
**Source inputs:** `requirements/bootcamp-registration-extension-requirements.md`; clarifying decisions from AJ on 2026-09-10 (recorded in §7).

---

## 1. Business outcome required

The customer needs a single, structured place inside Business Central to run bootcamp training
events end to end:

1. **Set up a bootcamp** before anyone can register — capture what defines it (topic, location,
   date), what it costs and how big it is (price per attendee, maximum seats, minimum seats /
   go-no-go threshold), and a manually-controlled lifecycle status.
2. **Register attendees** against a bootcamp — capture their contact details and, optionally,
   link them to an existing Business Central customer.
3. **Track money and attendance per attendee** — whether payment was received, when, how much
   (defaulting to the bootcamp price but overridable), and whether the person attended.
4. **See where a bootcamp stands at a glance** — status and seats remaining.

Today none of this exists in BC for the customer; registrations, payment status, and attendance
are tracked outside the system or not at all.

## 2. Scope (in)

| Area | What is included |
|---|---|
| **Bootcamp master** | Create/edit/delete bootcamps. Fields: Topic, Location, Bootcamp Date (single day), Price, Max Seats, Min Seats (Go/No-Go), Seats Remaining (calculated), Status (Active / Inactive / Completed / Canceled — **manual only**). Bootcamp No. from a No. Series. |
| **Attendee (registration)** | One or more attendees per bootcamp. Fields: Name, Email Address, Phone Number, Company, optional Customer link, Paid (Yes/No), Payment Date, Amount Paid (defaults from bootcamp Price, editable), Attended (Yes/No). Attendee No. from a No. Series; carries the parent Bootcamp No. |
| **Setup** | A single-instance "Bootcamp Registration Setup" record holding the No. Series for Bootcamp and Attendee. |
| **Assisted Setup Wizard** | A guided page that configures the Bootcamp and Attendee No. Series and can optionally create one or two sample bootcamps so the feature is usable immediately. |
| **In-client UI** | List and card pages for Bootcamp; a list/subpage for Attendees; the Setup page; the wizard. Navigable from Tell-Me (search). |
| **API surface** | Read/write API (v1.0) pages for Bootcamp and Attendee, for external systems, BI, and AI tooling. |

## 3. Scope (out)

- Automatic status changes driven by the bootcamp date or any other business logic — status is
  entirely user-controlled.
- Check-in timestamps for attendance (attendance is a plain Yes/No).
- Multi-day / date-range bootcamps.
- The "Relationship Type" selector and links to **Contact** or **Vendor** — removed per AJ; only
  an optional **Customer** link remains, with no option-field selector.
- Configurable default values on the Setup table (default status, default seat counts, etc.) —
  deferred; not in this build.
- Any payment posting, invoicing, G/L / ledger-entry integration, or financial documents —
  "Paid / Payment Date / Amount Paid" are descriptive fields only.
- Waitlist, overbooking rules, or automatic go/no-go cancellation.
- API exposure of the Setup record or the wizard.

## 4. Target consumers

| Consumer | How they use it | Access |
|---|---|---|
| Training coordinator / back-office staff | Set up bootcamps, register attendees, mark paid/attended, watch seats remaining and go/no-go. | In-client list/card pages. |
| Administrator / implementer | Runs the Assisted Setup Wizard once to configure numbering and seed sample data. | Wizard + Setup page. |
| External systems / integration middleware | Push registrations in, pull bootcamp and attendee data out. | API v1.0 pages (read/write). |
| BI / reporting | Read bootcamp fill rates, revenue-paid, attendance. | API v1.0 pages (read). |
| AI tooling | Query and update bootcamp/attendee data conversationally. | API v1.0 pages. |

## 5. Domain vocabulary (design anchors)

- **Bootcamp** — a single one-day training event. The parent entity.
- **Attendee** / **Registration** — one person's registration against one bootcamp. The child
  entity. The requirements use both words for the same thing; the extension will standardize on
  **Attendee** for object/entity names.
- **Go/No-Go threshold** — the Min Seats value; the number of registrations at or above which
  the bootcamp is considered viable to run. Informational only — nothing is automated on it.
- **Seats Remaining** — Max Seats minus the current count of attendee records for that bootcamp.
- **Status** — Active / Inactive / Completed / Canceled. A manual label, not a state machine.
- **Bootcamp Registration Setup** — the singleton configuration record.
- **Paid / Amount Paid / Payment Date** — descriptive payment-tracking fields on the attendee,
  not linked to any posting routine.

## 6. Initial entity / object list (pre gap-analysis)

| # | Entity | Kind | R/W intent | Notes |
|---|---|---|---|---|
| 1 | Bootcamp | Master | Read/Write | Topic, Location, Date, Price, Max/Min Seats, Seats Remaining (calc), Status. No. Series key. |
| 2 | Attendee | Child of Bootcamp | Read/Write | Contact fields, optional Customer link, Paid/Payment Date/Amount Paid, Attended. No. Series key + Bootcamp No. |
| 3 | Bootcamp Registration Setup | Setup (singleton) | Read/Write (in-client only) | No. Series for Bootcamp and Attendee. |
| 4 | Bootcamp Status | Enum | — | Active / Inactive / Completed / Canceled. |
| 5 | Assisted Setup Wizard | Page (guided) | — | Configures No. Series; optional sample data. |
| 6 | Customer (standard, T18) | Lookup reference | Read | Optional link target on Attendee. |
| 7 | No. Series (standard) | Reference | Read | Numbering for entities 1 and 2. |
| 8 | Bootcamp list / card / API pages, Attendee list/part / API page, Setup page | Pages | — | Surface objects for entities 1–3. |

## 7. Clarifying decisions taken (AJ, 2026-09-10)

| Question | Decision |
|---|---|
| Requirements body shows a Relationship Type selector (None/Contact/Customer/Vendor) + linked record; header note says these were removed. Which governs? | **Single optional Customer link, no selector.** Drop the Relationship Type option field and the Contact/Vendor links. |
| Consumer surface — in-client only, or also API pages? | **In-client + API pages.** Read/write API v1.0 for Bootcamp and Attendee. |
| What does the Assisted Setup Wizard configure? | **No. Series for Bootcamp & Attendee**, and **optionally create sample bootcamp data**. Not configurable defaults; not (explicitly) formal Guided Experience registration. |
| How are Bootcamp and Attendee identified? | **Both use No. Series** (code keys), configured in Setup. Attendee also carries the parent Bootcamp No. |

## 8. Open questions — to resolve during DESIGN (do not block PRE-02)

1. **Wizard discoverability.** AJ did not select formal registration in the Guided Experience /
   Assisted Setup list. Recommendation: register it anyway (with a completion flag) so it is
   discoverable and re-runnable; otherwise it is only reachable via an action on the Setup page.
   Needs a decision in Step 02/03.
2. **Bootcamp deletion behavior** when attendees exist — block, or cascade-delete the attendees?
   To be decided explicitly in Step 04 (Sanity Check) per runbook.
3. **Max Seats enforcement.** Requirements are silent on whether registering past Max Seats is
   blocked or merely reflected in a negative Seats Remaining. Default assumption: **not
   enforced** (Seats Remaining can go negative / zero), consistent with the "no automated logic"
   tone. Confirm in Step 02.
4. **Seats Remaining basis.** Attendees have no per-attendee status, so Seats Remaining = Max
   Seats − count of all attendee records for the bootcamp. Confirm no exclusion is wanted.
5. **Amount Paid default.** Defaults from bootcamp Price on attendee insert; must not overwrite a
   value the user already typed. Confirm this is a stored, seeded field (not a FlowField).
6. **Role Center placement.** Whether to surface the bootcamp list / wizard on an existing Role
   Center (e.g. Business Manager) or rely on Tell-Me only. Default: Tell-Me only for this build.
7. **Email field.** Use the BC email field pattern with format validation, or plain text.
   Default: validated email.
8. **Target version.** Requirements say "27.5 or newer"; the supplied symbols and `app.json`
   target BC 28.4 (`application 28.0.0.0`, runtime 17.0). Build will target the symbol version.

---

**Exit gate (PRE-01):** Functional Consultant sign-off on this problem statement and the initial
entity list (Standards §2.2 Stage 1).

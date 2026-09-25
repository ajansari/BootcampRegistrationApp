# Roadmap — Bootcamp Registration Tracking (BC PTE)

Items explicitly scheduled for later rather than fixed now, per the Testing Feedback Log and
Gap-Fit Test triage conventions (ALL ALONG). Each item names when it was scheduled, why, and
what would trigger picking it up.

---

## R-1 · No upgrade codeunit exists

**Scheduled:** 2026-09-13, Step 08 Gap-Fit Test (`docs/GapAnalysis.md` G-06).

**What:** `ocpfBootcampRegInstall.RegisterAssistedSetup` only runs from
`OnInstallAppPerCompany`. Install triggers do not run when an already-installed PTE is
republished at a new version, so any future change to the wizard's Assisted Setup registration
(its title, description, or a new object ID) will never reach a tenant that already has the app
installed.

**Why deferred, not fixed now:** impact today is nil — the registration already happened once
and is guarded by `IsAssistedSetupComplete`, so nothing is currently broken. It only becomes real
the first time the wizard's registration itself changes.

**Trigger to revisit:** the moment any change is made to `RegisterAssistedSetup`'s parameters
(title, description, object ID) or a new Guided Experience entry is added — add an upgrade
codeunit at that point (or explicitly re-confirm "still not needed" and update this entry) rather
than assuming the install-time registration will silently propagate.

**Decision needed before 1.0.0.0:** either add the upgrade codeunit pre-emptively, or record
explicitly that it's accepted as unnecessary pre-1.0 and revisit at the 1.0.0.0 baseline
(`PostDevTDD.md`, Step 11).

**Added dimension (2026-09-13, Step 09 Code Review, `docs/CodeReview.md` BP-8):** the same gap
also affects a **new company** created in an existing tenant *after* this extension is already
installed — `OnInstallAppPerCompany` never re-runs for it, so it won't see the wizard in its
Assisted Setup list either. Confirmed via BC v28.4 symbols: `Guided Experience Item` (table 1990)
has no `DataPerCompany = false`, i.e. it's company-scoped. Same trigger to revisit applies.

---

## R-2 · `Confirm()` (overbooking prompt) runs inside the Attendee insert transaction

**Scheduled:** 2026-09-13, Step 09 Code Review (`docs/CodeReview.md` BP-6).

**What:** `ocpfAttendee.OnInsert` → `ConfirmOverbookingIfNeeded` raises a `Confirm()` dialog from
inside the table's write transaction (guarded by `GuiAllowed()`, so the API path is unaffected).
Knowledge-backed (BCQuality `performance/avoid-user-prompts-inside-transactions.md`): a `Confirm`
issued from inside a write transaction stalls the transaction — and every lock it holds — until
the user responds.

**Why deferred, not fixed now:** at this app's concurrency profile (a training-bootcamp roster,
not a high-throughput ledger), the practical blast radius is small. Restructuring to prompt
before the transaction opens would mean moving the seat-count check out of the table trigger
entirely — a bigger change than the risk currently justifies.

**Trigger to revisit:** if this extension is ever deployed somewhere attendees are registered
concurrently at real volume (e.g., a public self-registration form hitting the API — which
bypasses this prompt anyway via `GuiAllowed()` — or many staff registering simultaneously against
the same popular bootcamp).

---

## R-3 · Separate attendee entities from bootcamp registrations and add billing

**Current state:** there is no standalone Attendee entity today. The current `ocpfAttendee`
table represents a bootcamp attendee registration: each record is required to have a `Bootcamp
No.` and stores registration-level details such as payment and attendance.

**Future direction:** introduce an Attendee entity that can be associated with one or more
bootcamps. One or more attendees should be able to relate to a Customer, allowing the customer
to be billed for their attendees. Add functionality to invoice attendees through their related
customer and issue credit memos when needed.

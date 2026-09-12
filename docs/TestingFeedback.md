# Testing Feedback — Bootcamp Registration Tracking (BC PTE)

Raw record of what was tested and what the tester found, **verbatim**, before triage. Triage
decisions (ChangeLog Issue, Roadmap item, or rejected) are cross-referenced below once made — see
`ChangeLog.md` and `Roadmap.md`.

---

## Session 2026-09-12 — AJ Ansari, manual testing on v0.0.2.0

**What was tested:** Assisted Setup Wizard (sample-data option); manually creating a new
Bootcamp and adding an Attendee line via the Card's embedded subform.

**Findings, verbatim:**

> "When I go through the Bootcamp Assisted Setup Wizard, there is an option to create two sample
> bootcamps. When I choose that, it errors out because it says a record already exists in that
> table (with the first available number on the Bootcamp no. series)."

> "When I manually create a new bootcamp and then try to add a line, it tells me 'the view is
> filtered, and the entry is outside the filter.'"

**Triage status:** Not yet triaged — clarifying questions asked back to AJ (see chat) before a
root-cause diagnosis is proposed, per Step 07's "ask the three questions" discipline. No
ChangeLog Issue opened yet; will be opened once the mechanism is confirmed rather than guessed.

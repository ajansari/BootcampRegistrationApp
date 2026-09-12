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

**Triage status:** Both triaged 2026-09-12, after two rounds of clarifying answers from AJ.

- **Sample-bootcamp "already exists"** → **Oversight, fixed — initial triage (BUILD-11) was
  wrong.** First read: leftover data from before a series reset (No code change). AJ then
  proved that wrong — confirmed an empty `ocpfBootcamp` table AND a brand-new No. Series
  reproduced the identical error on its first-ever use. Revised diagnosis: both sample-bootcamp
  inserts were computing the same number, the second collided, and the resulting error rolled
  back the whole operation (explaining "table now empty" + "already exists" together). Fixed by
  making `InitBootcampNo`/`InitAttendeeNo` self-healing — skip forward past any number that's
  already taken. See ChangeLog BUILD-11 (superseded) and BUILD-13 (corrected + fixed).
- **Attendee line gets blank Bootcamp No. / "view is filtered"** → **Oversight, fixed.**
  AJ confirmed the header was filled in properly and the attendee record was created with a
  blank `"Bootcamp No."` — pinpointing a `SubPageLink` auto-propagation timing gap. Fixed with a
  defensive `OnNewRecord` trigger on `ocpfAttendeeSubform`. See ChangeLog BUILD-12.

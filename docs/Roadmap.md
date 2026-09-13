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

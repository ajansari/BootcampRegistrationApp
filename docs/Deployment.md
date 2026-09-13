# Deployment — Bootcamp Registration Tracking

**Audience:** the administrator installing, upgrading, or removing this extension.
**Date:** 2026-09-13.

> This is the full install/upgrade/uninstall procedure. For a fast first API call instead, see
> `Documentation.md` §2 (Quick start).

## 1. Version requirements

| Requirement | Value |
|---|---|
| Deployment model | SaaS per-tenant extension (PTE) |
| BC application minimum | `28.0.0.0` |
| Recommended / validation target | BC `28.4` or newer |
| AL runtime | `17.0` |
| Dependencies | Base Application, System Application, Business Foundation (`No. Series`) — all satisfied by a standard BC 28.4+ online tenant. No third-party dependencies. |
| Localization | NA — no country-specific or tax fields; effectively world-wide |

## 2. Install procedure

1. Obtain the package: `outputAppPackage/Bootcamp_Registration_Tracking_<version>.app` — the
   specific version that passed Step 12's release test is the one to deploy (check
   `docs/ReleaseTestResults.md` for which build that was).
2. In Business Central, go to **Extension Management** (search Tell Me).
3. Click **Upload Extension**, select the `.app` file.
4. **Schema Sync Mode:** for a first install this is irrelevant (nothing exists yet to sync
   against). For every *subsequent* upgrade, check the current build's Schema Sync Mode note in
   `docs/ChangeLog.md` before uploading — an additive-only build (new fields/tables, code-only
   changes) uses the default **Add** mode; a build that removed, shrank, retyped, or re-keyed
   anything needs **Force Sync**, which can lose data and should be tested in a sandbox first.
5. Confirm the install. On first install per company, the extension automatically:
   - creates the singleton Bootcamp Registration Setup record;
   - registers **"Set up Bootcamp Registration Tracking"** in the standard Assisted Setup list.
6. Run the Assisted Setup wizard once per company (see `UserGuide.md` §2) before staff start
   using the feature — it configures the two number series bootcamps and attendees are numbered
   from.

## 3. Upgrade procedure

1. Obtain the new `.app` package. **Never delete the previous version's package** — every build
   lives permanently in `outputAppPackage/` under its own version-numbered filename.
2. Check `docs/ChangeLog.md` for that build's Schema Sync Mode note (step 2.4 above) before
   uploading.
3. Upload via **Extension Management** the same way as a first install; Business Central handles
   the in-place upgrade.
4. No manual data migration is needed for any release through `0.0.5.1` — every change so far has
   been additive or behavior-only.

## 4. Permission sets → roles

| Permission set | Grants | Assign to |
|---|---|---|
| `OCPF - Bootcamp Read` | Read on all 3 tables this extension owns (Bootcamp, Attendee, Bootcamp Registration Setup), plus execute on all 8 of its own pages | Anyone who needs to view bootcamps/attendees or see the Role Center Activity Cues, but not create/edit — e.g. an auditor or a manager who only reviews |
| `OCPF - Bootcamp Edit` | Everything in `OCPF - Bootcamp Read`, plus insert/modify/delete on all 3 tables | Training coordinators and back-office staff who create and maintain bootcamps and registrations — the normal day-to-day user |

Consumers also need the standard BC base access every user already has for their own license
type (e.g. `D365 BUS FULL ACCESS` or `D365 BASIC`) and read access to **Customer** (table 18) if
they'll use the optional Customer link on an attendee, and to **No. Series** (table 308), which
BC's own standard permission sets already cover for most users.

Neither OCPF permission set is assigned automatically on install — assign them explicitly to
each user or user group that needs this feature (**Permission Sets** in BC, or via a Security
Group).

## 5. Verification steps (after install or upgrade)

1. Confirm the extension shows as **Installed** in Extension Management, at the expected
   version.
2. Confirm **"Set up Bootcamp Registration Tracking"** appears in Assisted Setup and is
   completable.
3. As a user assigned `OCPF - Bootcamp Edit`, create a test bootcamp and register a test
   attendee — confirm Seats Remaining and Registered Attendees update.
4. As a user assigned only `OCPF - Bootcamp Read`, confirm every page opens read-only and the
   Role Center Activity Cues are visible; as a user with **neither** OCPF set, confirm the Cues
   are hidden and no error appears. (This is `HumanUnitTestScript.md` Part C — the one item not
   yet confirmed live as of `0.0.5.1`; treat it as a required verification step on every
   environment this extension is deployed to, not a one-time check.)
5. Spot-check the API: `GET .../ocpfBootcamps` returns the test bootcamp created in step 3.

## 6. Uninstall

1. In **Extension Management**, select the extension and choose **Uninstall**.
2. The platform removes the Guided Experience (Assisted Setup) item this extension registered,
   by AppId, automatically. **Not yet independently confirmed on a live tenant** — a named test
   case (`PostDevTDD.md` §3.13 / §11). If, after uninstall, the "Set up Bootcamp Registration
   Tracking" entry is still visible in Assisted Setup, report it — that would mean an explicit
   `OnUninstall` cleanup needs adding in a future build.
3. Uninstalling removes this extension's own tables (Bootcamp, Attendee, Bootcamp Registration
   Setup) and all data in them. There is no archive/export step built into the extension itself
   — export anything you need to keep (e.g. via the API, or Excel) before uninstalling.
4. Uninstalling does **not** affect any standard BC data this extension only referenced
   (Customers, No. Series) or extended additively (the Business Manager Role Center, the
   Activities Cue table, the O365 Activities page) — those simply lose the fields/actions this
   extension added.

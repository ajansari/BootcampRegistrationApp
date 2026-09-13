# Human Unit Test Script — Bootcamp Registration Tracking

**Phase:** PROVE · **Step:** 11 · **Executed by:** a person, not the agent
**Date written:** 2026-09-13 · **Package under test:** `outputAppPackage/Bootcamp_Registration_Tracking_0.0.5.1.app`

> Written for anyone testing this extension — no AL or development background assumed. Follow
> the steps in order; each one names exactly what to do and exactly what you should see. This is
> the script Step 12 (Release to Users for Testing) runs as the authoritative pass — an earlier,
> optional agent-run version of Part B's API checks may already have happened at Step 07, but
> that does not replace running this script by hand.
>
> **Setup assumed before you start:** the extension is published to a sandbox company, you're
> signed in as a user with `OCPF - Bootcamp Edit` (or SUPER, for the parts of this script that
> intentionally test a more restricted user — Part C), and you have run the Assisted Setup Wizard
> at least once (Test 1 below covers this from scratch).

---

## Part A — In-client walkthrough (happy path)

### A1. First-run setup (F-12, F-13)

1. Search (Tell Me, 🔍) for **"Bootcamp Registration Setup"** and open it.
   **Expect:** a page with two fields, "Bootcamp Nos." and "Attendee Nos.", both blank on a
   brand-new company.
2. Instead, search for **"Assisted Setup"** and open the standard Assisted Setup list.
   **Expect:** an entry titled **"Set up Bootcamp Registration Tracking"** is listed and not
   marked complete.
3. Open it. Click through: Welcome → Numbering → Sample data → Finish.
   - On the Numbering step, if either series field is blank, accept the offer to create a
     default series.
   - On the Sample data step, check the box to create sample bootcamps.
4. Click **Finish**.
   **Expect:** no error. Re-opening the Assisted Setup list now shows this item as complete.
   Re-running it is allowed (it doesn't fail or duplicate the series).
5. Open **Bootcamps** (search Tell Me, or the Business Manager Role Center's new "Bootcamps"
   section — see A5). **Expect:** two sample bootcamp records exist, each with a unique number,
   a future date roughly 30/60 days out, Price 1500, Max Seats 20, Min Seats 6.

### A2. Create a bootcamp and register an attendee (F-1, F-2, F-5, F-6, F-8)

1. Open **Bootcamps**, click **New**.
2. Enter: Topic = "Test Bootcamp", Bootcamp Date = any future date, Price = 1000,
   Max Seats = 5, Min Seats = 2. Leave Status at its default.
   **Expect:** a `No.` is assigned automatically once you leave the first field. Status shows
   "Active". Seats Remaining shows 5 (Max Seats, since no attendees exist yet).
3. Open the bootcamp's card. In the **Attendees** subpage at the bottom, click into a new line
   and enter a Name and Email Address.
   **Expect:** you do **not** need to type the Bootcamp No. yourself — it's already correctly
   set to this bootcamp (hidden on this subpage, but present). **Amount Paid is automatically
   set to 1000** (the bootcamp's Price) the moment the line is created.
4. Save (click out of the line, or close and reopen the card).
   **Expect:** back on the bootcamp card, **Registered Attendees** shows 1 and **Seats
   Remaining** shows 4.

### A3. Comp a registration (F-8 — the specific fix this behavior received)

1. On the same bootcamp, add a second attendee line. Before saving, change **Amount Paid**
   from the auto-filled 1000 to **0**.
2. Save, then close and reopen the card (forces a full refresh).
   **Expect:** Amount Paid still shows **0** for this attendee — it must **not** revert back to
   1000. This is the specific behavior fixed at Step 09 (BP-1): an explicit 0 is a genuine
   comp, and is never silently re-billed.

### A4. Max Seats warning (F-10) and blocked delete (F-11)

1. On "Test Bootcamp" (Max Seats = 5, 2 registered so far), add attendees until you have 5
   registered — no warning should appear yet.
2. Add a 6th attendee.
   **Expect:** a confirmation dialog appears, naming the bootcamp and saying it's full. Click
   **Yes**. **Expect:** the attendee is still created (overbooking is allowed, only warned
   about) and Seats Remaining now shows **-1** — a real, positive Max Seats can go negative once
   exceeded; only a Max Seats of exactly 0 clamps to 0 instead (see A6).
3. Try to delete "Test Bootcamp" from the Bootcamp list (select it, click Delete).
   **Expect:** deletion is refused with a message naming the bootcamp and telling you to delete
   its registrations first — not a raw, confusing platform error.
4. Delete all of "Test Bootcamp"'s attendees from its Attendees subpage, then delete the
   bootcamp again. **Expect:** it deletes cleanly this time.

### A5. Role Center Activity Cues (F-16)

1. Go to the **Business Manager Role Center** (or switch your role to it).
   **Expect:** a "Bootcamps" cue group is visible with five tiles: Active Bootcamps, Unpaid
   Registrations, Below Min Seats (Go/No-Go), Registrations This Month, Bootcamp Revenue This
   Month.
2. Click the **Active Bootcamps** tile. **Expect:** it opens the Bootcamp list, filtered to
   Active bootcamps only.
3. Click the **Unpaid Registrations** tile. **Expect:** it opens the Attendee list, filtered to
   unpaid registrations.
4. In the same Role Center's navigation, confirm a **"Bootcamps"** section exists with links to
   Bootcamps, Bootcamp Attendees, and Bootcamp Registration Setup.

### A6. No-cap bootcamp (F-10's "0 means unlimited" rule, and the Step 09 clamp fix)

1. Create a new bootcamp with **Max Seats = 0**.
   **Expect:** Seats Remaining shows **0**, not a negative number, even before any attendee is
   registered.
2. Register 3 attendees against it.
   **Expect:** no overbooking warning ever appears (0 = no cap), and Seats Remaining still
   shows **0** throughout — never negative.

---

## Part B — API tests (endpoint by endpoint)

Use Postman, or any HTTP client. Get a bearer token per `Documentation.md` §2.1 before starting.
Replace `{base}` below with the full URL prefix from `Documentation.md` §2.2 up through
`companies({companyId})`.

### Green-team (happy path)

| # | Test | Expected result |
|---|---|---|
| B1 | `GET {base}/$metadata` | `200 OK`, XML listing `ocpfBootcamps` and `ocpfAttendees` entity sets with their fields |
| B2 | `GET {base}/ocpfBootcamps` | `200 OK`, a `value` array of bootcamps (includes the sample data from A1 if not deleted) |
| B3 | `GET {base}/ocpfBootcamps(<systemId>)` (use a `systemId` from B2) | `200 OK`, a single bootcamp object |
| B4 | `POST {base}/ocpfBootcamps` with `{"topic": "API Test Bootcamp", "bootcampDate": "<future date>", "price": 500, "maxSeats": 10, "minSeats": 2}` | `201 Created`, response includes an assigned `number` and `systemId` |
| B5 | `PATCH {base}/ocpfBootcamps(<systemId from B4>)` with `{"price": 600}`, header `If-Match: *` | `200 OK`, `price` now `600` |
| B6 | `POST {base}/ocpfAttendees` with `{"bootcampNo": "<number from B4>", "name": "API Attendee"}` | `201 Created`, `amountPaid` in the response is `600` (seeded from the bootcamp's updated price) |

### Red-team (boundary — each must fail *gracefully*, not crash or hang)

| # | Test | Expected result |
|---|---|---|
| B7 | `PATCH {base}/ocpfBootcamps(<systemId>)` with `{"seatsRemaining": 999}` | `400 Bad Request` naming the field as not editable — not a 500 error |
| B8 | `PATCH {base}/ocpfBootcamps(<systemId>)` with `{"notAField": 1}` | `400 Bad Request`, a clear "unknown property" style message |
| B9 | `GET {base}/ocpfBootcamps(00000000-0000-0000-0000-000000000000)` (a key that doesn't exist) | `404 Not Found`, not an unhandled exception |
| B10 | `DELETE {base}/ocpfBootcamps(<systemId from B4>)` — first `POST` an attendee against it if none exists | error message naming the bootcamp and telling you to remove registrations first (matches Part A4's in-client message) |
| B11 | Repeat B2 using a token for a user with **no** OCPF permission set assigned | `403 Forbidden`, not a silently empty result |

---

## Part C — Permission verification (Standards §7.3 — named Step 12 test case)

**This is the one item still explicitly unverified live as of `0.0.5.1` — see
`docs/ProjectMemory.md` Open Decisions.**

1. Create (or use) a test user assigned **only** `OCPF - Bootcamp Read` — not SUPER, and no
   other permission set that happens to grant broader access.
2. Signed in as that user, confirm each of the following **opens without a permission error**:
   Bootcamp Registration Setup, Bootcamp List, Bootcamp Card, Attendee List, the Attendee
   subpage on a Bootcamp Card, the Assisted Setup Wizard, and both API entity sets (read-only
   calls).
3. Still as that user, confirm the Business Manager Role Center's Activity Cues (A5) are
   **visible** (this user *does* have the Read set).
4. Now test the opposite: sign in as a user with **neither** OCPF permission set assigned.
   **Expect:** the Activity Cues cue group does not appear at all on the Role Center, and no
   error surfaces — it should render as if the section didn't exist.
5. Record the actual result of steps 2–4 in `docs/ReleaseTestResults.md` (Step 12) either way.

---

## Result log

Record results here as each part is run — date, tester, pass/fail per numbered test, and a link
to any `ChangeLog.md` Issue a failure produces (per the Testing Feedback Log discipline).

| Date | Tester | Part(s) run | Result | Notes / ChangeLog link |
|---|---|---|---|---|
| | | | | |

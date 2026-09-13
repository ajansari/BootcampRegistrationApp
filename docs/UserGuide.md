# User Guide — Bootcamp Registration Tracking

**Audience:** training coordinators and back-office staff using this feature inside Business
Central. **Date:** 2026-09-13.

> Looking for the API reference instead? See `Documentation.md`. Setting the extension up as an
> administrator? See `Deployment.md`.

---

## 1. What this feature is for

Bootcamp Registration Tracking gives you one place, inside Business Central, to:

- keep a list of your bootcamps (one-day training events) — topic, venue, date, price, and how
  many seats they have;
- register attendees against a bootcamp and keep their contact details;
- track whether each attendee has paid, how much, and whether they showed up;
- see at a glance how full each bootcamp is, and whether it has enough registrations to be worth
  running.

It does **not** post anything to your books — Paid, Payment Date, and Amount Paid are
descriptive tracking fields only, not an invoice or a G/L entry. If you need to actually bill an
attendee, do that separately in the normal way (a sales invoice, etc.) and just record the result
here.

## 2. First-time setup

The first time this feature is used in a company, someone needs to run the **Assisted Setup**
wizard once:

1. Search (the 🔍 **Tell Me** box) for **"Assisted Setup"**.
2. Find **"Set up Bootcamp Registration Tracking"** and open it.
3. **Numbering step** — choose (or let the wizard create) the number series bootcamps and
   attendees will be numbered from. If you're not sure, accept the suggested default.
4. **Sample data step** — check the box if you'd like two example bootcamps created so you can
   see how the feature looks with real data in it. Uncheck it if you'd rather start from a clean
   slate.
5. Click **Finish**.

You can re-run this wizard later (e.g. from the Bootcamp Registration Setup page's **Assisted
Setup** action) if you ever need to change the number series — it won't create duplicates or
break anything already registered.

## 3. Setting up a bootcamp

1. Search for **"Bootcamps"** and open the list.
2. Click **New**.
3. Fill in:
   - **Topic** — what the bootcamp is about.
   - **Location** — the venue or city. This is a free-text field; it isn't tied to a warehouse
     or shipping location elsewhere in Business Central.
   - **Bootcamp Date** — the single day it runs. (Multi-day bootcamps aren't supported yet —
     if you need that, use Location or Topic to note it for now.)
   - **Price** — the standard price per attendee. This becomes each new attendee's default
     Amount Paid — see §5.
   - **Max Seats** — how many people the bootcamp can hold. **Enter 0 if there's no limit** —
     see §6 for what that changes.
   - **Min Seats (Go/No-Go)** — the minimum number of registrations you need before the
     bootcamp is worth running. This is purely informational: nothing is blocked or cancelled
     automatically if you're under it — it's there so you can decide.
   - **Status** — starts at **Active**. Change it yourself as the bootcamp progresses
     (Completed, Canceled, Inactive) — nothing changes it for you automatically, including on
     the bootcamp's own date passing.
4. Once saved, the bootcamp gets a number automatically. You'll also see two fields you never
   fill in yourself:
   - **Registered Attendees** — a live count of how many people are registered.
   - **Seats Remaining** — Max Seats minus Registered Attendees, kept up to date automatically
     as people register, are removed, or move between bootcamps.

### Deleting a bootcamp

You can delete a bootcamp only while it has **no** attendees registered against it. If you try to
delete one that still has registrations, you'll see a message telling you so — remove the
attendee registrations first (from the bootcamp's own Attendees list, below), then delete the
bootcamp.

## 4. Registering an attendee

You can do this two ways — they behave identically:

- **From the bootcamp itself:** open the bootcamp's card. Scroll to the **Attendees** section at
  the bottom and add a new line directly.
- **From the standalone Attendee list:** search for **"Attendees"**, click **New**, and pick the
  bootcamp from the **Bootcamp No.** column.

Either way, fill in the attendee's **Name**, **Email Address**, **Phone Number**, and
**Company** as you have them. **Customer No.** is optional — link it only if this attendee is
also an existing Business Central customer (or represents one); it's just a reference, nothing is
copied from the customer record.

**Amount Paid fills in automatically** the moment you pick the bootcamp, using that bootcamp's
Price. You can change it — for example, if you're giving someone a discount, or comping their
seat entirely by entering **0**. Once you've entered a value (including an explicit 0), it stays
exactly as you left it — it will not silently reset to the bootcamp's price later, even if you
reopen the record. The one case where it *will* refill: if you later change **which bootcamp**
this same attendee is registered for while Amount Paid is still sitting at 0.

## 5. Tracking payment and attendance

Two independent checkboxes per attendee:

- **Paid** — check it once payment is received. **Payment Date** is a plain date field next to
  it, not automatically validated against the checkbox — fill it in yourself when relevant.
- **Attended** — check it after the bootcamp, for anyone who actually showed up. There's no
  check-in timestamp, just yes/no.

## 6. Registering past capacity (overbooking)

If a bootcamp's Max Seats is a real number (not 0) and you try to register one attendee too many,
you'll see a confirmation message telling you the bootcamp is full and asking whether to proceed
anyway. This is a warning, not a hard stop — click **Yes** to register the person anyway (Seats
Remaining will go negative, which is expected and just means "over capacity"), or **No** to
cancel that registration.

**Setting Max Seats to 0 means "no limit"** — you will never see this warning, and Seats
Remaining will always show 0 rather than a negative number, no matter how many people register.

## 7. The Role Center dashboard

If your role is (or includes) the Business Manager Role Center, you'll see a **Bootcamps**
section added to its navigation, and five at-a-glance tiles:

| Tile | Shows | Clicking it opens |
|---|---|---|
| Active Bootcamps | Count of bootcamps currently marked Active | The Bootcamp list, filtered to Active |
| Unpaid Registrations | Count of attendee registrations not yet marked Paid | The Attendee list, filtered to unpaid |
| Below Min Seats (Go/No-Go) | Count of Active bootcamps under their own Min Seats threshold | The Bootcamp list, filtered to Active |
| Registrations This Month | Count of attendees registered so far this calendar month | The Attendee list |
| Bootcamp Revenue This Month | Total Amount Paid across attendees marked Paid with a Payment Date this month | The Attendee list |

If these tiles don't appear for you at all, you likely don't have the permission set this
feature needs assigned — see your administrator (`Deployment.md` §4).

## 8. When something is refused

| What happened | Why | What to do |
|---|---|---|
| "You cannot delete bootcamp … because attendee registrations exist for it." | The bootcamp still has attendees | Remove its registrations first, then delete it |
| "Bootcamp %1 is full (… of … seats used). Register … anyway?" | You're registering past Max Seats | This is a warning, not a block — choose Yes to proceed or No to cancel |
| A red error on Bootcamp No. when saving an attendee | Every attendee must belong to a bootcamp | Pick a bootcamp before saving |
| "The email address "…" is not valid…" | The Email Address doesn't look like a real email | Fix the format, or leave the field blank — it's optional |
| Amount Paid changed back to the bootcamp's price unexpectedly | You changed which bootcamp the attendee belongs to while Amount Paid was still 0 | Re-enter the intended amount after picking the final bootcamp |
| The Bootcamps section/tiles don't appear at all | Your user isn't assigned an OCPF permission set | Ask your administrator to assign `OCPF - Bootcamp Read` or `OCPF - Bootcamp Edit` |

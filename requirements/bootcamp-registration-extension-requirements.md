# Business Central Extension — Bootcamp Registration Tracking

> **Pre-BUILD source.** Current functional baseline: [docs/FRD.md](../docs/FRD.md) (re-baselined after 1.0.0.5; Relationship Type / Contact / Vendor removed per AJ). Do not use this file as the live “what should the app do.”

**Type:** Per-Tenant Extension (PTE)
**Target Version:** Business Central 27.5 or newer

## Executive Summary

The customer is requesting a per-tenant extension for Business Central, targeting version 27.5 or newer, to manage the setup and registration process for bootcamp training events. Today there is no structured way within Business Central to record which bootcamps are being offered, who has registered for them, or whether those registrations have been paid for and attended. This extension is intended to close that gap by giving the customer a single place to manage bootcamps from creation through completion, and to manage the attendees who register for each one.

At the core of the solution is the bootcamp itself. Each bootcamp needs to be set up before anyone can register for it, and needs to carry the essential details that define it: the topic being taught, the location where it will be held, and the date it takes place, since these are understood to be one-day events rather than multi-day programs. Financially and operationally, each bootcamp also needs a price per attendee, a maximum number of seats that can be filled, and a minimum number of registrations required for the bootcamp to be considered viable, sometimes referred to as the go or no-go threshold. To help staff track where a bootcamp stands at a glance, each one also carries a status of active, inactive, completed, or canceled, which is expected to be set manually by the user rather than driven by any automated business logic tied to the bootcamp date.

Once a bootcamp exists, the extension needs to support registering one or more attendees against it. For each attendee, the customer wants to capture basic contact information, including name, email address, phone number, and company. Beyond that, there is a need to optionally connect an attendee to an existing Business Central record, whether that is a contact, a customer, or a vendor. Rather than exposing three separate fields for this, the customer wants a single relationship type selection of none, contact, customer, or vendor, with the appropriate lookup field then appearing based on that choice. Finally, each attendee registration needs to track whether payment has been received, the date that payment was made, and the amount actually paid, which should default to the bootcamp's standard price but remain editable in case an individual attendee's payment differs from the standard rate. Attendance itself is tracked as a simple yes-or-no indicator, without the need for a check-in timestamp.

This document is intended as a loose requirements statement reflecting the conversation with the customer, and is meant to serve as the starting point for functional design and AL development rather than as a fully detailed functional specification.

---

## 1. Bootcamp

A bootcamp represents a single, one-day training event.

| Field | Description |
|---|---|
| Topic | The subject/title of the bootcamp |
| Location | Where the bootcamp is held |
| Bootcamp Date | Single date field (no separate start/end — bootcamps are one-day events) |
| Price | Standard price per attendee |
| Max Seats | Maximum number of attendees allowed |
| Min Seats (Go/No-Go) | Minimum number of registrations required for the bootcamp to run |
| Seats Remaining | Calculated field — Max Seats minus current attendee count |
| Status | Option field: **Active**, **Inactive**, **Completed**, **Canceled** — fully manual, no automatic status changes based on date or other logic |

---

## 2. Attendee (Registration)

Each bootcamp can have one or more attendees registered against it.

| Field | Description |
|---|---|
| Name | Attendee's full name |
| Email Address | Attendee's email |
| Phone Number | Attendee's phone number |
| Company | Attendee's company name |
| Relationship Type | Option field: **None**, **Contact**, **Customer**, **Vendor** |
| Linked Record | The specific Contact, Customer, or Vendor record — the correct field becomes visible/enabled based on the selected Relationship Type |
| Paid | Yes/No flag |
| Payment Date | Date the payment was received |
| Amount Paid | Defaults to the bootcamp's Price, but can be manually overridden by the user |
| Attended | Yes/No flag (no check-in timestamp required) |

---

## 3. Notes / Scope Decisions

- Bootcamps are one-day events — no start/end date range needed.
- Seats Remaining is calculated, not manually entered.
- Status transitions (e.g., preventing "Completed" before the bootcamp date) are **not** enforced — status is fully user-controlled.
- Attendance is a simple Yes/No checkbox — no check-in timestamp.
- The Relationship Type field drives which linked record field is shown, avoiding three separate always-visible link fields.

---

## 4. Out of Scope (for now)

- Automatic status changes based on bootcamp date
- Check-in timestamps for attendance
- Multi-day bootcamp support

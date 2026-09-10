# Project Parameters — Bootcamp Registration Tracking (BC PTE)

**Phase:** DEFINE · **Step:** 01 — Populate the Intake Sheet · **Status:** Awaiting human confirmation
**Date:** 2026-09-10 · **Collected from:** AJ Ansari, 2026-09-10

> Authoritative source for every name, ID, version, and quoting decision for the rest of the
> routine. Never hardcode these in AL — derive everything from this block (Operating Rule 1).

---

## 1.1 Extension Identity

| Parameter | Value |
|---|---|
| **Extension Name** | `Bootcamp Registration Tracking` |
| **Publisher** | `OnlyCopilotFans` |
| **Deployment Target** | `SaaS PTE` |
| **Use Namespace (y/n)** | `Yes` |
| **Namespace** | `OCPF.BootcampRegistration` |
| **Localization** | `NA` (North American market). No tax-framework or country-specific fields are in scope (see `GapAnalysis-PRE02.md` §8.6), so this value has no field-inclusion impact for this build. |

## 1.2 Object ID Allocation

| Block | From | To | Size | Notes |
|---|---|---|---|---|
| **Primary allocation** | 60800 | 60899 | 100 IDs | The entire allocation. Confirmed by AJ 2026-09-10. |

- No additional allocations.
- **Permission Sets required?** `Yes` — ≥ 2 IDs reserved inside the primary range (planned:
  60890 `OCPF - Bootcamp Read`, 60891 `OCPF - Bootcamp Edit`).
- **Rule:** never use object IDs outside 60800–60899. `app.json` `idRanges` currently declares
  `50100–50149` and **must be rewritten** to `60800–60899` in Step 05.

## 1.3 Naming & API Parameters

| Parameter | Value |
|---|---|
| **AL Object Prefix** | `ocpf` |
| **APIPublisher** | `'OnlyCopilotFans'` |
| **APIGroup Prefix** | `ocpf_` |
| **APIVersion** | `'v1.0'` |
| **Namespace** | `OCPF.BootcampRegistration` (matches 1.1) |
| **Permission Set Prefix** | `OCPF - ` |

### Entity-naming patterns (derived from prefix `ocpf`)

| Element | Value | Length check |
|---|---|---|
| `APIGroup` | `'ocpf_bootcampRegistration'` | 25 — ok |
| Bootcamp `EntityName` / `EntitySetName` | `ocpfBootcamp` / `ocpfBootcamps` | 12 / 13 — ok (≤30) |
| Attendee `EntityName` / `EntitySetName` | `ocpfAttendee` / `ocpfAttendees` | 12 / 13 — ok (≤30) |
| `ODataKeyFields` | `SystemId` | on every API page |

- Bootcamp Registration Setup and the Assisted Setup Wizard are **not** exposed via API — no
  entity names needed.
- Singleton rule (if any singleton API page were added later): `EntityName = EntitySetName`.

## 1.4 Platform & Runtime

| Parameter | Value |
|---|---|
| **AL Runtime** | `17.0` |
| **BC Application Minimum** | `28.0.0.0` |
| **Recommended BC Version** | `28.4+` |
| **Symbol Source** | BC v28.4 symbol files — Base Application `28.4.53241.54183`, Business Foundation `28.4.53241.53312`, System Application `28.4.53241.54101`, Application `28.4.53241.53312`, System `28.0.53984.0` |

## 1.5 Feature Flags (fixed)

| Flag | Status |
|---|---|
| `NoImplicitWith` | **Enabled (enforced)** — already present in `app.json` `"features"`. Every field source prefixed with `Rec.`. |

---

## Quoting reference (applies to every AL and config file)

| Context | Quote style | Example |
|---|---|---|
| `app.json` / `launch.json` values | JSON strings | `"publisher": "OnlyCopilotFans"` |
| AL string property values | Single quotes | `APIPublisher = 'OnlyCopilotFans';` |
| AL object names | Double quotes | `page 60810 "ocpfBootcamps"` |
| BC source field names with spaces | Double quotes on the field name | `Rec."No. Series"` |

---

## Exit-gate checklist (Step 01)

- [x] No placeholder remains.
- [x] Deployment Target is one allowed value (`SaaS PTE`).
- [x] Namespace matches between 1.1 and 1.3 (`OCPF.BootcampRegistration`).
- [x] Localization is set (`NA`).
- [x] Permission Sets required = `Yes` → ≥ 2 IDs reserved in the primary range (60890–60891).
- [ ] **Human confirms the sheet.** ← pending

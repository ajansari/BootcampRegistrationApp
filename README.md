# Bootcamp Registration Tracking

A Business Central per-tenant extension for running bootcamp training events — set up a
bootcamp, register attendees against it, and track payment and attendance, all from inside
Business Central.

## What it does

- **Bootcamps** — topic, location, date, price, seat limits, and a manual lifecycle status
  (Active / Inactive / Completed / Canceled).
- **Attendees** — register people against a bootcamp with contact details and an optional link
  to an existing Customer; track whether they paid, how much, and whether they attended.
- **Capacity at a glance** — a live Registered Attendees count and an auto-maintained Seats
  Remaining, plus a friendly warning (not a hard block) when a registration would go past Max
  Seats.
- **Guided first-time setup** — an Assisted Setup Wizard configures numbering and can create
  sample bootcamps to try the feature out.
- **Role Center dashboard** — five at-a-glance tiles (active bootcamps, unpaid registrations,
  below-threshold bootcamps, registrations and revenue this month) on the Business Manager Role
  Center.
- **API v1.0** — read/write OData endpoints for both Bootcamps and Attendees, for external
  systems, BI, and AI tooling.

## Documentation

| For | See |
|---|---|
| Using the feature in Business Central | [`docs/UserGuide.md`](docs/UserGuide.md) |
| Integrating with the API | [`docs/Documentation.md`](docs/Documentation.md) |
| Installing or upgrading | [`docs/Deployment.md`](docs/Deployment.md) |
| Testing a release | [`docs/HumanUnitTestScript.md`](docs/HumanUnitTestScript.md) |
| Current status of the project | [`ProjectProgress.md`](ProjectProgress.md) |

## Roadmap

See the [project roadmap](docs/Roadmap.md) for planned improvements and deferred decisions.

## Requirements

Business Central Online, application `28.0.0.0` or later (built and validated against `28.4`).

## License

[MIT](LICENSE).

---

Created by **AJ Ansari, OnlyCopilotFans**.

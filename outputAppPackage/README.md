# Build output — .app packages

`outputAppPackage/` is this framework's fixed, standard name for the folder where built `.app`
packages land (CLAUDE.md → ALL ALONG → Packaging & Versioning). The `.app` files themselves are
intentionally kept out of version control (see `.gitignore`); this `README.md` is tracked so the
folder and its purpose survive a fresh clone.

Per the runbook: **never delete a previous package.** Every repackage writes a new,
uniquely-named file here (`<ExtensionName>_<version>.app`) next to the ones already present.

When uploading a package to a Business Central sandbox or production tenant via the Extension
Management page (or the admin center), check whether this build's changes are additive-only
(safe under the default **Add** Schema Sync Mode) or include anything removed, resized, retyped,
or key-altered (needs **Force Sync**, which can cause data loss) — see the same runbook section
for the full criteria.

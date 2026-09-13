# Build output — .app packages

`outputAppPackage/` is this framework's fixed, standard name for the folder where built `.app`
packages land (CLAUDE.md → ALL ALONG → Packaging & Versioning). The `.app` files here **are**
tracked in version control (AJ Ansari, 2026-09-13) — every build is a normal, git-tracked project
deliverable, same as any other. An earlier version of this file said the opposite; that was this
project's own unreviewed scaffold default, never something the runbook actually required.

Per the runbook: **never delete a previous package.** Every repackage writes a new,
uniquely-named file here (`<ExtensionName>_<version>.app`) next to the ones already present.

When uploading a package to a Business Central sandbox or production tenant via the Extension
Management page (or the admin center), check whether this build's changes are additive-only
(safe under the default **Add** Schema Sync Mode) or include anything removed, resized, retyped,
or key-altered (needs **Force Sync**, which can cause data loss) — see the same runbook section
for the full criteria.

**Note (Step 08, `docs/GapAnalysis.md` G-20):** VS Code's own `AL: Package` command (Ctrl+Shift+B
or the command palette) writes its output to the **project root**, not here, under its own
default naming (`<Publisher>_<ExtensionName>_<version>.app`, spaces and all) — a different
pattern from this framework's fixed `<ExtensionName>_<version>.app` in `outputAppPackage/`. Both
are tracked in git (see above). If you see `.app` files sitting in the project root, that's VS
Code's own publish path, not a mistake — per the never-delete-a-package policy, leave them in
place.

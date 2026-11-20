# velix_core

Shared code for the Velix Flutter apps: the brand theme (from DESIGN.md in velix-web), models,
network client, repositories and shared widgets.

This folder is the **single copy**. The customer app uses it by path; the partner app (and the
driver app, when it lands) use it as a git package pinned in their `pubspec.lock`.

When you change it:

1. Merge the change into this repo's `develop`.
2. In each other app, run `flutter pub upgrade velix_core`, check it builds, and commit the
   updated `pubspec.lock`.

Keep changes backwards compatible where you can, since the other apps pick them up only when
they upgrade.

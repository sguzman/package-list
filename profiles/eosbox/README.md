# eosbox

Current package inventory for the `eosbox` EndeavourOS workstation.

Refresh it with:

```fish
./snapshot.fish
```

Expected generated files:

- `arch-all.txt` — every installed Arch package with version
- `arch-explicit.txt` — explicitly installed package names
- `arch-native-explicit.txt` — explicitly installed repository package names
- `arch-foreign.txt` — foreign/AUR/local packages with versions
- `arch-foreign-explicit.txt` — explicitly installed foreign package names
- `cargo.txt` — `cargo install --list`
- `pnpm.txt` — globally installed pnpm packages
- `uv-tools.txt` — uv-managed tools
- `uv-python.txt` — uv-visible installed Python runtimes
- `flatpak-apps.txt` — installed Flatpak applications (not runtimes), showing
  app ID, version, architecture, branch, origin and user/system installation
- `meta.txt` — timestamp, OS/kernel, and package-manager versions

This README is static; the other files are generated snapshots.

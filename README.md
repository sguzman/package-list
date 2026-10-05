# package-list

Durable snapshots of installed software, organized by machine.

This repository records **observed machine package state**. It is not a dotfiles
repository and it is not a replacement for project lockfiles.

## Canonical layout

Current snapshots live under:

```text
profiles/<machine>/
```

The current workstation is:

```text
profiles/eosbox/
```

Older files under `data/` and older machine profiles are retained as historical
snapshots. They are not the canonical current state for `eosbox`.

## Refreshing a machine snapshot

Run from anywhere:

```fish
./snapshot.fish
```

The script defaults to the current hostname, so on `eosbox` it refreshes
`profiles/eosbox/`. An explicit profile name can also be supplied:

```fish
./snapshot.fish eosbox
```

The script snapshots:

- all installed Arch packages with versions;
- explicitly installed Arch package roots;
- explicitly installed native-repository package roots;
- foreign/AUR/local Arch packages;
- explicitly installed foreign package roots;
- Cargo-installed tools;
- global pnpm packages;
- uv-managed tools;
- uv-managed installed Python runtimes;
- machine/toolchain metadata.

It only rewrites the selected profile snapshot files. It does not install,
remove, upgrade, commit, or push anything.

## What belongs elsewhere

Project dependencies belong in each project's own manifests and lockfiles
(`Cargo.lock`, `pnpm-lock.yaml`, `uv.lock`, etc.).

Machine configuration belongs in the separate configuration repository.

#!/usr/bin/env fish

# Refresh the package inventory for one machine profile.
# Defaults to the current hostname, so eosbox writes profiles/eosbox/.

set -l repo_root (path resolve (dirname (status filename)))
set -l machine $argv[1]

if test -z "$machine"
    set machine (hostname)
end

set -l profile_dir "$repo_root/profiles/$machine"

for tool in yay cargo pnpm uv
    if not command -q $tool
        echo "snapshot: required command not found: $tool" >&2
        exit 1
    end
end

mkdir -p "$profile_dir"
or begin
    echo "snapshot: could not create $profile_dir" >&2
    exit 1
end

echo "Refreshing package snapshot for $machine"

yay -Q | sort > "$profile_dir/arch-all.txt"
or exit 1

yay -Qqe | sort > "$profile_dir/arch-explicit.txt"
or exit 1

yay -Qqen | sort > "$profile_dir/arch-native-explicit.txt"
or exit 1

yay -Qm | sort > "$profile_dir/arch-foreign.txt"
or exit 1

yay -Qqem | sort > "$profile_dir/arch-foreign-explicit.txt"
or exit 1

cargo install --list > "$profile_dir/cargo.txt"
or exit 1

pnpm list --global --depth=-1 > "$profile_dir/pnpm.txt"
or exit 1

uv tool list > "$profile_dir/uv-tools.txt"
or exit 1

uv python list --only-installed > "$profile_dir/uv-python.txt"
or exit 1

set -l distro "unknown"
if test -r /etc/os-release
    set distro (grep '^PRETTY_NAME=' /etc/os-release | string replace 'PRETTY_NAME=' '' | string trim -c '"')
end

begin
    echo "profile: $machine"
    echo "hostname: "(hostname)
    echo "generated_utc: "(date -u '+%Y-%m-%dT%H:%M:%SZ')
    echo "distro: $distro"
    echo "kernel: "(uname -srmo)
    echo "fish: "(fish --version)
    echo "yay: "(yay --version | head -n 1)
    echo "cargo: "(cargo --version)
    echo "pnpm: "(pnpm --version)
    echo "uv: "(uv --version)
end > "$profile_dir/meta.txt"
or exit 1

echo
echo "Updated profiles/$machine:"
git -C "$repo_root" status --short -- "profiles/$machine"

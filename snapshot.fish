#!/usr/bin/env fish

# Refresh the package inventory for one machine profile.
# Defaults to the current hostname, so eosbox writes profiles/eosbox/.

set -l repo_root (path resolve (dirname (status filename)))
set -l machine $argv[1]

if test -z "$machine"
    set machine (hostname)
end

set -l profile_dir "$repo_root/profiles/$machine"

for tool in yay cargo pnpm uv flatpak
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

# Inventory installed Flatpak applications (system and user); omit runtimes.
# Keep application ID, version, arch, branch, origin and installation scope.
flatpak list --app --columns=application,version,arch,branch,origin,installation > "$profile_dir/flatpak-apps.txt"
or exit 1

# Gear Lever integrates AppImages in ~/AppImages by default, separately from Flatpak.
# Inventory actual AppImage files, and enrich with Gear Lever desktop-entry metadata.
# Override PACKAGE_LIST_APPIMAGE_DIR if Gear Lever's managed folder was changed.
set -l appimage_dir "$HOME/AppImages"
if set -q PACKAGE_LIST_APPIMAGE_DIR; and test -n "$PACKAGE_LIST_APPIMAGE_DIR"
    set appimage_dir "$PACKAGE_LIST_APPIMAGE_DIR"
end
set -l desktop_dir "$HOME/.local/share/applications"

begin
    printf 'name\tversion\tintegrated\tpath\n'
    if test -d "$appimage_dir"
        for appimage in (find "$appimage_dir" -maxdepth 1 -type f -iname '*.appimage' | sort)
            set -l app_name (string replace -r '(?i)\.appimage$' '' -- (basename -- "$appimage"))
            set -l app_version unknown
            set -l integrated no

            if test -d "$desktop_dir"
                for desktop in (find "$desktop_dir" -maxdepth 1 -type f -name '*.desktop')
                    set -l target (string match -r '^TryExec=.*' < "$desktop" | string replace -r '^TryExec=' '')
                    if test "$target" = "$appimage"
                        set integrated yes
                        set -l desktop_name (string match -r '^X-AppImage-Name=.*' < "$desktop" | string replace -r '^X-AppImage-Name=' '')
                        if test -z "$desktop_name"
                            set desktop_name (string match -r '^Name=.*' < "$desktop" | string replace -r '^Name=' '')
                        end
                        set -l desktop_version (string match -r '^X-AppImage-Version=.*' < "$desktop" | string replace -r '^X-AppImage-Version=' '')
                        if test -n "$desktop_name"
                            set app_name "$desktop_name"
                        end
                        if test -n "$desktop_version"
                            set app_version "$desktop_version"
                        end
                        break
                    end
                end
            end
            printf '%s\t%s\t%s\t%s\n' "$app_name" "$app_version" "$integrated" "$appimage"
        end
    end
end > "$profile_dir/appimage-apps.txt"
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
    echo "flatpak: "(flatpak --version)
end > "$profile_dir/meta.txt"
or exit 1

echo
echo "Updated profiles/$machine:"
git -C "$repo_root" status --short -- "profiles/$machine"

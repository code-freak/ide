#! /bin/env bash
# Utility script to preinstall runtime dependencies of VSCode extensions
# This seems propritary to Microsoft's C# extension (ms-dotnettools.csharp)
#
# Dependencies:
#  - jq to parse package.json
#  - curl to download archives
#  - unzip to extract archives
#
# Usage:
#  ./install-ext-runtime-deps.sh [absolte path to extension installation dir conainting package.json]
# Example:
#  ./install-ext-runtime-deps.sh /home/coder/.local/share/code-server/extensions/ms-dotnettools.csharp-*

set -e

ext_dir="$(realpath "$1")"

if [ ! -f "$ext_dir/package.json" ]; then
    echo "Directory does not contain any package.json!";
    exit 1
fi

echo -e "Installing runtimeDependencies of $ext_dir\n"

# Read all runtime deps into an array where each object contains
# installPath, url, binaries
declare -a runtime_deps=($(jq --compact-output '.runtimeDependencies[] | select(.platforms[] | contains("linux")) | select(.architectures[] | contains("x86_64")) | {installPath: .installPath, url: .url, binaries: .binaries}' "$ext_dir/package.json"))

for dep in ${runtime_deps[@]}; do
    install_path="$ext_dir/$(echo "$dep" | jq -r ".installPath")"
    url="$(echo "$dep" | jq -r ".url")"
    binaries=($(echo "$dep" | jq -r ".binaries[]"))
    basename="${url##*/}"
    tmp_file="$ext_dir/$basename"

    echo -e "Downloading $url...\n"
    curl -Lo "$tmp_file" "$url"
    echo -e "Extracting $basename to $install_path...\n"
    # nuke everything in our destination dir to prevent "replace XYZ" questions by unzip
    rm -rf "$install_path"
    mkdir -p "$install_path"
    # unzip extracts archives with "backwards slashes warning" fine but finishes with exit code 1
    unzip -q "$tmp_file" -d "$install_path" || true
    rm "$tmp_file"

    for binary in "${binaries[@]}"; do
        echo -e "Making $install_path/$binary executable\n"
        # seems like there are some binaries that do not exist anymore
        [ -f "$install_path/$binary" ] && chmod u+x "$install_path/$binary"
    done
    # Mark dependencies
    touch "$install_path/install.complete"
    touch "$install_path/install.Lock"
done

echo -e "Done installing ${#runtime_deps[@]} runtime dependencies.\n"
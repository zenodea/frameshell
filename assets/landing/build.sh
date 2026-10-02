#!/bin/sh
# Assembles the landing page into _site/ next to this script (or into $1).
set -e
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
out=${1:-$here/_site}

rm -rf "$out"
mkdir -p "$out/assets"
cp "$here/index.html" "$here"/*.webp "$out/"
cp -R "$here/wallpapers" "$out/wallpapers"
cp "$repo/assets/demo.mp4" "$out/assets/"
cp -R "$repo/assets/screenshots" "$out/assets/screenshots"

# every bundled theme in one file, keyed by name
{
    printf '{'
    sep=
    for f in "$repo"/themes/*.json; do
        printf '%s"%s":' "$sep" "$(basename "$f" .json)"
        tr -d '\n' < "$f"
        sep=,
    done
    printf '}'
} > "$out/themes.json"

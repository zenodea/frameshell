#!/bin/sh
# Assembles the landing page into _site/ (or $1) for GitHub Pages.
set -e
cd "$(dirname "$0")/.."
out=${1:-_site}

rm -rf "$out"
mkdir -p "$out"
cp site/index.html site/*.webp "$out/"
cp -R site/wallpapers "$out/wallpapers"
cp -R assets "$out/assets"

# every bundled theme in one file, keyed by name
{
    printf '{'
    sep=
    for f in themes/*.json; do
        printf '%s"%s":' "$sep" "$(basename "$f" .json)"
        tr -d '\n' < "$f"
        sep=,
    done
    printf '}'
} > "$out/themes.json"

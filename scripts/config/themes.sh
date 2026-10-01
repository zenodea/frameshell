#!/usr/bin/env bash

printf '['
first=1
for dir in "$@"; do
    for f in "$dir"/*.json; do
        [[ -f "$f" ]] || continue
        ((first)) || printf ','
        first=0
        printf '{"name":"%s","colours":%s}' "$(basename "$f" .json)" "$(tr -d '\n' < "$f")"
    done
done
printf ']\n'

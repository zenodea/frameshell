#!/usr/bin/env bash

dir="$1"
cache="$2"
missing=()

preview() {
    if command -v magick > /dev/null; then
        magick "$1[0]" -thumbnail 480x -quality 82 "$2"
    elif command -v ffmpeg > /dev/null; then
        ffmpeg -v error -y -i "$1" -vf scale=480:-1 -frames:v 1 "$2"
    else
        return 1
    fi
}

mkdir -p "$cache"

for f in "$dir"/*; do
    [[ -f "$f" ]] || continue
    name=$(basename "$f")
    case "${name,,}" in
        *.png | *.jpg | *.jpeg | *.webp | *.avif | *.bmp | *.gif) ;;
        *) continue ;;
    esac

    thumb="$cache/$(printf '%s' "$f" | sha1sum | cut -c1-16).jpg"
    if [[ -s "$thumb" && ! "$f" -nt "$thumb" ]]; then
        printf '%s\t%s\n' "$name" "$thumb"
    else
        printf '%s\t%s\n' "$name" "$f"
        missing+=("$f" "$thumb")
    fi
done

exec >&-

for ((i = 0; i < ${#missing[@]}; i += 2)); do
    preview "${missing[i]}" "${missing[i + 1]}.tmp.jpg" 2> /dev/null && mv "${missing[i + 1]}.tmp.jpg" "${missing[i + 1]}"
done

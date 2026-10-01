#!/usr/bin/env bash

if pgrep -x awww-daemon > /dev/null; then
    awww img "$1" --transition-type wipe --transition-duration 1
elif pgrep -x swww-daemon > /dev/null; then
    swww img "$1" --transition-type wipe --transition-duration 1
elif pgrep -x hyprpaper > /dev/null; then
    hyprctl hyprpaper reload ",$1"
else
    exit 1
fi

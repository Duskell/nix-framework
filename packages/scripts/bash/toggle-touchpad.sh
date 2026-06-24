#!/bin/bash

DEVICES=(
  "ALP0026:00 044E:1222 Mouse"
  "ALP0026:00 044E:1222 Touchpad"
  "AlpsPS/2 ALPS DualPoint TouchPad"
)

PRIMARY_DEV="ALP0026:00 044E:1222 Touchpad"

device_line=$(xinput | grep "$PRIMARY_DEV")

if [ -z "$device_line" ]; then
  notify-send "Touchpad Error" "Touchpad hardware not detected."
  exit 1
fi

if echo "$device_line" | grep -q "floating slave"; then
  for dev in "${DEVICES[@]}"; do
    xinput --enable "$dev" 2>/dev/null
  done
  notify-send -i emblem-nowrite "Touchpad" "Enabled"
else
  for dev in "${DEVICES[@]}"; do
    xinput --disable "$dev" 2>/dev/null
  done
  notify-send -i emblem-nowrite "Touchpad" "Disabled"
fi

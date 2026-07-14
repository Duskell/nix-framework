#!/bin/bash

LOW_BATTERY_THRESHOLD=15
while true; do
  battery_level=$(acpi -b | grep -P -o '[0-9]+(?=%)')
  charging_status=$(acpi -b | grep -oP 'Charging|Discharging')
  if [ "$battery_level" -lt "$LOW_BATTERY_THRESHOLD" ] && [ "$charging_status" == "Discharging" ]; then
    notify-send "Low Battery Warning" "Battery is at $battery_level%. Please plug in your charger."
  fi
  sleep 60
done

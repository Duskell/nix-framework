#!/usr/bin/env bash

# Define the primary color used for Ethernet formatting in Polybar
PRIMARY_COLOR="#f0c674"

# Get the primary interface used for internet routing
iface=$(ip route | awk '/^default/ {print $5}' | head -n1)

# If the interface starts with 'e' (eth0, eno1, enp3s0, etc.)
if [[ "$iface" == e* ]]; then
  echo "󰈀 "

# If the interface starts with 'w' (wlan0, wlp2s0, etc.)
elif [[ "$iface" == w* ]]; then
  echo "󰖩 "

else
  echo "󰖪 "
fi

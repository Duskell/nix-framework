#!/usr/bin/env bash

if ! command -v playerctl &>/dev/null; then
  echo "playerctl is not installed."
  exit 1
fi

if playerctl -l 2>/dev/null | grep -iq "YoutubeMusic"; then

  status=$(playerctl -p YoutubeMusic status 2>/dev/null)

  if [[ "$status" == "Playing" ]]; then
    song=$(playerctl -p YoutubeMusic metadata --format "{{ artist }} - {{ title }}" 2>/dev/null)

    # Truncate if longer than 30 characters
    if [ ${#song} -gt 30 ]; then
      song="${song:0:30}..."
    fi
    echo "$song"
  else
    echo "Paused."
  fi

else
  echo "Not running. Click to open"
fi

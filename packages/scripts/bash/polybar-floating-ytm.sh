#!/bin/bash

if ! command -v playerctl &>/dev/null; then
  echo "playerctl is not installed."
  exit 1
fi

get_ytm_song_linux() {
  playerctl -p YoutubeMusic metadata --format "{{ artist }} - {{ title }}"
}

if pgrep -x "YoutubeMusic" >/dev/null; then
  song=$(get_ytm_song_linux)

  if [[ -n "$song" ]]; then
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

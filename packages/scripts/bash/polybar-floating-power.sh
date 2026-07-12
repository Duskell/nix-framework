#!/usr/bin/env bash

uptime=$(uptime -p | sed -e 's/up //g')

vicinae_command="vicinae dmenu"

# Options
shutdown=" Shutdown"
reboot="󰜉 Restart"
suspend="󰒲 Sleep"
lock=" Lock"
logout=" Logout"

# Confirmation prompt using vicinae
confirm_exit() {
  echo -e "no\nyes" | $vicinae_command -p "Are You Sure?"
}

# Combine choices into a single string stream
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

# Launch the primary selector
chosen="$(echo -e "$options" | $vicinae_command -p "Uptime: $uptime")"

case $chosen in
$shutdown)
  if [[ $(confirm_exit) == "yes" ]]; then
    systemctl poweroff
  fi
  ;;
$reboot)
  if [[ $(confirm_exit) == "yes" ]]; then
    systemctl reboot
  fi
  ;;
$lock)
  if command -v i3lock-blur &>/dev/null; then
    i3lock-blur
  fi
  ;;
$suspend)
  if [[ $(confirm_exit) == "yes" ]]; then
    mpc -q pause
    amixer set Master mute
    systemctl suspend
  fi
  ;;
$logout)
  if [[ $(confirm_exit) == "yes" ]]; then
    if [[ "$DESKTOP_SESSION" == "Openbox" ]]; then
      openbox --exit
    elif [[ "$DESKTOP_SESSION" == "bspwm" ]]; then
      bspc quit
    elif [[ "$DESKTOP_SESSION" == "i3" ]]; then
      i3-msg exit
    fi
  fi
  ;;
esac

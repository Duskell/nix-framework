# Created By @hussainhareb
# Edited and Ported to Nix By Duskell
{
  pkgs,
  framework,
  config,
}: let
  background = "#CC1e1e2e";
  nix_color = "#5fb8f2";
  music_color = "#f60000";
  white = "#f5f3e1";
  mauve = "#490761";
  mauving = "#c867eb";
  grey = "#dddddd";
  really_white = "#ffffff";
  blue = "#89d1fa";
  background_alt = "#373b41";
  foreground = "#fcf5bd";
  primary = "#f0c674";
  secondary = "#8abeb7";
  alert = "#a54242";
  disabled = "#707880";
  border_color = "#00000000";

  height = "32pt";
  radius = 8;

  font_0 = "JetBrainsMono Nerd Font:weight=bold:size=12;3";
  font_0_1 = "JetBrainsMono Nerd Font:weight=bold:size=20;5";
  font_1 = "Symbols Nerd Font Mono:size=12;3";

  override = true;
in {
  #---------------------BARS--------------------#

  "bar/spacer" = {
    width = "0.1%";
    height = 32;
    border-size = "5pt";
    border-color = border_color;
    background = border_color;
    override-redirect = false;
    modules-center = "space";
  };

  "bar/power" = {
    width = "3.3%";
    offset-x = "0%";
    height = height;
    radius = radius;

    background = background;
    foreground = foreground;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 0;

    font-0 = font_0_1;
    font-1 = font_1;

    modules-center = "nix";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;
  };

  "bar/clock" = {
    width = "10%";
    offset-x = "3.3%";
    height = height;
    radius = radius;

    background = background;
    foreground = foreground;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 1;

    font-0 = font_0;
    font-1 = font_1;

    modules-left = "date";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;
  };

  "bar/yt-music" = {
    width = "20%";
    offset-x = "13.3%";
    height = height;
    radius = radius;

    background = background;
    foreground = foreground;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 1;

    font-0 = font_0;
    font-1 = font_1;

    modules-left = "ytm space yt-music";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;

    cursor-click = "pointer";
  };

  "bar/workspaces" = {
    width = "15.8%";
    offset-x = "42.1%";
    height = height;
    radius = radius;

    background = background;
    foreground = foreground;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 1;

    font-0 = font_0;
    font-1 = font_1;

    modules-center = "xworkspaces";

    cursor-click = "pointer";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;
  };

  "bar/cava" = {
    width = "15.2%";
    offset-x = "60%";
    height = height;
    radius = radius;

    background = background;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 1;

    font-0 = font_0;
    font-1 = font_1;

    modules-left = "cava";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;

    cursor-click = "pointer";
  };

  "bar/weather" = {
    width = "5%";
    offset-x = "75.2%";
    height = height;
    radius = radius;

    background = background;
    foreground = foreground;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 1;

    font-0 = font_0;
    font-1 = font_1;

    modules-center = "weather";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;

    cursor-click = "pointer";
  };

  "bar/sound" = {
    width = "10%";
    offset-x = "80.2%";
    height = height;
    radius = radius;

    background = background;
    foreground = foreground;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 1;

    font-0 = font_0;
    font-1 = font_1;

    modules-center = "audio space mic";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;

    cursor-click = "pointer";
  };

  "bar/settings" = {
    width = "9.8%";
    offset-x = "90.2%";
    height = height;
    radius = radius;

    background = background;
    foreground = foreground;

    border-size = "5pt";
    border-color = border_color;

    padding-left = 1;
    padding-right = 1;

    font-0 = font_0;
    font-1 = font_1;

    modules-center = "battery space backlight space network";

    enable-ipc = true;

    wm-restack = "i3";
    override-redirect = override;

    cursor-click = "pointer";
  };

  #--------------------MODULES--------------------#

  "module/nix" = {
    type = "custom/text";
    content = " ";
    content-font = 1;
    content-foreground = nix_color;
    content-margin = 0;
    click-left = "${pkgs.polybar-floating-power}/bin/polybar-floating-power 2>~/polybar-power-error.log";
  };

  "module/date" = {
    type = "internal/date";
    interval = 1;
    date = " %I:%M %p|%d-%m";
    label = "%date%";
    label-foreground = foreground;
  };

  "module/ytm" = {
    type = "custom/text";
    content = "󰫔";
    content-font = 2;
    content-foreground = music_color;
    content-margin = 0;
  };

  "module/yt-music" = {
    type = "custom/script";
    exec = "${pkgs.polybar-floating-ytm}/bin/polybar-floating-ytm 2>~/polybar-ytm-error.log";
    interval = 1;
    format = "<label>";
    label = "%output%";
    click-left = "pear-desktop";
  };

  "module/xworkspaces" = {
    type = "internal/i3";

    index-sort = true;

    pin-workspaces = false;

    # Focused / Active Workspace
    label-focused = "";
    label-focused-padding = 1;
    label-focused-font = 1;

    # Unfocused / Background Workspace
    label-unfocused = "";
    label-unfocused-padding = 1;
    label-unfocused-foreground = grey;
    label-unfocused-font = 1;

    # Visible but not focused
    label-visible = "";
    label-visible-padding = 1;
    label-visible-font = 1;

    #label-urgent = "";
    #label-urgent-padding = 1;
    #label-urgent-foreground = alert;
    #label-urgent-font = 1;
  };

  "module/cava" = {
    type = "custom/script";
    exec = "${pkgs.python312}/bin/python3 ${framework}/assets/scripts/cava.py -f 60 -b 26 -e 00FFFF,66FFFF,99FFFF,CCE5FF,E6CCFF,FFB3FF,FF80FF,FF00FF -c stereo 2>~/polybar-cava-error.log";
    tail = true;
  };

  "module/network" = {
    type = "custom/script";
    exec = "${pkgs.polybar-floating-network}/bin/polybar-floating-network";
    interval = 1;
    format-foreground = white;
    format = "<label>";
    label = "%output%";
  };

  "module/backlight" = {
    type = "internal/backlight";
    card = "intel_backlight";
    use-actual-brightness = true;
    enable-scroll = true;
    format = "<ramp> <label>";
    format-foreground = white;
    label = "%percentage%%";

    ramp-0 = "󰃞";
    ramp-1 = "󰃝";
    ramp-2 = "󰃟";
    ramp-3 = "󰃠";
  };

  "module/battery" = {
    type = "internal/battery";
    full-at = 99;
    low-at = 20;
    battery = "BAT0";
    adapter = "ADP1";
    poll-interval = 5;
    format-charging-foreground = foreground;
    format-discharging-foreground = foreground;
    format-charging = "<animation-charging><label-charging>";
    format-discharging = "<ramp-capacity><label-discharging>";
    label-charging = "%percentage%%";
    label-discharging = "%percentage%%";
    label-full = "Full";
    label-low = "LOW";

    ramp-capacity-0 = " ";
    ramp-capacity-1 = " ";
    ramp-capacity-2 = " ";
    ramp-capacity-3 = " ";
    ramp-capacity-4 = " ";

    bar-capacity-width = 10;

    animation-charging-0 = " ";
    animation-charging-1 = " ";
    animation-charging-2 = " ";
    animation-charging-3 = " ";
    animation-charging-4 = " ";
    animation-charging-framerate = 750;

    animation-discharging-0 = " ";
    animation-discharging-1 = " ";
    animation-discharging-2 = " ";
    animation-discharging-3 = " ";
    animation-discharging-4 = " ";

    animation-discharging-framerate = 500;

    animation-low-0 = "!";
    animation-low-1 = "";
    animation-low-framerate = 200;
  };

  "module/audio" = {
    type = "internal/pulseaudio";
    format-volume = "<label-volume>";
    format-volume-prefix = "󰕾 ";
    format-volume-foreground = blue;
    format-volume-prefix-foreground = blue;
    label-volume = "%percentage%%";

    label-muted = "󰖁 Muted";
    label-muted-foreground = blue;
  };

  "module/mic" = {
    type = "custom/script";
    exec = "${pkgs.polybar-floating-mic}/bin/polybar-floating-mic";
    interval = 1;
    format-foreground = blue;
    format = "<label>";
    label = "%output%";
    click-left = "${pkgs.polybar-floating-mic}/bin/polybar-floating-mic 1";
  };

  "module/weather" = {
    type = "custom/script";
    exec = let
      pythonEnv = pkgs.python312.withPackages (ps: [ps.requests]);
    in "${pythonEnv}/bin/python3 ${framework}/assets/scripts/get-weather.py";
    interval = 1800;
    format-foreground = really_white;
    format = "<label>";
    label = "%output%";
  };

  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format-prefix = "CPU ";
    format-prefix-foreground = primary;
    label = "%percentage:2%%";
  };

  "settings" = {
    screenchange-reload = true;
    pseudo-transparency = false;
  };

  "module/space" = {
    type = "custom/text";
    content = " ";
  };
}

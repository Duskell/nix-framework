{ ... }:
rec {
  servers = {
    x11     = "x11";
    wayland = "wayland";
  };

  displayManagers = {
    ly   = "ly";
    sddm = "sddm";
  };

  environments = {

    # KDE Plasma 6
    plasma = {
      flavor = "plasma";
      server = servers.wayland;
      dm = displayManagers.sddm;
    };

    i3 = {
      flavor   = "i3";
      server   = servers.x11;
      dm = displayManagers.ly;
    };

  };

  # environmentByName :: string -> (attrset | null)
  environmentByName = name: if name == null then null else environments."${name}";

  # isPlasma :: attrset -> bool
  isPlasma = environment: environment.flavor == "plasma";

  # usesWayland :: attrset -> bool
  usesWayland = environment: environment.server == servers.wayland;
}
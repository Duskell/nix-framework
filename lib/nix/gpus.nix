{ ... }:
rec {
  vendors = {
    nvidia = "nvidia";
    amd    = "amd";
    intel  = "intel";
  };
  
  cards = {
    # NVIDIA T1000
    nvidia-t1000 = {
      vendor       = vendors.nvidia;
      architecture = "turing";
    }
  };

  # cardByName :: string -> (attrset | null)
  cardByName = name: if name == null then null else cards."${name}";

  # isNvidia :: attrset -> bool
  isNvidia = gpu: gpu.vendor == vendors.nvidia;

  # isAMD :: attrset -> bool
  isAMD = gpu: gpu.vendor == vendors.amd;
}
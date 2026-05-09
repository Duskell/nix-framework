{ ... }@inputs:
{
  desktops = (import ./desktops.nix) inputs;
  gpus = (import ./gpus.nix) inputs;
  nixos = (import ./nixos.nix) inputs;
  webwrap = (import ./webwrap.nix) inputs;
}
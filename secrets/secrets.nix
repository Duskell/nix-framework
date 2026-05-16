let
  hp = "age122lavyk7jh3utnm0f56l3nec3wasfkxd6uy7av4y47ej9ffpm9aqnnw294";
  server = "age1qwhvvtj9zv08dy90vk3m9c8qmcwdqwcxy44eq85mu2q0d92s23fsw9772j";
  newHp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAKunlgjIIMQsUxN6oEmrP+CDik0zwt5PSQZ65gkt5a root@nixos";
  newServer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEfRtaUPRCcVftqkX3KWSySUnWIDRwMDXzS5bm2TZ7dt root@nixos";
  hosts = [hp server newHp newServer];
in {
  "tailscale-key.age".publicKeys = hosts;
  "ssh-github-duskell.age".publicKeys = hosts;
  "copyparty-levente.age".publicKeys = hosts;
  "copyparty-attila.age".publicKeys = hosts;
}

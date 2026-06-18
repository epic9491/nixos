{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
   # ./backup.nix
    ../../../modules/baseline.nix # <-- shared config between laptop/desktop
    ../../../modules/flatpak.nix
    ../../../modules/niri.nix #     <-- niri environment
    # ../../../modules/hypr.nix     <-- hyprland environment
    # ../../../modules/gnome.nix    <-- gnome environemt
    ../../../modules/kde.nix      # <-- kde environment
    # ../../../modules/xfce.nix     <-- xfce environment
    ../../../modules/mount.nix
    ../../../modules/packages.nix
    ../../../modules/ssh.nix
    ../../../modules/nixvim.nix
    ../../../modules/yazi.nix
    ../../../modules/virtualization.nix
    ../../../modules/polkit.nix
  ];

  # hostname
  networking.hostName = "erebos";

  workstation = {
    baseline = {
      enable = true;              # enable baseline config
      packages = {
        tools = true;             # enable common suite of CLI tools
        dev = true;               # enable common langs/lang related tools
        apps = true;              # enable common desktop applications
      };
    };      
    nixvim.enable = true;         # enable nixvim configuration
    niri.enable = false;           # change to a different profile if you want
    kde.enable = true;
    polkit.enable = true;
    yazi.enable = true;           # yazi
    ssh.enable = true;            # enable default ssh configuration + authorized yubikeys
    virtualization.enable = true; # enable QEMU/KVM virtualization
    flatpak = {
      enable = true;
      onCalendar = "weekly";
      packages = [
        "flathub:app/app.zen_browser.zen//stable"
        "flathub:app/com.github.tchx84.Flatseal//stable"
      ];
    };
  };

  # environments, switch to true or false as needed
  # workstation.hypr.enable = true;
  # workstation.gnome.enable = true;
  # workstation.kde.enable = true;
  # workstation.xfce.enable = true;

  age.identityPaths = [ "/home/gumbo/.ssh/agenix_gumbo" ];
  
  # symlink agenix key so I can use it in cli
  system.activationScripts.agenix-cli-identity = ''
    if [ ! -e /home/gumbo/.ssh/id_ed25519 ]; then
      ln -s /home/gumbo/.ssh/agenix_gumbo /home/gumbo/.ssh/id_ed25519
    fi
  '';

  mount = {
    media.enable = true;
    games.enable = true;
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/jelly/jelly  192.168.0.0/24(ro,no_subtree_check,async)
      /mnt/jelly/manga  100.69.69.217/32(ro,no_subtree_check,async)
      /mnt/jelly/photos 192.168.0.0/24(rw,no_subtree_check,sync)
      /mnt/jelly/music  192.168.0.0/24(rw,no_subtree_check,async)
    '';
  };
  
  programs.steam.enable = true;
  programs.coolercontrol.enable = true;
  hardware.cpu.amd.updateMicrocode = true;

  hardware.graphics = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    heroic
    input-remapper
  ];

  networking.firewall.allowedTCPPorts = [ 2049 ];

}

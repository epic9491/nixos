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
    ../../../modules/hypr.nix #     <-- hyprland environment
    # ../../../modules/gnome.nix    <-- gnome environemt
    ../../../modules/kde.nix
    # ../../../modules/xfce.nix     <-- xfce environment
    ../../../modules/storagebox.nix
    ../../../modules/retroshare.nix
    ../../../modules/nixvim.nix
    ../../../modules/packages.nix
    ../../../modules/yazi.nix
    ../../../modules/virtualization.nix
    ../../../modules/polkit.nix
  ];

  # hostname
  networking.hostName = "prometheus";
  hardware.cpu.amd.updateMicrocode = true;

  workstation = {
    baseline = {
      enable = true;              # enable baseline config
      packages = {
        tools = true;             # enable common suite of CLI tools
        dev = true;               # enable common langs/lang related tools
        apps = true;              # enable common desktop applications
      };
    }; 
    retroshare.enable = false;     # enables ROM sync to server
    nixvim.enable = true;         # enable nixvim configuration
    niri.enable = true;           # change to a different profile if you want
    kde.enable= false;
    polkit.enable = true;
    yazi.enable = true;           # yazi
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

  # environments, switch to true as needed
  # workstation.hypr.enable = true;
  # workstation.gnome.enable = true;
  # workstation.kde.enable = true;
  # workstation.xfce.enable = true;

  services.fprintd.enable = true;

  age.identityPaths = [ "/home/gumbo/.ssh/agenix_gumbo" ];
  
  # symlink agenix key so I can use it in cli
  system.activationScripts.agenix-cli-identity = ''
    if [ ! -e /home/gumbo/.ssh/id_ed25519 ]; then
      ln -s /home/gumbo/.ssh/agenix_gumbo /home/gumbo/.ssh/id_ed25519
    fi
  '';

  programs.steam.enable = true;

  systemd.services.micmute-led-off = {
    description = "Turn off micmute LED at boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "sysinit.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 0 > /sys/class/leds/platform::micmute/brightness || true'";
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    v4l-utils
  ];
}

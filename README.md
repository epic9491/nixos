# My NixOS configurations v3

This is a pretty significant overhaul of the structure the repo used previously, and should allow for more flexibility and easier modification. About 20 directories and 40 files were removed.

The flake builds no longer depend on hostname-profile (e.g. `erebos-niri`, `prometheus-hypr`, etc) and are now only `.#hostname`. I've converted the "profiles" I used before into modules which can be enabled or disabled as needed. At the time of writing, the Home Manager file for the respective environment will need to be swapped out in `flake.nix`. Make sure you comment or remove any conflicting files from other environments.

I previously got a little over-ambitious in the past and pushed a structure for servers, I have since removed that structure (the bulk of the directories and files that were removed) and instead am slowly migrating services to NixOS servers. If you would like to take a look at how I have configured those, relevant files are `/flake.nix`, `/modules/baseline.server.nix`, `/home/server.nix`, and `/devices/server/*`. 

Though I've learned a lot about NixOS since I started daily driving it in 2025, this configuration should be used with caution. You should review all files for anything that may conflict with what you are looking for out of your build. You may need to adjust occurrences of things specific to my environment, like hostnames, usernames, filesystem mounts, etc. Part of the reason I broke things up into modules is to make that process easier.

## Table of Contents
- [Repo structure](#repo-structure)
- [Important things to note](#important-things-to-note)
- [Current valid build commands](#current-valid-build-commands-from-root-of-repo)
- [Showcase](#showcase)
- [Installation](#installation)
- [Sponsor NixOS](#sponsor-nixos)
- [Github mirror](#github-mirror)

## Repo structure

- `/config`: software configuration files (ghostty, fastfetch, niri binds, etc). Pretty much all of these are managed through Home Manager and deployed to `~/.config`.
- `/devices`: broken into `/desktop`, `/laptop`, and `/server`. This is where device-specific configurations and modules are imported and set, as well as the home for `hardware-configuration.nix`. If you're cloning this repo, don't forget to replace this file with your own.
- `/home`: Home Manager configurations for my baseline (`common.nix`), DE/WM-specific configurations, etc.
- `/modules`: this is where the vast majority of the restructuring was done. Review and adjust as needed. Many things are specific to my environment. Overall, the move to modules should make this repo much more flexible for both myself and anyone else who may want to use it.
- `/pics`: profile pictures and eventually screenshots to include in the README.

## Important things to note

- My workstations run on the **unstable** branch, use the **latest kernel**, and **allow unfree software**. My servers run on the **stable** branch, use an **LTS kernel**, and also allow **unfree software**. Garbage collection removes all generations older than 7 days on both workstations and servers, Nix store optimization is run on every rebuild.
- `/modules/baseline.nix` is exactly what it sounds like. Services, kernel and boot parameters, and other core, shared settings are defined here. You should review this file. The baseline is enabled with: ```workstation.baseline.enable = true;```. Most modules are nested within the ```workstation``` option.
- `/modules/packages.nix` handles all shared packages for workstations. It is broken up into options, being ```tools```, ```dev```, and ```apps```. I have nested the modules options into the ```baseline``` option as I still consider it a part of the baseline, but that file was getting too big and this makes more sense.
- All builds use **zsh** by default. I have separate **zsh** and **bash** Home Manager files, you can switch the shell to say bash by modifying the shell file Home Manager imports under either machines entry in ```flake.nix```.
- I use **Niri** almost exclusively. The Niri module uses **Noctalia Shell**. If you don't want to use Noctalia, remove it's input in `flake.nix` and remove the package from Niri's module. If you're using my Niri config from `/config/niri`, remove ```spawn-at-startup "noctalia-shell"``` from the file. The Niri module will be up to date more often than the others. GNOME and XFCE modules should be stable and usable.
- Hyprland currently lags behind upstream. Breaking changes were made to window-rule syntax in version 0.53, and I have not yet made adjustments to accommodate this. I don't really have any window rules though so it's probably fine. Use niri.
- KDE and GNOME work great if that's what you like.
- Display managers change depending on what environment you choose:
  - Desktop environments use their defaults (GNOME = GDM, KDE = SDDM, XFCE = LightDM)
  - Window managers use `tuigreet` with autologin
- The **SteamOS** build is **not** a functional configuration. This was an experiment to create a SteamOS-like environment that boots directly into Gamescope, aiming for a more console-like experience with support for things like Netflix or YouTube as non-Steam games. It does boot into Gamescope with Steam in Big Picture mode (after a delay), but playing games or streaming them from another device does not work.
- This repo is not 100 MB. Wallpapers used to live here and were removed. The blobs should also be removed from `.git`. ```du -hs``` reports **8.7 MB** at the time of writing.

## Current valid build commands (from root of repo)

```sudo nixos-rebuild boot --flake .#prometheus``` (laptop build)

```sudo nixos-rebuild boot --flake .#erebos``` (desktop/gaming build)

## Showcase

<video src="https://codeberg.org/sensei/nixos/raw/branch/assets/recording_20260208_103359.mp4" controls width="100%"></video>

## Installation

For installation instructions, please see https://codeberg.org/sensei/nixos/wiki/Installation-instructions

## Sponsor NixOS

Please consider sponsoring NixOS to support the people that this possible https://github.com/sponsors/NixOS

## GitHub mirror

For the GitHub only folks, you can find the mirror here https://github.com/epic9491/nixos

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config
, lib
, pkgs
, hostname
, username
, ...
}:

{

  # WARN: Do not change unless you know what you're doing
  # Does not dictate current version of system
  system.stateVersion = "24.05";


  networking.hostName = "${hostname}"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless.enable = false; # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Disable the X11 windowing system.
  services.xserver.enable = false;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound.
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = false;
    pulse.enable = false;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
  programs.git.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      # desktop-windows-wsl
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDiMx4rHgmNc/fwHcffw8pRT2xfsUtfgnUKjKxRIWeG minttea@wsl"
    ];
  };

  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
}


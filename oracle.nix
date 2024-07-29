{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  services.fail2ban.enable = true;
  services.fail2ban.bantime-increment.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 8108 ];

    sftpFlags = [
      "-f AUTHPRIV"
      "-l INFO"
    ];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";

      PermitRootLogin = "no";
      DenyUsers = [ "root" ];
      DenyGroups = [ "root" ];

      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];

      X11Forwarding = true;
    };

  };

  # WARN: Oracle Cloud requires iSCSI outgoing endpoints only accessible to root
  # https://docs.oracle.com/en-us/iaas/Content/Compute/References/images.htm#image-firewall-rules
  networking.firewall.enable = true;
  networking.firewall.extraCommands = ''
    iptables -A OUTPUT -m owner --uid-owner root -d 169.254.0.2 -p tcp --dport 3260 -j ACCEPT
    iptables -A OUTPUT -m owner --uid-owner root -d 169.254.2.0/24 -p tcp --dport 3260 -j ACCEPT
    iptables -A OUTPUT -d 169.254.0.2 -p tcp --dport 3260 -j DROP
    iptables -A OUTPUT -d 169.254.2.0/24 -p tcp --dport 3260 -j DROP
  '';

  # WARN: Oracle Cloud Linux image restrictions
  # (1) Must be set up for BIOS boot
  # (2) Only one disk is supported, must be boot drive with valid MBR
  # (3) Boot loader should use LVM or UUID to locate boot volume
  # https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/importingcustomimagelinux.htm#Importing_Custom_Linux_Images
  #
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = false;

  # Configure with LVM with disko???
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only


  # Open ports in the firewall for iSCSCI?
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # NOTE: Probably use boot.iscsi-initiator instead of services.openiscsi
  # since the boot device itself is an iSCSI volume
  #
  # services.openiscsi.enable = true;
  # services.openiscsi.name = "";

  # initiatorname.iscsi: InitiatorName=iqn.1988-12.com.oracle:0a4e0f3bcde
  #iscsiadm -m node -T iqn.2015-02.oracle.boot:uefi -o show | grep node.startup
  #iscsiadm -m node -T iqn.2015-02.oracle.boot:uefi -p 169.254.0.2:3260 -o update -n node.startup -v onboot
  #iscsiadm -m node -T iqn.2015-02.oracle.boot:uefi -o show | grep node.startup
}


{ pkgs
, username
, nix-index-database
, ...
}:
let
  unstable-packages = with pkgs.unstable; [

  ];

  stable-packages = with pkgs; [

  ];
in
{
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "24.05";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/zsh";
  };

  home.packages =
    stable-packages
    ++ unstable-packages
  ;

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableZshIntegration = true;
    #nix-index-database.comma.enable = true;

    # FIXME: include my zsh config
    zsh.enable = true;

    fzf.enable = true;
    fzf.enableZshIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;
    zoxide.options = [ "--cmd cd" ];
    broot.enable = true;
    broot.enableZshIntegration = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "davidpham@gmail.com";
      userName = "dayvidpham";
      extraConfig = {
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };
  };
}

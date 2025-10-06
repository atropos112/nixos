{
  lib,
  config,
  ...
}: {
  imports = [
    # Base
    ./desktop.nix
  ];

  environment.persistence."/persistent" = lib.mkIf config.atro.impermanence.enable {
    directories = [
      "/etc/NetworkManager/system-connections" # To store wifi passwords/connections  TODO: Figure out a way to generate this.
    ];
  };

  atro.hyprland.settings = [
    {
      priority = 3;
      value = {
        gesture = [
          "3, swipe, move"
          "4, horizontal, workspace"
        ];
      };
    }
  ];

  services = {
    # vpn mesh to connect to other devices
    tailscale = {
      extraUpFlags = [
        "--accept-routes"
      ];
    };

    # To provide information about the battery (e.g. how much % is left)
    upower = {
      enable = true;
    };

    # IX Server does a lot, used for keyboard settings here and to select the display manager (Login screen)
    # Note, the keyboard settings are for stuff it controls like GDM, onced logged in, DE (e.g. HyprLand) takes over and that can dictate the keyboard.
    xserver.xkb = {
      layout = "us,us";
      variant = "colemak,intl";
      options = "grp:win_space_toggle";
    };
  };
}

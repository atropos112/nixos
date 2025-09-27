{pkgs, ...}: {
  atro.hyprland.settings = [
    {
      priority = 2;
      value = {
        bind = [
          "$mainMod, Y, exec, kitty --class clipse -e 'clipse'"
        ];
        windowrulev2 = [
          "float,class:(clipse)" # ensure you have a floating window class set if you want this behavior
          "size 1000 1300,class:(clipse)" # set the size of the window as necessary
        ];
      };
    }
  ];

  home-manager.users.atropos.services.clipse = {
    enable = true;
    package = pkgs.clipse;
    historySize = 100;
    systemdTarget = "hyprland-session.target";
    imageDisplay.type = "kitty";
    allowDuplicates = false;
  };
}

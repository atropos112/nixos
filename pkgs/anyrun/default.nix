{pkgs, ...}: {
  home-manager.users.atropos.programs.anyrun = {
    enable = true;
    config = {
      # The horizontal position.
      # when using `fraction`, it sets a fraction of the width or height of the screen
      x.fraction = 0.5; # at the middle of the screen
      # The vertical position.
      y.fraction = 0.05; # at the top of the screen
      # The width of the runner.
      width.fraction = 0.3; # 30% of the screen

      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = null;

      plugins =
        [
          "libapplications"
          "libsymbols"
          "libkidex"
          "libwebsearch"
        ]
        |> builtins.map (plugin_name: "${pkgs.anyrun}/lib/${plugin_name}.so");
    };
    extraCss = builtins.readFile ./style.css;
  };
}

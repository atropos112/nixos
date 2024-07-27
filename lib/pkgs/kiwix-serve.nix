{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kiwix-tools
  ];

  systemd.user.services.kiwix-serving = {
    description = "Atuin Daemon";
    after = ["network.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "kiwix-serving" ''
        ${pkgs.kiwix-tools}/bin/kiwix-serve "/home/atropos/Sync/websites/"*.zim --port 8012 --blockexternal --address 127.0.0.1
      ''}"; # NOTE: That *.zim is intentionally outside of the quotes otherwise it will not be expanded for the app.
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}

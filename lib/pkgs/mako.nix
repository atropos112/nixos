{pkgs, ...}: {
  home-manager.users.atropos.services.mako = {
    enable = true;
    package = pkgs.mako;
    extraConfig = ''
      font=Inconsolata 14
      background-color=#151718
      text-color=#9FCA56
      border-color=#151718
      default-timeout=3000
      ignore-timeout=1

      [urgency=high]
      text-color=#CD3F45
      default-timeout=5000
    '';
  };

  # Notification daemon and cli tool
  environment.systemPackages = with pkgs; [
    mako
    libnotify
  ];
}

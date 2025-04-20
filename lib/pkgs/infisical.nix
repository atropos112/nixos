{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    infisical
  ];
  home-manager.users.atropos = {
    programs.zsh.shellAliases = {
      inf = "infisical run --recursive";
    };
    home.file.".infisical/infisical-config.json".text = ''
      {"loggedInUserEmail":"sv7n@pm.me","LoggedInUserDomain":"http://creds/api","loggedInUsers":[{"email":"sv7n@pm.me","domain":"http://creds/api"}],"domains":["http://creds"]}
    '';
  };
}

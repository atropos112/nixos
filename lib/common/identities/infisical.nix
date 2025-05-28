{
  config,
  pkgs,
  ...
}: let
  projectIdPath = "/home/atropos/.infisical/projectId";
  tokenPath = "/home/atropos/.infisical/token";
  infDefaultParams = "--token=$(cat ${tokenPath}) --projectId=$(cat ${projectIdPath}) --silent --telemetry=false";
  infLocalParams = "${infDefaultParams} --env local";
  infK8sParams = "${infDefaultParams} --env k8s";

  scriptNeedingPath = script: "${pkgs.writeShellScript "script-needing-path" ''
    if [ $# -ne 1 ]; then
      echo "Error: You must provide the path in the infisical secret to execute on. For example '/event_driven'."
      exit 1
    fi
    ${script} "$1";
  ''}";

  infSet = env: "${pkgs.writeShellScript "inf-set" ''
    if [ $# -ne 2 ]; then
      echo "Error: You are expected to provide path (first arg) and key=value (second arg) to set in infisical. For example '/event_driven ATRO_TEST_VALUE=1234'."
      exit 1
    fi

    infisical secrets set ${infDefaultParams} --env=${env} --path "$1" "$2";
  ''}";
in {
  environment.systemPackages = with pkgs; [
    infisical
  ];
  environment.sessionVariables.INFISICAL_API_URL = "http://creds";

  sops.secrets = {
    "infisical/token" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
      path = tokenPath;
    };
    "infisical/projectId" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
      path = projectIdPath;
    };
  };
  home-manager.users.atropos = {
    home.file.".infisical/infisical-config.json".text = ''
      {"loggedInUserEmail":"sv7n@pm.me","LoggedInUserDomain":"http://creds/api","loggedInUsers":[{"email":"sv7n@pm.me","domain":"http://creds/api"}],"domains":["http://creds"]}
    '';

    programs.zsh.shellAliases = {
      inf-run = "infisical run --recursive ${infLocalParams}";
      inf-list-dirs = scriptNeedingPath "infisical secrets folders get ${infLocalParams} --path ";
      inf-list-dirs-as-k8s = scriptNeedingPath "infisical secrets folders get ${infK8sParams} --path ";
      inf-get = scriptNeedingPath "infisical export ${infLocalParams} --path ";
      inf-get-as-k8s = scriptNeedingPath "infisical export ${infK8sParams} --path ";
      inf-set = infSet "local";
      inf-set-as-k8s = infSet "k8s";
      inf-set-both = "${pkgs.writeShellScript "inf-set-both" ''
        ${infSet "local"} "$1" "$2";
        ${infSet "k8s"} "$1" "$2";
      ''}";
    };
  };
}

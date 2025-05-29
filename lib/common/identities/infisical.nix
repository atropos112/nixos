{
  config,
  pkgs,
  ...
}: let
  tokenPath = config.sops.secrets."infisical/token".path;
  projectIdPath = config.sops.secrets."infisical/projectId".path;
  infParams = env: "--token=$(cat ${tokenPath}) --projectId=$(cat ${projectIdPath}) --silent --telemetry=false --env='${env}'";

  infisicalScriptWithPath = script: env: "${pkgs.writeShellScript "infisical-script-path" ''
    if [ $# -ne 1 ]; then
      echo "Error: You must provide the path in the infisical secret to execute on. For example '/event_driven'."
      exit 1
    fi
    infisical ${script} ${infParams env} --path="$1" ;
  ''}";

  infSet = env: "${pkgs.writeShellScript "inf-set" ''
    if [ $# -ne 2 ]; then
      echo "Error: You are expected to provide path (first arg) and key=value (second arg) to set in infisical. For example '/event_driven ATRO_TEST_VALUE=1234'."
      exit 1
    fi

    infisical secrets set ${infParams env} --path "$1" "$2";
  ''}";
in {
  environment.systemPackages = with pkgs; [
    infisical
  ];
  environment.sessionVariables = {
    INFISICAL_API_URL = "http://creds";
    ATRO_INFISICAL_PROJECT_ID_PATH = projectIdPath;
    ATRO_INFISICAL_TOKEN_PATH = tokenPath;
  };

  sops.secrets = {
    "infisical/token" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
    };
    "infisical/projectId" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
    };
  };
  home-manager.users.atropos = {
    programs.zsh.shellAliases = {
      inf-run = "infisical run --recursive ${infParams "local"}";
      inf-list-dirs = infisicalScriptWithPath "secrets folders get" "local";
      inf-list-dirs-as-k8s = infisicalScriptWithPath "secrets folders get" "k8s";
      inf-get = infisicalScriptWithPath "export" "local";
      inf-get-as-k8s = infisicalScriptWithPath "export" "k8s";
      inf-set = infSet "local";
      inf-set-as-k8s = infSet "k8s";
      inf-set-both = "${pkgs.writeShellScript "inf-set-both" ''
        ${infSet "local"} "$1" "$2";
        ${infSet "k8s"} "$1" "$2";
      ''}";
    };
  };
}

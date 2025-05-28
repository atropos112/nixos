{
  config,
  pkgs,
}: let
  clientIDPath = config.sops.secrets."infisical/clientID".path;
  clientSecretPath = config.sops.secrets."infisical/clientSecret".path;

  populateToken = "${pkgs.writeShellScript "infisicalPopulateToken" ''
    CLIENT_ID=$(cat ${clientIDPath})
    CLIENT_SECRET=$(cat ${clientSecretPath})
    API_URL="http://creds"

    TOKEN=$(${pkgs.infisical}/bin/infisical login --client-id $CLIENT_ID --client-secret $CLIENT_SECRET --api-url $API_URL --silent --plain --method universal-auth)
    echo $TOKEN > $HOME/.infisical/token
  ''}";
in {
  environment.sessionVariables.INFISICAL_API_URL = "http://creds";

  sops.secrets = {
    "infisical/clientSecret" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
    };
    "infisical/clientID" = {
      owner = config.users.users.atropos.name;
      group = config.users.users.atropos.name;
    };
  };

  home-manager.users.atropos.programs.zsh.shellAliases = {
    populate-infisical-token = populateToken;
  };
}

{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.atro.k3s;
  inherit (config.networking) hostName;
  isNvidiaEnabled = config.virtualisation.docker.enableNvidia;
in {
  options.atro.k3s = {
    enable = mkEnableOption "boot basics";
    role = mkOption {
      type = types.str;
    };
    serverAddr = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      if isNvidiaEnabled
      then [pkgs.k3s_1_28 pkgs.runc]
      else [pkgs.k3s_1_28];

    sops.secrets."k3s/token" = {};

    services.k3s = {
      enable = true;
      inherit (cfg) role serverAddr;
      configPath = mkIf (cfg.role == "server") ./config.yaml;
      tokenFile = config.sops.secrets."k3s/token".path;
      package = pkgs.k3s_1_28;
      extraFlags = "--node-name=${
        if hostName == "atroa21" # Special case... I know, I have regrets.
        then "atro21"
        else hostName
      }";
    };

    # NVIDIA SUPPORT BELOW
    # A hack...
    system.activationScripts.symlinks = mkIf isNvidiaEnabled {
      text = ''
        echo "-------------------------------------------------------------"
        echo "--------------- START MANUAL SECTION ------------------------"
        echo "-------------------------------------------------------------"
        homedir="/root"
        echo "****** homedir=$homedir"

        echo
        echo "------ symlinks ----"

        symlink() {
          local src="$1"
          local dest="$2"
          [[ -e "$src" ]] && {
              [[ -e $dest ]] && {
                  echo "****** OK: $dest exists"
              } || {
                  ln -s "$src" "$dest" || {
                      echo "****** ERROR: could not symlink $src to $dest"
                  }
                  echo "****** CHANGED: $dest updated"
              }
          } || {
              echo "****** ERROR: source $src does not exist"
          }
        }

        symlink "${./nvidia_containerd_config.toml}" \
                "/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl"

        echo "-------------------------------------------------------------"
        echo "--------------- END MANUAL SECTION --------------------------"
        echo "-------------------------------------------------------------"
      '';
    };
  };
}

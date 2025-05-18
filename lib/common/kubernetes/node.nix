_: let
  inherit (builtins) readFile concatStringsSep toFile;
  # Read both files and merge them.
  basicAlloy = readFile ../alloy/basic.alloy;
  k8sAlloy = readFile ../alloy/k8s.alloy;

  mergedAlloy = concatStringsSep "\n" [
    basicAlloy
    k8sAlloy
  ];
  mergedAlloyFile = toFile "merged.alloy" mergedAlloy;
in {
  imports = [
    ./longhorn.nix
    ../../modules/k3s
    ../default.nix
  ];

  atro.k3s = {
    enable = true;
    serverAddr = "https://11.0.0.11:6443";
  };

  # Needed for grafana alloy but also convininient.
  # Grafana alloy infact needs this to be called "kubeconfig" so it exists
  # in /run/secrets/kubeconfig as well
  sops.secrets."kubeconfig" = {
    owner = "atropos";
    path = "/home/atropos/.kube/config";
    mode = "0444"; # Read only
  };

  atro.fastfetch.extraModules = [
    {
      "type" = "command";
      "text" = "systemctl is-active k3s";
      "key" = "K3s";
    }
  ];

  services.alloy = {
    configPath = mergedAlloyFile;
  };
}

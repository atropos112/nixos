{
  config,
  pkgs,
  ...
}: let
  inherit (builtins) toFile toJSON;
  kubeConfigPath =
    if config.atro.impermanence.enable
    then "/persistent/home/atropos/.kube/config"
    else "/home/atropos/.kube/config";
in {
  imports = [
    ../../pkgs/k9s.nix
  ];

  environment.systemPackages = with pkgs; [
    # Nice regex capable log viewer
    stern

    # Kubernetes CLI tool
    kubectl

    # Coloured wrapper of kubectl
    kubecolor

    # Kubernetes helm, a yaml wrapper with templating
    kubernetes-helm

    # Kubernetes kubebuilder, a tool for building kubernetes operators
    kubebuilder

    # ArgoCD CLI
    argocd

    # Argo Workflows CLI
    argo

    # Krew, the plugin manager for kubectl
    krew

    # Local k8s testing
    kind

    # For interacting with cnpg
    kubectl-cnpg

    # Nice kubectl watch wrapper
    kubectl-klock
  ];

  # Needed for grafana alloy but also convininient.
  # Grafana alloy infact needs this to be called "kubeconfig" so it exists
  # in /run/secrets/kubeconfig as well
  sops.secrets."kubeconfig" = {
    owner = config.users.users.atropos.name;
    group = config.users.users.atropos.name;
    mode = "0400";
  };

  # Copy the kubeconfig from the secret to the home directory so it can be modified
  # by the user inbetween the runs. The modifications do not need to be persisted but
  # the file needs to be writable by the user.
  system.activationScripts.kubeconfig = "${pkgs.writeShellScript "kubeconfig" ''
    # So it can be modified in between the runs
    mkdir -p $(dirname ${kubeConfigPath})
    rm -f ${kubeConfigPath}
    cp ${config.sops.secrets."kubeconfig".path} ${kubeConfigPath}
    chmod 600 ${kubeConfigPath}
    chown atropos:users ${kubeConfigPath}
  ''}";

  environment.sessionVariables = {
    KUBECONFIG = kubeConfigPath;
    KUBECOLOR_CONFIG =
      {
        preset = "protanopia-dark";
        objFreshThreshold = "1h";
      }
      |> toJSON
      |> toFile "kubecolor.yaml";
  };

  home-manager.users.atropos.programs.zsh = {
    shellAliases = {
      k = "kubecolor";
      kubectl = "kubecolor";
      hui = "helm upgrade --install";
      kb = "kubebuilder";
      cnpg = "kubectl-cnpg";
      kvpn = "kubectl-kubevpn";
      kgpw = "kubectl-klock pods";
    };
    initContent = ''
      compdef kubecolor=kubectl
    '';
  };
}

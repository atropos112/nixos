{pkgs, ...}: {
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
    owner = "atropos";
    path = "/home/atropos/.kube/config";
    mode = "0444"; # Read only
  };

  home-manager.users.atropos = {
    home.file.".kube/color.yaml".text = ''
      kubectl: ${pkgs.kubectl}/bin/kubectl
      preset: protanopia-dark
      objFreshThreshold: 1h
    '';

    programs = {
      zsh = {
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
    };
  };
}

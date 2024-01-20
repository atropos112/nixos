{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Kubernetes CLI tool
    kubectl

    # Coloured wrapper of kubectl
    kubecolor

    # Kubernetes helm, a yaml wrapper with templating
    kubernetes-helm

    # Kubernetes kubebuilder, a tool for building kubernetes operators
    kubebuilder

    # ArgoCD
    argocd
  ];

  home-manager.users.atropos = {
    programs.zsh = {
      shellAliases = {
        k = "kubecolor";
        hui = "helm upgrade --install";
        kb = "kubebuilder";
      };
      initExtra = ''
        compdef kubecolor=kubectl
      '';
    };
  };
}

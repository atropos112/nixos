{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
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
  ];

  home-manager.users.atropos = {
    imports = [
      inputs.krewfile.homeManagerModules.krewfile
    ];

    programs.krewfile = {
      enable = true;
      krewPackage = pkgs.krew;
      plugins = [
        "cnpg"
        "neat"
        "pv-migrate"
        "browse-pvc"
        "gadget"
        "kor"
        "klock"
      ];
    };
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

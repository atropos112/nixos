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
  ];

  home-manager.users.atropos = {
    programs = {
      zsh = {
        shellAliases = {
          k = "kubecolor";
          hui = "helm upgrade --install";
          kb = "kubebuilder";
          cnpg = "kubectl-cnpg";
        };
        initExtra = ''
          compdef kubecolor=kubectl
        '';
      };

      k9s = {
        enable = true;
        skins = {
          catppuccin-mocha = ./k9s.catppuccin-mocha.yaml;
        };
        settings = {
          k9s = {
            ui = {
              skins = "catppuccin-mocha";
            };
          };
        };
        plugin = {
          plugins = {
            exec-sh-container = {
              shortCut = "Shift-E";
              description = "Exec into container";
              scopes = ["containers"];
              command = "kubectl";
              background = false;
              args = [
                "exec"
                "-it"
                "--context"
                "$CONTEXT"
                "-n"
                "$NAMESPACE"
                "$POD"
                "-c"
                "$NAME"
                "--"
                "sh"
              ];
            };
            debug = {
              shortCut = "Shift-D";
              description = "Add debug container";
              dangerous = true;
              scopes = ["containers"];
              command = "bash";
              background = false;
              confirm = true;
              args = [
                "-c"
                "kubectl debug -it --context $CONTEXT -n=$NAMESPACE $POD --target=$NAME --image=nicolaka/netshoot:v0.13 --share-processes -- bash"
              ];
            };
            remove-finalizers = {
              shortCut = "Ctrl-F";
              confirm = true;
              dangerous = true;
              scopes = ["all"];
              description = "Removes all finalizers from selected resource.";
              command = "kubectl";
              background = true;
              args = [
                "patch"
                "--context"
                "$CONTEXT"
                "--namespace"
                "$NAMESPACE"
                "$RESOURCE_NAME"
                "$NAME"
                "-p"
                "{\"metadata\":{\"finalizers\":null}}"
                "--type"
                "merge"
              ];
            };
            watch-events = {
              shortCut = "Shift-E";
              confirm = false;
              description = "Get Events";
              scopes = ["all"];
              command = "kubectl ";
              background = false;
              args = [
                "get"
                "events"
                "-A"
                "--watch"
              ];
            };
            json-logs = {
              shortCut = "Ctrl-L";
              description = "Json Pod logs";
              scopes = ["po"];
              command = "sh";
              background = false;
              args = [
                "-c"
                "kubectl logs -f \"$NAME\" -n \"$NAMESPACE\" --context \"$CLUSTER\" | jq ."
              ];
            };

            cnpg-backup = {
              shortCut = "b";
              description = "Backup";
              scopes = ["cluster"];
              command = "bash";
              confirm = true;
              background = false;
              args = [
                "-c"
                "kubectl-cnpg backup $NAME -n $NAMESPACE --context $CONTEXT |& less -R"
              ];
            };
            cnpg-hibernate-status = {
              shortCut = "h";
              description = "Hibernate status";
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg hibernate status $NAME -n $NAMESPACE --context $CONTEXT |& less -R"
              ];
            };
            cnpg-hibernate = {
              shortCut = "Shift-H";
              description = "Hibernate";
              confirm = true;
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg hibernate on $NAME -n $NAMESPACE --context $CONTEXT |& less -R"
              ];
            };
            cnpg-hibernate-off = {
              shortCut = "Shift-H";
              description = "Wake up hibernated cluster in this namespace";
              confirm = true;
              scopes = ["namespace"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg hibernate off $NAME -n $NAME --context $CONTEXT |& less -R"
              ];
            };
            cnpg-logs = {
              shortCut = "l";
              description = "Logs";
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg logs cluster $NAME -f -n $NAMESPACE --context $CONTEXT"
              ];
            };
            cnpg-psql = {
              shortCut = "p";
              description = "PSQL shell";
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg psql $NAME -n $NAMESPACE --context $CONTEXT"
              ];
            };
            cnpg-reload = {
              shortCut = "r";
              description = "Reload";
              confirm = true;
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg reload $NAME -n $NAMESPACE --context $CONTEXT |& less -R"
              ];
            };
            cnpg-restart = {
              shortCut = "Shift-R";
              description = "Restart";
              confirm = true;
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg restart $NAME -n $NAMESPACE --context $CONTEXT |& less -R"
              ];
            };
            cnpg-status = {
              shortCut = "s";
              description = "Status";
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg status $NAME -n $NAMESPACE --context $CONTEXT |& less -R"
              ];
            };
            cnpg-status-verbose = {
              shortCut = "Shift-S";
              description = "Status (verbose)";
              scopes = ["cluster"];
              command = "bash";
              background = false;
              args = [
                "-c"
                "kubectl-cnpg status $NAME -n $NAMESPACE --context $CONTEXT --verbose |& less -R"
              ];
            };
          };
        };
      };
    };
  };
}

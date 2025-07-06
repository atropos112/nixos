{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    k9s
  ];

  home-manager.users.atropos.programs.k9s = {
    enable = true;
    settings = {
      k9s = {
        ui = {
          skins = "catppuccin-mocha";
        };
      };
    };
    plugins = {
      exec-sh-container = {
        shortCut = "Shift-U";
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
        command = "kubecolor";
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

    skins = {
      catppuccin-mocha = {
        k9s = {
          body = {
            fgColor = "#cdd6f4";
            bgColor = "#1e1e2e";
            logoColor = "#cba6f7";
          };
          prompt = {
            fgColor = "#cdd6f4";
            bgColor = "#181825";
            suggestColor = "#89b4fa";
          };
          help = {
            fgColor = "#cdd6f4";
            bgColor = "#1e1e2e";
            sectionColor = "#a6e3a1";
            keyColor = "#89b4fa";
            numKeyColor = "#eba0ac";
          };
          frame = {
            title = {
              fgColor = "#94e2d5";
              bgColor = "#1e1e2e";
              highlightColor = "#f5c2e7";
              counterColor = "#f9e2af";
              filterColor = "#a6e3a1";
            };
            border = {
              fgColor = "#cba6f7";
              focusColor = "#b4befe";
            };
            menu = {
              fgColor = "#cdd6f4";
              keyColor = "#89b4fa";
              numKeyColor = "#eba0ac";
            };
            crumbs = {
              fgColor = "#1e1e2e";
              bgColor = "#eba0ac";
              activeColor = "#f2cdcd";
            };
            status = {
              newColor = "#89b4fa";
              modifyColor = "#b4befe";
              addColor = "#a6e3a1";
              pendingColor = "#fab387";
              errorColor = "#f38ba8";
              highlightColor = "#89dceb";
              killColor = "#cba6f7";
              completedColor = "#6c7086";
            };
          };
          info = {
            fgColor = "#fab387";
            sectionColor = "#cdd6f4";
          };
          views = {
            table = {
              fgColor = "#cdd6f4";
              bgColor = "#1e1e2e";
              cursorFgColor = "#313244";
              cursorBgColor = "#45475a";
              markColor = "#f5e0dc";
              header = {
                fgColor = "#f9e2af";
                bgColor = "#1e1e2e";
                sorterColor = "#89dceb";
              };
            };
            xray = {
              fgColor = "#cdd6f4";
              bgColor = "#1e1e2e";
              cursorColor = "#45475a";
              cursorTextColor = "#1e1e2e";
              graphicColor = "#f5c2e7";
            };
            charts = {
              bgColor = "#1e1e2e";
              chartBgColor = "#1e1e2e";
              dialBgColor = "#1e1e2e";
              defaultDialColors = [
                "#a6e3a1"
                "#f38ba8"
              ];
              defaultChartColors = [
                "#a6e3a1"
                "#f38ba8"
              ];
              resourceColors = {
                cpu = [
                  "#cba6f7"
                  "#89b4fa"
                ];
                mem = [
                  "#f9e2af"
                  "#fab387"
                ];
              };
            };
            yaml = {
              keyColor = "#89b4fa";
              valueColor = "#cdd6f4";
              colonColor = "#a6adc8";
            };
            logs = {
              fgColor = "#cdd6f4";
              bgColor = "#1e1e2e";
              indicator = {
                fgColor = "#b4befe";
                bgColor = "#1e1e2e";
                toggleOnColor = "#a6e3a1";
                toggleOffColor = "#a6adc8";
              };
            };
          };
          dialog = {
            fgColor = "#f9e2af";
            bgColor = "#9399b2";
            buttonFgColor = "#1e1e2e";
            buttonBgColor = "#7f849c";
            buttonFocusFgColor = "#1e1e2e";
            buttonFocusBgColor = "#f5c2e7";
            labelFgColor = "#f5e0dc";
            fieldFgColor = "#cdd6f4";
          };
        };
      };
    };
  };
}

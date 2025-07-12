{lib, ...}: let
  priorityList = import ../../utils/priorityList.nix {inherit lib;};
  inherit (priorityList) listToPriorityList;
in {
  atro = {
    alloy = {
      enable = true;
      configs = listToPriorityList 0 [
        ./otel.alloy
        ./metrics.alloy
        ./logs.alloy
      ];
    };

    fastfetch.modules = [
      {
        priority = 1007;
        value = {
          "type" = "command";
          "text" = "systemctl is-active alloy";
          "key" = "Alloy";
        };
      }
    ];
  };
}

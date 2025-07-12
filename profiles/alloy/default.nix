{lib, ...}: let
  priorityList = import ../../utils/priorityList.nix {inherit lib;};
  inherit (priorityList) listToPriorityList;
in {
  atro.alloy = {
    enable = true;
    configs = listToPriorityList 0 [
      ./otel.alloy
      ./metrics.alloy
      ./logs.alloy
    ];
  };
}

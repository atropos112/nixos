_: {
  imports = [
    ../kubernetes/node_agent.nix
    ./hardware.nix # Non standard, typically this is done from devices/<devicename>/hardware.nix but its the same across and always should be so importing it here instead.
  ];
}

{lib, ...}:
with lib; {
  fileType = types.attrsOp (type.submodule (_: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Should the device be included in the system?";
      };
      hostName = mkOption {
        type = types.str;
        description = "The hostname of the device, either IP or hostname (e.g. MagicDNS tailscale host name).";
      };
      shortHostName = mkOption {
        type = types.str;
        description = "The short version of the host name, e.g. rzr for atrorzr etc.";
      };
      rootPublicKey = mkOption {
        type = types.str;
        description = "The public key of the root device.";
      };
      atroposPublicKey = mkOption {
        type = types.str || types.null;
        description = "The public key of the atropos device.";
        default = null;
      };
    };
  }));
}

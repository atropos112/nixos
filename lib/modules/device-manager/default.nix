{lib, ...}:
with lib; let
  inherit (./device-type.nix) fileType;
in {
  options = {
    atro = {
      device = mkOption {
        type = fileType;
        default = {};
      };
    };
  };
}

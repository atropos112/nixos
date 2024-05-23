_: let
  # Public keys
  giant = {
    publicKeyAtropos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGqRdI3cwDuF/x1Hdr2AGmnNjTiU7hfXePqzlEMVn7F AtroGiant";
    publicKeyRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgtcKNMhw2C8xpbIVaOPfLBr9f93JXxLgp2LVr7CPlJ root@giant";
  };
  surface = {
    publicKeyAtropos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXzyzsV64asxyikHArB1HNNMg2R9YGoepmpBnGzZjkE atropos@AtroSurface";
    publicKeyRoot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNpaXlN8uspqQmrApGVQlgOSvhL1i22uFHllfyW/BqL root@surface";
  };
  juicessh = {
    publicKeyAtropos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLyjGaUMq7SWWUXdew/+E213/KCUDB1D59iEOhE6gyB atropos@giant";
  };
in {
  users = {
    mutableUsers = false;

    groups = {
      plugdev = {};
    };

    groups.atropos = {
      gid = 1000;
    };

    users = {
      root = {
        initialHashedPassword = "$6$IHPb2KGAOorX1aT.$JIRXgxboZAAO/4pKl.L7Cgavn7tF1cUCiIk5z8sJrglwkcFYqPWhUxQ7zmynikVVyc6X5AMxQ5kz89Aqzoqgy1";
        openssh = {
          authorizedKeys.keys = [
            giant.publicKeyRoot
            surface.publicKeyRoot
          ];
        };
      };
      atropos = {
        isNormalUser = true;
        uid = 1000;
        useDefaultShell = true;
        home = "/home/atropos";
        group = "atropos";
        createHome = true;
        extraGroups = ["wheel" "audio" "networkmanager" "docker" "input" "plugdev"];
        initialHashedPassword = "$6$IHPb2KGAOorX1aT.$JIRXgxboZAAO/4pKl.L7Cgavn7tF1cUCiIk5z8sJrglwkcFYqPWhUxQ7zmynikVVyc6X5AMxQ5kz89Aqzoqgy1";
        openssh = {
          authorizedKeys.keys = [
            giant.publicKeyAtropos
            surface.publicKeyAtropos
            juicessh.publicKeyAtropos
          ];
        };
      };
    };
  };
}

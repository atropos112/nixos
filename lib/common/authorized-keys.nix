_: {
  users = {
    groups = {
      plugdev = {};
    };

    groups.atropos = {};

    users = {
      root = {
        initialHashedPassword = "$6$IHPb2KGAOorX1aT.$JIRXgxboZAAO/4pKl.L7Cgavn7tF1cUCiIk5z8sJrglwkcFYqPWhUxQ7zmynikVVyc6X5AMxQ5kz89Aqzoqgy1";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgtcKNMhw2C8xpbIVaOPfLBr9f93JXxLgp2LVr7CPlJ root@giant"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNpaXlN8uspqQmrApGVQlgOSvhL1i22uFHllfyW/BqL root@surface"
        ];
      };
      atropos = {
        isNormalUser = true;
        useDefaultShell = true;
        home = "/home/atropos";
        group = "atropos";
        createHome = true;
        extraGroups = ["wheel" "audio" "networkmanager" "docker" "input" "plugdev"];
        initialHashedPassword = "$6$IHPb2KGAOorX1aT.$JIRXgxboZAAO/4pKl.L7Cgavn7tF1cUCiIk5z8sJrglwkcFYqPWhUxQ7zmynikVVyc6X5AMxQ5kz89Aqzoqgy1";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGqRdI3cwDuF/x1Hdr2AGmnNjTiU7hfXePqzlEMVn7F AtroGiant"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXzyzsV64asxyikHArB1HNNMg2R9YGoepmpBnGzZjkE atropos@AtroSurface"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLyjGaUMq7SWWUXdew/+E213/KCUDB1D59iEOhE6gyB atropos@giant"
        ];
      };
    };
  };
}

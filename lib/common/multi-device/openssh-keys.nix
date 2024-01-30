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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkHQRQeP0j4lU9K6Cw5ceY9c28WceGaDmh8QmIyhTlM root@atrosmol"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlpMXPxg3wXTympXkcasKdFqXTY92Fzz07yg+fRxeQR root@atrorzr"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBB5p1hG0kRNEmB4vXOkSN85ZTa2NU6mPrzXcyrFHkl root@atroa21"

          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKeA7Mz0ckZQ04jguI51HMuPlYvweGAPtwX/lfqeKfM root@atroopi1"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF4eTi4MF68bVZmCAblNzfVYYGGh+HbRpOC0WP8vG5Nf root@atroopi2"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILL4xN5R158EkD2PQRzEdYQs1TqqzEYXzBew0ZbhgYxE root@atroopi3"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+nD1OeKabX0pM8ZmTF/o6UxVKqKxXLS1XywX8VOr7l root@atroopi4"
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

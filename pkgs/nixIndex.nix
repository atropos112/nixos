{
  inputs,
  pkgs,
  ...
}: {
  # INFO:
  # nix-index allows one to do nix-locate to get packages providing a certain file in nixpkgs.
  # Example output:
  # $ nix-locate 'bin/hello'
  # hello.out                                        29,488 x /nix/store/bdjyhh70npndlq3rzmggh4f2dzdsj4xy-hello-2.10/bin/hello
  # linuxPackages_4_4.dpdk.examples               2,022,224 x /nix/store/jlnk3d38zsk0bp02rp9skpqk4vjfijnn-dpdk-16.07.2-4.4.52-examples/bin/helloworld
  # linuxPackages.dpdk.examples                   2,022,224 x /nix/store/rzx4k0pb58gd1dr9kzwam3vk9r8bfyv1-dpdk-16.07.2-4.9.13-examples/bin/helloworld
  # linuxPackages_4_10.dpdk.examples              2,022,224 x /nix/store/wya1b0910qidfc9v3i6r9rnbnc9ykkwq-dpdk-16.07.2-4.10.1-examples/bin/helloworld
  # linuxPackages_grsec_nixos.dpdk.examples       2,022,224 x /nix/store/2wqv94290pa38aclld7sc548a7hnz35k-dpdk-16.07.2-4.9.13-examples/bin/helloworld
  # camlistore.out

  # INFO:
  # It is also a good replacement for command-not-found functionality, and is infact better because it comes with
  # nix-index-database which is a prebuilt database that is updated regularly, so you don't have to build the index yourself.
  # This allows for
  # ❯ brave
  # The program 'brave' is currently not installed. You can install it
  # by typing:
  #   nix-env -iA nixpkgs.brave.out
  #
  # Or run it once with:
  #   nix-shell -p brave.out --run 'brave ...'

  home-manager.users.atropos = {
    imports = [
      inputs.nix-index-database.homeModules.nix-index
    ];
    programs = {
      zsh.initContent = ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';
      nix-index-database.comma.enable = true;
      nix-index = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
    };
  };

  # WARN: Make sure to disable the default command-not-found handler to avoid conflicts.
  # This line is here to cause the build to fail if I accidentally enable it somewhere forgetting about nix-index.
  programs.command-not-found.enable = false;
}

_: {
  imports = [
    ./basic.nix
  ];

  atro.impermanence = {
    global = {
      dirs = [
        "/var/lib/bluetooth" # Keep track of bluetooth devices
      ];
    };
    home = {
      ensureDirsExist = [
        "Sync" # For syncthing
        "scratch" # Scratch space for various things
      ];

      # INFO: User dirs are relative to their home directory i.e. .ssh -> /home/atropos/.ssh
      dirs = [
        ".wakatime" # Wakatime downloads some cache (some bins etc)
        "Sync" # Syncthing
        "projects" # Code projects
        "nixos" # NixOS config
        ".mozilla" # Firefox config
        ".ollama" # Ollama cache

        ".config/nvim" # Neovim config
        ".config/Element" # Element desktop config.
        ".config/Signal" # Signal desktop config.
        ".local/share/ZapZap" # Whatsapp for linux cache.
        ".cache/ZapZap" # Whatsapp for linux cache.
        ".cache/pre-commit" # Cache for pre-commit hooks
        ".config/github-copilot"
        ".config/sops/age" # Allowing atropos user read and edit the age keys
        ".config/wakatime" # waka time local bin's otherwise it wipes the password. There is a WAKATIME_HOME environment variable pointing to this dir.
        ".config/SuperSlicer" # SuperSlicer config

        ".local/share/nvim" # Neovim plugins and basic cache (Treesitter, etc.)
        ".local/share/Anki2" # Anki cache

        ".cache/nvim" # Neovim cache
      ];
    };
  };
}

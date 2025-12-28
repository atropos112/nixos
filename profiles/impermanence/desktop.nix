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
        "Sync" # Syncthing
        "projects" # Code projects
        "nixos" # NixOS config

        ".mozilla" # Firefox config
        ".ollama" # Ollama cache
        ".claude" # Claude config
        ".wakatime" # Wakatime downloads some cache (some bins etc)

        ".cache/ZapZap" # Whatsapp for linux cache.
        ".cache/prek" # Cache for prek (pre-commit) hooks
        ".cache/nvim" # Neovim cache

        ".config/nvim" # Neovim config
        ".config/Element" # Element desktop config.
        ".config/Signal" # Signal desktop config.
        ".config/github-copilot"
        ".config/sops/age" # Allowing atropos user read and edit the age keys
        ".config/wakatime" # waka time local bin's otherwise it wipes the password. There is a WAKATIME_HOME environment variable pointing to this dir.
        ".config/SuperSlicer" # SuperSlicer config

        ".local/share/nvim" # Neovim plugins and basic cache (Treesitter, etc.)
        ".local/share/Anki2" # Anki cache
        ".local/share/ZapZap" # Whatsapp for linux cache.
      ];
      files = [
        ".claude.json"
        ".claude.json.backup"
      ];
    };
  };
}

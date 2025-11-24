_: {
  virtualisation.oci-containers.containers.ollama = {
    image = "ollama/ollama";
    autoStart = true;
    ports = ["0.0.0.0:11434:11434"];
    volumes = [
      "/persistent/ollama/models:/root/.ollama/models"
    ];
    extraOptions = [
      "--device=nvidia.com/gpu=all"
    ];
  };

  # WARNING: I am hacking the implementation of the podman module here but I can't figure out a better way to do this.
  systemd.services.podman-ollama.after = ["network.target" "nvidia-container-toolkit-cdi-generator.service"];
}

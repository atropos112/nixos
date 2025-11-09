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
}

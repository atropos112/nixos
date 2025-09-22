_: let
  inherit (builtins) toFile toJSON;
  tracingApiServerConfig = {
    apiVersion = "apiserver.config.k8s.io/v1beta1";
    kind = "TracingConfiguration";
    endpoint = "otel:4317";
    samplingRatePerMillion = 1000000;
  };
  tracingApiServerConfigPath = tracingApiServerConfig |> toJSON |> toFile "tracing-config.json";
in {
  imports = [
    ./base.nix
    ./user.nix
  ];

  services.tailscale.extraUpFlags = [
    ''--advertise-routes="11.0.0.11/32"''
  ];

  services.k3s = {
    role = "server";
    # INFO: To initialize a new cluster, set this to true on the first server node only.
    # Once the cluster is set up, set this back to false
    # clusterInit = true
    configPath =
      {
        flannel-backend = "none";
        tls-san = "11.0.0.11";
        disable = [
          "servicelb"
          "traefik"
          "local-storage"
          "network-policy"
          "kube-proxy"
          "coredns"
        ];
        write-kubeconfig-mode = 644;
        kube-apiserver-arg = [
          "default-not-ready-toleration-seconds=30"
          "default-unreachable-toleration-seconds=30"
          "feature-gates=StatefulSetAutoDeletePVC=true"
          "tracing-config-file=${tracingApiServerConfigPath}"
        ];
        kube-controller-arg = [
          "node-monitor-period=20s"
          "node-monitor-grace-period=20s"
        ];
      }
      |> toJSON
      |> toFile "k3s-config.json";

    # INFO: This config is the same config as the one described in
    # https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/
    # Except you don't need the `apiVersion` and `kind` fields.
    extraKubeletConfig = {
      featureGates = {
        KubeletTracing = true;
        StatefulSetAutoDeletePVC = true;
      };
      tracing = {
        endpoint = "otel:4317";
        samplingRatePerMillion = 1000000;
      };
      maxPods = 250;
      nodeStatusUpdateFrequency = "5s";
      imageGCHighThresholdPercent = 25;
      imageGCLowThresholdPercent = 10;
    };
  };
}

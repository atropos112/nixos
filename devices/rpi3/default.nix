{lib, ...}: {
  system.stateVersion = lib.mkForce "24.05";
  imports = [
    ./hardware.nix
    ../../lib/common
    ./sdimage.nix
  ];

  services = {
    fluidd = {
      enable = true;
      nginx.locations."/webcam".proxyPass = "http://127.0.0.1:8080/stream";
    };
    nginx.clientMaxBodySize = "1000m";
    moonraker = {
      user = "root";
      enable = true;
      address = "0.0.0.0";
      settings = {
        octoprint_compat = {};
        history = {};
        authorization = {
          force_logins = false;
          cors_domains = [
            "*.local"
            "*.lan"
            "*://app.fluidd.xyz"
            "*://my.mainsail.xyz"
          ];
          trusted_clients = [
            "0.0.0.0/8"
          ];
        };
      };
    };
    klipper = {
      enable = true;
      settings = {
        mcu = {
          serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
        };
      };
      firmwares = {
        mcu = {
          enable = true;

          # Run klipper-genconf to generate this
          configFile = ./avr.cfg;
          # Serial port connected to the microcontroller
          # serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
        };
      };
    };
  };

  topology.self = {
    name = "rpi3";
    # interfaces = {
    #   tailscale0.addresses = ["100.122.175.74" "opi1"];
    #   eth0.addresses = ["9.0.0.5"];
    # };
  };
  networking = {
    # interfaces.eth0.macAddress = "7e:7d:fe:73:bf:61";
    hostName = "atrorpi3";
  };
}

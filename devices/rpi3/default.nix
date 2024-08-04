{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  system.stateVersion = lib.mkForce "24.05";
  imports = [
    ./hardware.nix
    ../../lib/common
    ./sdimage.nix
  ];

  services = {
    mainsail = {
      enable = true;
      nginx.locations."/webcam".proxyPass = "http://127.0.0.1:8080/stream";
    };
    nginx.clientMaxBodySize = "1000m";
    moonraker = {
      user = "root";
      enable = true;
      address = "0.0.0.0";
      settings = {
        authorization = {
          force_logins = false;
          cors_domains = [
            "*"
          ];
          trusted_clients = [
            "0.0.0.0/0"
          ];
        };
      };
    };
    klipper = {
      enable = true;
      package = pkgs-unstable.klipper;
      settings = {
        mcu = {
          serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
        };

        printer = {
          kinematics = "cartesian";
          max_velocity = 300;
          max_accel = 3000;
          max_z_velocity = 5;
          max_z_accel = 100;
        };

        stepper_x = {
          step_pin = "PC2";
          dir_pin = "PB9";
          enable_pin = "!PC3";
          microsteps = 16;
          rotation_distance = 40;
          endstop_pin = "^PA5";
          position_endstop = 0;
          position_max = 235;
          homing_speed = 50;
        };

        stepper_y = {
          step_pin = "PB8";
          dir_pin = "PB7";
          enable_pin = "!PC3";
          microsteps = 16;
          rotation_distance = 40;
          endstop_pin = "^PA6";
          position_endstop = 0;
          position_max = 235;
          homing_speed = 50;
        };

        stepper_z = {
          step_pin = "PB6";
          dir_pin = "!PB5";
          enable_pin = "!PC3";
          microsteps = 16;
          rotation_distance = 8;
          endstop_pin = "probe:z_virtual_endstop";
          position_max = 250;
        };

        extruder = {
          control = "pid";
          pid_Kp = 23.561;
          pid_Ki = 1.208;
          pid_Kd = 114.859;
          max_extrude_only_distance = 100.0;
          step_pin = "PB4";
          dir_pin = "PB3";
          enable_pin = "!PC3";
          microsteps = 16;
          gear_ratio = "3.5:1";
          rotation_distance = 26.359;
          nozzle_diameter = 0.400;
          filament_diameter = 1.750;
          heater_pin = "PA1";
          sensor_type = "EPCOS 100K B57560G104F";
          sensor_pin = "PC5";
          min_temp = 0;
          max_temp = 300;
          min_extrude_temp = 170;
          max_extrude_cross_section = 5;
        };

        bltouch = {
          sensor_pin = "^PB1";
          control_pin = "PB0";
          x_offset = -31.8;
          y_offset = -40.5;
          z_offset = 2.130;
          speed = 35;
          samples = 3;
          samples_result = "median";
          samples_tolerance = 0.0075;
          samples_tolerance_retries = 10;
          probe_with_touch_mode = true;
          stow_on_each_sample = false;
        };

        safe_z_home = {
          home_xy_position = "147, 154";
          speed = 75;
          z_hop = 10;
          z_hop_speed = 5;
          move_to_previous = true;
        };

        pause_resume = {
          recover_velocity = 25;
        };

        heater_bed = {
          heater_pin = "PA2";
          control = "pid";
          sensor_type = "EPCOS 100K B57560G104F";
          sensor_pin = "PC4";
          pid_Kp = 54.027;
          pid_Ki = 0.770;
          pid_Kd = 948.182;
          min_temp = 0;
          max_temp = 130;
        };

        fan = {
          pin = "PA0";
        };

        bed_screws = {
          screw1 = "25, 205";
          screw1_name = "rear left screw";
          screw2 = "195, 205";
          screw2_name = "rear right screw";
          screw3 = "195, 35";
          screw3_name = "front right screw";
          screw4 = "25, 35";
          screw4_name = "front left screw";
        };

        screws_tilt_adjust = {
          screw1 = "57, 229";
          screw1_name = "rear left screw";
          screw2 = "227, 229";
          screw2_name = "rear right screw";
          screw3 = "227, 70";
          screw3_name = "front right screw";
          screw4 = "57, 70";
          screw4_name = "front left screw";
          horizontal_move_z = 10;
          speed = 50;
          screw_thread = "CW-M4";
        };

        bed_mesh = {
          speed = 120;
          horizontal_move_z = 8;
          mesh_min = "15,15";
          mesh_max = "188,186";
          probe_count = "7,7";
          algorithm = "bicubic";
          fade_start = 1;
          fade_end = 10;
          fade_target = 0;
        };

        idle_timeout = {
          timeout = 1800;
        };

        input_shaper = {
          shaper_freq_x = 68.8;
          shaper_type_x = "mzv";
          shaper_freq_y = 44.4;
          shaper_type_y = "mzv";
        };
      };
      firmwares = {
        mcu = {
          enable = true;

          # Run klipper-genconf to generate this
          configFile = ./avr.cfg;
          # Serial port connected to the microcontroller
          serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
        };
      };
    };
  };
  systemd.services.ustreamer = {
    wantedBy = ["multi-user.target"];
    description = "uStreamer for video0";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.ustreamer}/bin/ustreamer --encoder=HW --persistent --drop-same-frames=30'';
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

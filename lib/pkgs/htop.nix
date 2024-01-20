{pkgs, ...}: {
  programs.htop = {
    enable = true;
    package = pkgs.htop;
    settings = {
      "fields" = "0 48 17 18 38 39 40 2 46 47 49 1";
      "sort_key" = 46;
      "sort_direction" = 1;
      "tree_sort_key" = 0;
      "tree_sort_direction" = 1;
      "hide_kernel_threads" = 1;
      "hide_userland_threads" = 0;
      "shadow_other_users" = 1;
      "show_thread_names" = 0;
      "show_program_path" = 1;
      "highlight_base_name" = 1;
      "highlight_megabytes" = 1;
      "highlight_threads" = 1;
      "highlight_changes" = 0;
      "highlight_changes_delay_secs" = 131;
      "find_comm_in_cmdline" = 1;
      "strip_exe_from_cmdline" = 1;
      "show_merged_command" = 0;
      "tree_view" = 1;
      "tree_view_always_by_pid" = 1;
      "header_margin" = 1;
      "detailed_cpu_time" = 0;
      "cpu_count_from_one" = 1;
      "show_cpu_usage" = 1;
      "show_cpu_frequency" = 1;
      "show_cpu_temperature" = 1;
      "degree_fahrenheit" = 0;
      "update_process_names" = 0;
      "account_guest_in_cpu_meter" = 0;
      "color_scheme" = 6;
      "enable_mouse" = 1;
      "delay" = 15;
      "left_meters" = "LeftCPUs Memory Systemd";
      "left_meter_modes" = "1 1 2";
      "right_meters" = "RightCPUs NetworkIO DiskIO";
      "right_meter_modes" = "1 2 2";
      "hide_function_bar" = 0;
    };
  };
}

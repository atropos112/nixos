{pkgs-stable, ...}: {
  services.adguardhome = {
    enable = true;
    # WARN: Have to use pkgs-stable as on the unstable branch the version is showing as ""
    # and as a result adguardhome-sync is refusing to sync.
    package = pkgs-stable.adguardhome;
    port = 3000; # The web interface port
    host = "0.0.0.0";
    mutableSettings = false; # Will allow external-dns to add some DNS rewrites etc.
    settings = {
      auth_attempts = 5;
      block_auth_min = 15;
      clients = {
        persistent = [];
        runtime_sources = {
          arp = true;
          dhcp = true;
          hosts = true;
          rdns = true;
          whois = true;
        };
      };
      dhcp = {
        dhcpv4 = {
          gateway_ip = "";
          icmp_timeout_msec = 1000;
          lease_duration = 86400;
          options = [];
          range_end = "";
          range_start = "";
          subnet_mask = "";
        };
        dhcpv6 = {
          lease_duration = 86400;
          ra_allow_slaac = false;
          ra_slaac_only = false;
          range_start = "";
        };
        enabled = false;
        interface_name = "";
        local_domain_name = "lan";
      };
      dns = {
        aaaa_disabled = false;
        allowed_clients = [];
        anonymize_client_ip = false;
        bind_hosts = ["0.0.0.0"];
        blocked_hosts = ["version.bind" "id.server" "hostname.bind"];
        bogus_nxdomain = [];
        bootstrap_dns = [];
        bootstrap_prefer_ipv6 = false;
        cache_optimistic = true;
        cache_size = 4194304;
        cache_ttl_max = 0;
        cache_ttl_min = 0;
        disallowed_clients = [];
        dns64_prefixes = [];
        edns_client_subnet = {
          custom_ip = "";
          enabled = false;
          use_custom = false;
        };
        enable_dnssec = false;
        fallback_dns = ["9.9.9.9" "8.8.8.8"];
        fastest_timeout = "1s";
        handle_ddr = true;
        hostsfile_enabled = true;
        ipset = [];
        ipset_file = "";
        local_ptr_upstreams = [];
        max_goroutines = 300;
        pending_requests = {enabled = true;};
        port = 53;
        private_networks = [];
        ratelimit = 0;
        ratelimit_subnet_len_ipv4 = 24;
        ratelimit_subnet_len_ipv6 = 56;
        ratelimit_whitelist = [];
        refuse_any = true;
        serve_http3 = false;
        serve_plain_dns = true;
        trusted_proxies = ["127.0.0.0/8" "::1/128"];
        upstream_dns = [
          "tcp://9.0.0.1:5553" # Opnsense local IP unbound
          "tcp://100.91.21.102:5553" # Opnsense tailscale IP unbound
          "tcp://192.168.68.53:5553" # Orth local IP unbound
          "tcp://100.124.150.44:5553" # Orth tailscale IP unbound
        ];
        upstream_dns_file = "";
        upstream_mode = "parallel";
        upstream_timeout = "10s";
        use_dns64 = false;
        use_http3_upstreams = false;
        use_private_ptr_resolvers = false;
      };
      filtering = {
        blocked_response_ttl = 20;
        blocked_services = {
          ids = [];
          schedule = {time_zone = "UTC";};
        };
        blocking_ipv4 = "";
        blocking_ipv6 = "";
        blocking_mode = "default";
        cache_time = 30;
        filtering_enabled = true;
        filters_update_interval = 72;
        parental_block_host = "family-block.dns.adguard.com";
        parental_cache_size = 1048576;
        parental_enabled = false;
        protection_disabled_until = null;
        protection_enabled = true;
        safe_fs_patterns = ["/opt/adguardhome/work/userfilters/*"];
        safe_search = {
          bing = true;
          duckduckgo = true;
          ecosia = true;
          enabled = false;
          google = true;
          pixabay = true;
          yandex = true;
          youtube = true;
        };
        safebrowsing_block_host = "standard-block.dns.adguard.com";
        safebrowsing_cache_size = 1048576;
        safebrowsing_enabled = false;
        safesearch_cache_size = 1048576;
      };
      filters = [];
      http = {
        address = "0.0.0.0:3000";
        pprof = {
          enabled = false;
          port = 6060;
        };
        session_ttl = "720h";
      };
      http_proxy = "";
      language = "en";
      log = {
        compress = false;
        enabled = true;
        file = "";
        local_time = false;
        max_age = 3;
        max_backups = 0;
        max_size = 100;
        verbose = false;
      };
      os = {
        group = "";
        rlimit_nofile = 0;
        user = "";
      };
      querylog = {
        dir_path = "";
        enabled = true;
        file_enabled = true;
        ignored = [];
        interval = "720h";
        size_memory = 1000;
      };
      schema_version = 23;
      statistics = {
        dir_path = "";
        enabled = true;
        ignored = [];
        interval = "168h";
      };
      theme = "auto";
      user_rules = [];
      users = [
        {
          name = "atropos";
          password = "$2a$10$CXo0cHXet2CFeQSiY53Dt.fklCsk.U3Kh2FeLRqSKfUb5C.tn5kz6";
        }
      ];
      whitelist_filters = [];
    };
  };
}

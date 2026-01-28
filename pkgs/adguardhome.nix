{
  pkgs,
  lib,
  config,
  ...
}: {
  atro.impermanence.global = lib.mkIf config.atro.impermanence.enable {
    dirs = [
      {
        directory = "/var/lib/private/AdGuardHome"; # Adguard home dir
        mode = "0700";
      }
    ];
  };

  services.adguardhome = {
    enable = true;
    package = pkgs.adguardhome;
    port = 3000; # The web interface port
    host = "0.0.0.0";
    mutableSettings = true; # Will allow external-dns to add some DNS rewrites etc.
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
      filters = [
        {
          enabled = false; # This blocks fc.yahoo.com, it is yahoo's ad server but things lik yfinance stop working when this is enabled.
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_24.txt";
          name = "1Hosts (Lite)";
          id = 1766475041;
        }
        {
          enabled = false; # This blocks all kinds of stuff for no good reason like mcr.microsoft.com, cgr.dev and jupiterbroadcasting.com so disabled.
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_70.txt";
          name = "1Hosts (Xtra)";
          id = 1766475042;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1766475043;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt";
          name = "AdGuard DNS Popup Hosts filter";
          id = 1766475044;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt";
          name = "AWAvenue Ads Rule";
          id = 1766475045;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
          name = "Dan Pollock's List";
          id = 1766475046;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_34.txt";
          name = "HaGeZi's Normal Blocklist";
          id = 1766475047;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt";
          name = "HaGeZi's Pro Blocklist";
          id = 1766475048;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt";
          name = "HaGeZi's Pro++ Blocklist";
          id = 1766475049;
        }
        {
          enabled = false; # Blocks log.tailscale.com and that's not desireable.
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_49.txt";
          name = "HaGeZi's Ultimate Blocklist";
          id = 1766475050;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
          name = "Malicious URL Blocklist (URLHaus)";
          id = 1766475051;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_5.txt";
          name = "OISD Blocklist Small";
          id = 1766475052;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt";
          name = "uBlock₀ filters – Badware risks";
          id = 1766475053;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
          name = "OISD Blocklist Big";
          id = 1766475054;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
          name = "The Big List of Hacked Malware Web Sites";
          id = 1766475055;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";
          name = "Peter Lowe's Blocklist";
          id = 1766475056;
        }
        {
          enabled = false; # Blocks websites like what is my ip etc.
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_69.txt";
          name = "ShadowWhisperer Tracking List";
          id = 1766475057;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_31.txt";
          name = "Stalkerware Indicators List";
          id = 1766475058;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_42.txt";
          name = "ShadowWhisperer's Malware List";
          id = 1766475059;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt";
          name = "Steven Black's List";
          id = 1766475060;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_10.txt";
          name = "Scam Blocklist by DurableNapkin";
          id = 1766475061;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt";
          name = "Dandelion Sprout's Anti Push Notifications";
          id = 1766475062;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_6.txt";
          name = "Dandelion Sprout's Game Console Adblock List";
          id = 1766475063;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt";
          name = "Phishing Army";
          id = 1766475064;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_45.txt";
          name = "HaGeZi's Allowlist Referral";
          id = 1766475065;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";
          name = "NoCoin Filter List";
          id = 1766475066;
        }
        {
          enabled = false; # For ISO downloading purposes this is disabled.
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_46.txt";
          name = "HaGeZi's Anti-Piracy Blocklist";
          id = 1766475067;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_68.txt";
          name = "HaGeZi's URL Shortener Blocklist";
          id = 1766475068;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_67.txt";
          name = "HaGeZi's Apple Tracker Blocklist";
          id = 1766475069;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt";
          name = "HaGeZi's Threat Intelligence Feeds";
          id = 1766475070;
        }
        {
          enabled = false; # Blocks backoffice.bsport.io which breaks functionality of my 12x3gym.co.uk
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_47.txt";
          name = "HaGeZi's Gambling Blocklist";
          id = 1766475071;
        }
        {
          enabled = false; # Blocks a lot of useful services like webhooks.fyi,
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_56.txt";
          name = "HaGeZi's The World's Most Abused TLDs";
          id = 1766475072;
        }
        {
          enabled = false; # Blocks pkgs.tailscale.com and thats not desiriable.
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_52.txt";
          name = "HaGeZi's Encrypted DNS/VPN/TOR/Proxy Bypass";
          id = 1766475073;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_66.txt";
          name = "HaGeZi's OPPO & Realme Tracker Blocklist";
          id = 1766475074;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_54.txt";
          name = "HaGeZi's DynDNS Blocklist";
          id = 1766475075;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_61.txt";
          name = "HaGeZi's Samsung Tracker Blocklist";
          id = 1766475076;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_71.txt";
          name = "HaGeZi's DNS Rebind Protection";
          id = 1766475077;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_65.txt";
          name = "HaGeZi's Vivo Tracker Blocklist";
          id = 1766475078;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_55.txt";
          name = "HaGeZi's Badware Hoster Blocklist";
          id = 1766475079;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_63.txt";
          name = "HaGeZi's Windows/Office Tracker Blocklist";
          id = 1766475080;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt";
          name = "Dandelion Sprout's Anti-Malware List";
          id = 1766475081;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_60.txt";
          name = "HaGeZi's Xiaomi Tracker Blocklist";
          id = 1766475082;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
          name = "Phishing URL Blocklist (PhishTank and OpenPhish)";
          id = 1766475083;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt";
          name = "Perflyst and Dandelion Sprout's Smart-TV Blocklist";
          id = 1766475084;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_14.txt";
          name = "POL: Polish filters for Pi-hole";
          id = 1766475085;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_57.txt";
          name = "ShadowWhisperer's Dating List";
          id = 1766475086;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_62.txt";
          name = "Ukrainian Security Filter";
          id = 1766475087;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_41.txt";
          name = "POL: CERT Polska List of malicious domains";
          id = 1766475088;
        }
      ];
      dns = {
        aaaa_disabled = false;
        anonymize_client_ip = false;
        bind_hosts = ["0.0.0.0"];
        cache_optimistic = false; # Serve stale cache if upstream times out, flaky sometimes
        cache_size = 4194304;
        cache_ttl_max = 30; # Has to reasonably small as most devices have their own caching DNS resolver anyway
        cache_ttl_min = 1;
        allowed_clients = [
          "100.64.0.0/10" # Tailscale
          "127.0.0.1/24" # Localhost
          "9.0.0.0/8" # Home network at my place
          "192.168.0.0/16" # Home network at parents
        ];
        disallowed_clients = [];
        dns64_prefixes = [];
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
        ratelimit = 0;
        ratelimit_subnet_len_ipv4 = 24;
        ratelimit_subnet_len_ipv6 = 56;
        refuse_any = true;
        serve_http3 = false;
        serve_plain_dns = true;
        trusted_proxies = ["127.0.0.0/8" "::1/128"];
        upstream_dns = [
          "127.0.0.1:5553" # Unbound local
          "[/ts.net/]100.100.100.100" # Tailscale MagicDNS for all .ts.net domains
        ];
        upstream_mode = "parallel"; # Not relevant with only 1 upstream (plus one for ts.net)
        upstream_timeout = "10s";
        use_dns64 = false;
        use_http3_upstreams = false;
        use_private_ptr_resolvers = false;
      };
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
      schema_version = 29;
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

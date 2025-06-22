{
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) map;
  inherit (lib) mkForce;
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    languagePacks = [
      "en-GB"
      "en-US"
    ];

    /*
    ---- POLICIES ----
    */
    # Check about:policies#documentation for options.
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = false;
      DisableAccounts = false;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      # DNSOverHTTPS = {
      #   Enabled = true;
      # };
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
      SearchBar = "unified"; # alternative: "separate"

      /*
      ---- EXTENSIONS ----
      */
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".

      ExtensionSettings = mkForce (
        # Default behaviour for all extensions not listed here.
        # [
        #   {
        #     # Disable all extensions by default.
        #     # "*".installation_mode = "blocked";
        #   }
        # ] ++
        # My selected extensions
        map (x: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${x}/latest.xpi";
          installation_mode = "force_installed";
        }) [
          # Add custom search engine (to add Searx)
          "{af37054b-3ace-46a2-ac59-709e4412bec6}"

          # Read Aloud:
          "{ddc62400-f22d-4dd3-8b4a-05837de53c2e}"

          # uBlock Origin:
          "uBlock0@raymondhill.net"

          # Dark Reader:
          "addon@darkreader.org"

          # FreshRSS Checker:
          "freshrss-checker@addons.mozilla.org"

          # Bitwarden Password Manager:
          "{446900e4-71c2-419f-a6a7-df9c091e268b}"

          # Vimium
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}"

          # SponsorBlock
          "sponsorBlocker@ajay.app"

          # Duplicate Tabs Closer
          "jid0-RvYT2rGWfM8q5yWxIxAHYAeo5Qg@jetpack"

          # SimpleLogin
          "addon@simplelogin"

          # Tree Style Tabs
          "treestyletab@piro.sakura.ne.jp"

          # TST More Tree Commands (Creating folders, etc.)
          "tst-more-tree-commands@piro.sakura.ne.jp"

          # Kiwix JS
          "kiwix-html5-listed@kiwix.org"

          # SingleFile
          "{531906d3-e22f-4a6c-a102-8057b88a1a63}"

          # Redirector
          "redirector@einaregilsson.com"

          # Keepa - Amazon Price Tracker
          "amptra@keepa.com"

          # TST Folder Expand Collapse
          "tst-folder-expand-collapse@pale-ed"
        ]
      );
      /*
      ---- PREFERENCES ----
      */
      # Check about:config for options.
      Preferences =
        lib.mapAttrs (_: value: {
          Value = value;
          Locked = true;
        }) {
          # INFO: Personal preference settings
          "browser.aboutConfig.showWarning" = false; # Disable about:config warning
          "browser.startup.page" = 3; # 0=blank, 1=home, 2=last visited, 3=resume previous session
          "browser.startup.homepage" = "https://atro.xyz"; # Set homepage
          "browser.newtabpage.enabled" = false; # Disable new tab page (true being the firefox homepage)

          "extensions.screenshots.disabled" = true;
          "browser.topsites.contile.enabled" = false;
          "browser.formfill.enable" = false;
          "browser.search.suggest.enabled" = false;
          "browser.search.suggest.enabled.private" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.showSearchSuggestionsFirst" = false;
          "browser.tabs.unloadOnLowMemory" = true;
          "browser.tabs.warnOnClose" = true;

          ## INFO: Security and privacy settings

          # Set default search engine: DuckDuckGo
          "browser.urlbar.placeholderName" = "Kagi";
          # "browser.urlbar.placeholderName" = "Searx";

          # Set default permissions
          # * Location, Camera, Microphone, VR
          # * 0=always ask (default), 1=allow, 2=block.
          "permissions.default.geo" = "2";
          "permissions.default.camera" = "2";
          "permissions.default.microphone" = "0";
          "permissions.default.desktop-notification" = "0";
          "permissions.default.xr" = "2";

          # Fingerprints
          "privacy.resistFingerprinting.letterboxing" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.pbmode" = true;

          # Disable spellchecker
          "layout.spellcheckDefault" = "1";

          # Custom DNS over HTTPS
          "network.trr.custom_uri" = "https://dns.atro.xyz:9443/dns-query";
          "network.trr.mode" = 3; # Max protection use TRR first, complain if can't and fallback on user accept only
          "network.trr.uri" = "https://dns.atro.xyz:9443/dns-query";
          "network.dns.disableIPv6" = true; # Disable IPv6
          "doh-rollout.disable-heuristics" = true;

          # Use HTTPS ONLY MODE
          "dom.security.https_only_mode_ever_enabled" = true;

          # Custom Enhance Tracking Protection
          "browser.contentblocking.category" = "Custom";

          # Disable form autofill
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;

          # Disable built-in bullshit features
          "extensions.pocket.enabled" = false;
          "identity.fxaccounts.enabled" = false;
          "extensions.fxmonitor.enabled" = false;
          "browser.messaging-system.whatsNewPanel.enabled" = false;
          "dom.forms.autocomplete.formautofill" = false;
          "beacon.enabled" = false;

          # Disable internal password manager
          "signon.rememberSignons" = false;
          "signon.management.page.breach-alerts.enabled" = false;

          # Disable WebRTC
          "media.peerconnection.enabled" = false;

          # Protect private IP even in TRUSTED scenarios after you grant device access
          "media.peerconnection.ice.no_host" = true;

          # Disable GMP (Gecko Media Plugins)
          "media.gmp-provider.enabled" = false;

          # Disable Geolocation
          "geo.provider.ms-windows-location" = false; # Windows
          "geo.provider.use_corelocation" = false; # MacOS
          "geo.provider.use_geoclue" = false; # Linux

          # Disable about:addons recomended extensions (uses Google Analytics)
          "extensions.getAddons.showPane" = false; # Hidden pref
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.shopping.experience2023.enabled" = false; # default is already false

          # Activity stream
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
          "browser.newtabpage.activity-stream.system.showSponsored" = false;
          "browser.newtabpage.activity-stream.default.sites" = ""; # Disable default sites

          # Disable studies
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          "app.shield.optoutstudies.enabled" = false;

          # No crash reporting
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

          # Disable captive portal detection
          # As per https://www.eff.org/deeplinks/2017/08/how-captive-portals-interfere-wireless-security-and-privacy
          # these suck.
          "captivedetect.canonicalURL" = "";
          "network.captive-portal-service.enabled" = false;
          "network.connectivity-service.enabled" = false;

          # Block implicit outbound [not explicitly asked for - e.g. clicked on]
          "network.prefetch-next" = false;
          "network.dns.disablePrefetch" = true;
          "network.dns.disablePrefetchFromHTTPS" = true;
          "network.predictor.enabled" = false;
          "network.predictor.enable-prefetch" = false;
          "network.http.speculative-parallel-limit" = 0;
          "browser.places.speculativeConnect.enabled" = false;

          "network.gio.supported-protocols" = ""; # Disable GIO as a potential bypass vector

          # Disable toolkit telemetry
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";
        };
    };
  };
}

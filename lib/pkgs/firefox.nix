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

          # TST Search box
          "@tst-search" # Not super confident about this one will revisit

          # Kiwix JS
          "kiwix-html5-listed@kiwix.org"

          # SingleFile
          "{531906d3-e22f-4a6c-a102-8057b88a1a63}"

          # Redirector
          "redirector@einaregilsson.com"

          # Keepa - Amazon Price Tracker
          "amptra@keepa.com"
        ]
      );
      /*
      ---- PREFERENCES ----
      */
      # Check about:config for options.
      Preferences = {
        "browser.contentblocking.category" = {
          Value = "strict";
          Status = "locked";
        };
        "extensions.pocket.enabled" = "lock-false";
        "extensions.screenshots.disabled" = "lock-true";
        "browser.topsites.contile.enabled" = "lock-false";
        "browser.formfill.enable" = "lock-false";
        "browser.search.suggest.enabled" = "lock-false";
        "browser.search.suggest.enabled.private" = "lock-false";
        "browser.urlbar.suggest.searches" = "lock-false";
        "browser.urlbar.showSearchSuggestionsFirst" = "lock-false";
        "browser.newtabpage.activity-stream.feeds.section.topstories" = "lock-false";
        "browser.newtabpage.activity-stream.feeds.snippets" = "lock-false";
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = "lock-false";
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = "lock-false";
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = "lock-false";
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = "lock-false";
        "browser.newtabpage.activity-stream.showSponsored" = "lock-false";
        "browser.newtabpage.activity-stream.system.showSponsored" = "lock-false";
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = "lock-false";
      };
    };
  };
}

{ config, pkgs, lib, ... }:
{

    programs.firefox.enable = true;
    programs.firefox = {
      # nativeMessagingHosts = [ pkgs.gnome-browser-connector ];

      package = pkgs.firefox-esr; # Use ESR firefox.

      profiles.hardened = {
	id = 0;
	name = "hardened";

	isDefault = true;
	extensions = with pkgs; [];

        search.force = true;
	search.default = "DuckDuckGo";
        search.privateDefault = "DuckDuckGo";
      };

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
	DisableFirefoxAccounts = true;
	DisableAccounts = true;
	DisableFirefoxScreenshots = true;
	OverrideFirstRunPage = "";
	OverridePostUpdatePage = "";
	DontCheckDefaultBrowser = true;
	DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
	DisplayMenuBar = "default-off"; 	 # alternatives: "always", "never" or "default-on"
	SearchBar = "unified";             # alternative: "separate"

	ExtensionSettings = {
	  "*".installation_mode = "blocked"; # blocks all addons except the ones specified below

	  #
	  # To add additional extensions, find it on addons.mozilla.org, find
	  # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
	  # ```sh
	  # mkdir addon
	  # cd addon
	  # curl -Lo addon.xpi https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi
	  # unzip addon.xpi
	  # jq .browser_specific_settings.gecko.id manifest.json    # => "uBlock0@raymondhill.net"
	  # jq .applications.gecko.id manifest.json
	  # ```

	  "uBlock0@raymondhill.net" = { # ublock.
	    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
	    installation_mode = "force_installed";
	  };

	  "{54e2eb33-18eb-46ad-a4e4-1329c29f6e17}" = { # block website
	    install_url = "https://addons.mozilla.org/firefox/downloads/latest/block-website/latest.xpi";
	    installation_mode = "force_installed";
	  };


/*
	  "myallychou@gmail.com" = {    # youtube unhook.
	    install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
	    installation_mode = "force_installed";
	  };

	  "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {  # return youtube dislikes
	    install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
	    installation_mode = "force_installed";
	  };
*/
	};

	# Check about:config for options.
	Preferences = { 
	  # Copy & Paste from BetterFox user.js: https://github.com/yokoffing/BetterFox
	  "content.notify.interval" = 100000;

	  "gfx.canvas.accelerated.cache-items" = 4096;
	  "gfx.canvas.accelerated.cache-size" = 512;
	  "gfx.content.skia-font-cache-size" = 20;

	  "browser.cache.jsbc_compression_level" = 3;

	  "media.memory_cache_max_size" = 65536;
	  "media.cache_readahead_limit" = 7200;
	  "media.cache_resume_threshold" = 3600;

	  "image.mem.decode_bytes_at_a_time" = 32768;

	  "network.buffer.cache.size" = 262144;
	  "network.buffer.cache.count" = 128;
	  "network.http.max-connections" = 1800;
	  "network.http.max-persistent-connections-per-server" = 10;
	  "network.http.max-urgent-start-excessive-connections-per-host" = 5;
	  "network.http.pacing.requests.enabled" = false;
	  "network.dnsCacheExpiration" = 3600;
	  "network.dns.max_high_priority_threads" = 8;
	  "network.ssl_tokens_cache_capacity" = 10240;

	  "network.dns.disablePrefetch" = true;
	  "network.prefetch-next" = false;
	  "network.predictor.enabled" = false;

	  /****************************************************************************
	   * SECTION: SECUREFOX                                                       *
	  ****************************************************************************/
	  /** TRACKING PROTECTION ***/
	  "browser.contentblocking.category" = "strict";
	  "urlclassifier.trackingSkipURLs" = "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com";
	  "urlclassifier.features.socialtracking.skipURLs" = "*.instagram.com, *.twitter.com, *.twimg.com";
	  "network.cookie.sameSite.noneRequiresSecure" = true;
	  "browser.download.start_downloads_in_tmp_dir" = true;
	  "browser.helperApps.deleteTempFileOnExit" = true;
	  "browser.uitour.enabled" = false;
	  "privacy.globalprivacycontrol.enabled" = true;

	  /** OCSP & CERTS / HPKP ***/
	  "security.OCSP.enabled" = 0;
	  "security.remote_settings.crlite_filters.enabled" = true;
	  "security.pki.crlite_mode" = 2;

	  /** SSL / TLS ***/
	  "security.ssl.treat_unsafe_negotiation_as_broken" = true;
	  "browser.xul.error_pages.expert_bad_cert" = true;
	  "security.tls.enable_0rtt_data" = false;

	  /** DISK AVOIDANCE ***/
	  "browser.privatebrowsing.forceMediaMemoryCache" = true;
	  "browser.sessionstore.interval" = 60000;

	  /** SHUTDOWN & SANITIZING ***/
	  "privacy.history.custom" = true;

	  /** SEARCH / URL BAR ***/
	  "browser.search.separatePrivateDefault.ui.enabled" = true;
	  "browser.urlbar.update2.engineAliasRefresh" = true;
	  "browser.search.suggest.enabled" = false;
	  "browser.urlbar.suggest.quicksuggest.sponsored" = false;
	  "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
	  "browser.formfill.enable" = false;
	  "security.insecure_connection_text.enabled" = true;
	  "security.insecure_connection_text.pbmode.enabled" = true;
	  "network.IDN_show_punycode" = true;

	  /** HTTPS-FIRST POLICY ***/
	  "dom.security.https_first" = true;
	  "dom.security.https_first_schemeless" = true;

	  /** PASSWORDS ***/
	  "signon.formlessCapture.enabled" = false;
	  "signon.privateBrowsingCapture.enabled" = false;
	  "network.auth.subresource-http-auth-allow" = 1;
	  "editor.truncate_user_pastes" = false;

	  /** MIXED CONTENT + CROSS-SITE ***/
	  "security.mixed_content.block_display_content" = true;
	  "security.mixed_content.upgrade_display_content" = true;
	  "security.mixed_content.upgrade_display_content.image" = true;
	  "pdfjs.enableScripting" = false;
	  "extensions.postDownloadThirdPartyPrompt" = false;

	  /** HEADERS / REFERERS ***/
	  "network.http.referer.XOriginTrimmingPolicy" = 2;

	  /** CONTAINERS ***/
	  "privacy.userContext.ui.enabled" = true;

	  /** WEBRTC ***/
	  "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
	  "media.peerconnection.ice.default_address_only" = true;

	  /** SAFE BROWSING ***/
	  "browser.safebrowsing.downloads.remote.enabled" = false;

	  /** MOZILLA ***/
	  "permissions.default.desktop-notification" = 2;
	  "permissions.default.geo" = 2;
	  "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
	  "permissions.manager.defaultsUrl" = "";
	  "webchannel.allowObject.urlWhitelist" = "";

	  /** TELEMETRY ***/
	  "datareporting.policy.dataSubmissionEnabled" = false;
	  "datareporting.healthreport.uploadEnabled" = false;
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
	  "browser.ping-centre.telemetry" = false;
	  "browser.newtabpage.activity-stream.feeds.telemetry" = false;
	  "browser.newtabpage.activity-stream.telemetry" = false;

	  /** EXPERIMENTS ***/
	  "app.shield.optoutstudies.enabled" = false;
	  "app.normandy.enabled" = false;
	  "app.normandy.api_url" = "";

	  /** CRASH REPORTS ***/
	  "breakpad.reportURL" = "";
	  "browser.tabs.crashReporting.sendReport" = false;
	  "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

	  /** DETECTION ***/
	  "captivedetect.canonicalURL" = "";
	  "network.captive-portal-service.enabled" = false;
	  "network.connectivity-service.enabled" = false;

	  /** MOZILLA UI ***/
	  "browser.privatebrowsing.vpnpromourl" = "";
	  "extensions.getAddons.showPane" = false;
	  "extensions.htmlaboutaddons.recommendations.enabled" = false;
	  "browser.discovery.enabled" = false;
	  "browser.shell.checkDefaultBrowser" = false;
	  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
	  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
	  "browser.preferences.moreFromMozilla" = false;
	  "browser.tabs.tabmanager.enabled" = false;
	  "browser.aboutConfig.showWarning" = false;
	  "browser.aboutwelcome.enabled" = false;

	  /** THEME ADJUSTMENTS ***/
	  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
	  "browser.compactmode.show" = true;
	  "browser.display.focus_ring_on_anything" = true;
	  "browser.display.focus_ring_style" = 0;
	  "browser.display.focus_ring_width" = 0;
	  "layout.css.prefers-color-scheme.content-override" = 2;

	  /** COOKIE BANNER HANDLING ***/
	  "cookiebanners.service.mode" = 1;
	  "cookiebanners.service.mode.privateBrowsing" = 1;

	  /** FULLSCREEN NOTICE ***/
	  "full-screen-api.transition-duration.enter" = "0 0";
	  "full-screen-api.transition-duration.leave" = "0 0";
	  "full-screen-api.warning.delay" = -1;
	  "full-screen-api.warning.timeout" = 0;

	  /** URL BAR ***/
	  "browser.urlbar.suggest.calculator" = true;
	  "browser.urlbar.unitConversion.enabled" = true;
	  "browser.urlbar.trending.featureGate" = false;

	  /** NEW TAB PAGE ***/
	  "browser.newtabpage.activity-stream.feeds.topsites" = false;
	  "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

	  /** POCKET ***/
	  "extensions.pocket.enabled" = false;

	  /** DOWNLOADS ***/
	  "browser.download.always_ask_before_handling_new_types" = true;
	  "browser.download.manager.addToRecentDocs" = false;

	  /** PDF ***/
	  "browser.download.open_pdf_attachments_inline" = true;

	  /** TAB BEHAVIOR ***/
	  "browser.bookmarks.openInTabClosesMenu" = false;
	  "browser.menu.showViewImageInfo"  = true;
	  "findbar.highlightAll" = true;
	  "layout.word_select.eat_space_to_next_word" = false;

	  /** REMOVE BOOKMARKS ***/
	  "browser.toolbars.bookmarks.visibility" = "never";

	  /** ALWAYS RESTORE PREVIOUS SESSION ***/
	  "browser.sessionstore.resume_from_crash" = true;
	  "browser.sessionstore.max_tabs_undo" = 50;
	  "browser.startup.page" = 3;

	  /** MIDDLE MOUSE SCROLL ***/
	  "general.autoScroll" = true;
	};
      };
    };

}


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";

  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-23.11"; # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
  });

  gnome-extensions-packages = with pkgs.gnomeExtensions; [
    appindicator
    dash-to-panel
    custom-hot-corners-extended
  ];

  default-extensions-packages = with pkgs.gnomeExtensions; [
    launch-new-instance
  ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      nixvim.nixosModules.nixvim
    ];

  # Cannot have that in hardware-configuration.nix, because it might be overwritten by NixOS.
  fileSystems."/home/paul.dobrogost/.cache" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "rw" "uid=1001" "gid=100" "nodev" "nosuid" "noexec" ]; 
    };

  fileSystems."/tmp" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "rw" "nodev" "nosuid" ]; 
    };

  swapDevices = [
    { device = "/var/swapfile"; size = 8 * 1024; priority = 0; }
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/29a9086f-d8df-47bc-b685-b4f32247b9c5"; # This is a partition where swap file resides. In my case this is root.
  boot.kernelParams = [
    # 
    # Offset of a swap file.
    # Calculated using ... filefrag -v /var/swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}' ... thx Arch Wiki.
    # 
    "resume_offset=21401600"
  ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Minsk";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GDM Display Manager
  services.xserver.displayManager = {
    gdm.enable = true;

    defaultSession = "gnome";
  };

  # Enable GNOME.
  services.xserver.desktopManager.gnome.enable = true;

  # Enable Hyprland
  programs.hyprland.enable = true;
  programs.hyprland = {
    enableNvidiaPatches = true;
    xwayland.enable = true;
  };

  services.xserver.excludePackages = with pkgs; [
    xterm
  ]; 

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us,ru";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable daemon to sync browser profile directories to RAM.
  # This will load ~/.mozilla/firefox/... profiles in RAM.
  services.psd.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enables Hybrid graphics for desktop.
  services.switcherooControl.enable = true;

  # zram
  zramSwap.enable        = true;
  zramSwap.algorithm     = "zstd";
  zramSwap.priority      = 100;  # We want this priority to be higher then those of swapDevice.
  zramSwap.memoryPercent = 100;

  # sysctl optimizations for zram
  boot.kernel.sysctl."vm.swappiness" = 180;
  boot.kernel.sysctl."vm.watermark_boost_factor" = 0;
  boot.kernel.sysctl."vm.watermark_scale_factor" = 125;
  boot.kernel.sysctl."vm.page-cluster" = 0;

  # Disable some default packages.
  programs.nano.enable = false;

  programs.dconf.enable = true;
  programs.dconf.profiles.gdm.databases = [{
    settings = {
      "org/gnome/desktop/peripherals/touchpad" = {
	tap-to-click = true;
      };

      "org/gnome/desktop/interface" = {
        cursor-theme = "Bibata-Modern-Classic";
        show-battery-percentage = true;
      };
    };
  }];

  programs.steam.enable = true;

  programs.nixvim.enable = true;
  programs.nixvim = {
    options = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 2;        # Tab width should be 2
    };

    colorschemes.gruvbox.enable = true;
    globals.mapleader = " ";

    plugins = {
      lightline.enable = true;

      telescope.enable = true;

      treesitter.enable = true;

      oil.enable = true;

      lsp.servers = {
	ccls.enable = true;

        rust-analyzer = {
	  enable = true;
	  installCargo = true;
	  installRustc = true;
	};
      };

      nvim-cmp.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      lightline-gruvbox-vim
    ];
  };

  home-manager.users."paul.dobrogost" = {config, ...}: {
    home.stateVersion = "23.11";

    imports = [
      ./firefox.nix
      ./hyprland.nix
    ];

    home.username = "paul.dobrogost";
    home.homeDirectory = "/home/paul.dobrogost";

    home.pointerCursor.package = pkgs.bibata-cursors;
    home.pointerCursor.name = "Bibata-Modern-Classic";
    home.pointerCursor.size = 24;

    home.sessionVariables = {
      EDITOR = "nvim";

      # Arch Wiki says to do this to get dark theme for all applications.
      # https://wiki.archlinux.org/title/Dark_mode_switching
      # GTK_THEME = "Adwaita:dark";   # Turn this off, because Gnome doesn't like it.
      QT_STYLE_OVERRIDE = "Adwaita-Dark";
    };

    home.shellAliases = {
      vi  = "nvim";
      vim = "nvim";
    };

    # SessionPath and sessionVariables creates a hm-session file that must be sourced:
    # Beware, it puts it in .profile, not in the .bashrc!
    programs.bash.enable = true;
    programs.bash = {
      # I dunno what that is, some weird hack for `sessionVariables`
      initExtra = ''
	. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      '';
    };

    programs.git.enable = true;
    programs.git = {
      userName = "Павел Доброгост";
      userEmail = "mr.dobrogost02@mail.ru";
    };

    programs.obs-studio.enable = true;
    programs.obs-studio = {
      # package = ...;
      # plugins = [ pkgs... ];
    };

    programs.htop.enable = true;
    programs.htop = {
      settings = {
	tree_view = 1;

      }  // (with config.lib.htop; leftMeters [
          (bar "LeftCPUs")
          (bar "Memory")
          (bar "Zram") # (bar "Swap")

        ]) // (with config.lib.htop; rightMeters [
          (bar "RightCPUs")
          (text "Tasks")
          (text "LoadAverage")
          (text "Uptime")
          # (text "Systemd")
        ]);
    };

    programs.alacritty.enable = true;
    programs.alacritty = {
      # package = ...;
      settings = {

	window = {
	  decorations  = "None";
	  startup_mode = "Maximized";
	};

	mouse = {
	  hide_when_typing = true;
	};
      };
    };

    programs.zathura.enable = true;
    programs.zathura = {
      extraConfig = ''
	set selection-clipboard clipboard
	set guioptions none
      '';
    };

    programs.tmux.enable = true;
    programs.tmux = {
      extraConfig = ''
	unbind C-b
	set -g prefix `
	bind-key ` last-window
	bind-key e send-prefix

	set -g mouse on

	set -g status-position bottom
	set -g status-bg colour234
	set -g status-fg colour137
	set -g status-left \'\'
	set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
	set -g status-right-length 50
	set -g status-left-length 20

	setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
	setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
      '';
    };

    programs.wofi.enable = true;
    programs.wofi = {
      settings = {
	allow_markup = true;
	width = 1000;
      };

      # style = ''string'';
    };

    gtk.enable = true;
    gtk = {
      cursorTheme.package = pkgs.bibata-cursors;
      cursorTheme.name = "Bibata-Modern-Classic";
      cursorTheme.size = 24;
    };

    dconf.settings = {
      "org/gnome/desktop/wm/keybindings" = {
	switch-to-workspace-1  = ["<Control>1"];
	switch-to-workspace-2  = ["<Control>2"];
	switch-to-workspace-3  = ["<Control>3"];
	switch-to-workspace-4  = ["<Control>4"];
	switch-to-workspace-5  = ["<Control>5"];
	switch-to-workspace-6  = ["<Control>6"];
	switch-to-workspace-7  = ["<Control>7"];
	switch-to-workspace-8  = ["<Control>8"];
	switch-to-workspace-9  = ["<Control>9"];
	switch-to-workspace-10 = ["<Control>0"];
        move-to-workspace-1    = ["<Control><Shift>1"];
        move-to-workspace-2    = ["<Control><Shift>2"];
        move-to-workspace-3    = ["<Control><Shift>3"];
        move-to-workspace-4    = ["<Control><Shift>4"];
        move-to-workspace-5    = ["<Control><Shift>5"];
        move-to-workspace-6    = ["<Control><Shift>6"];
        move-to-workspace-7    = ["<Control><Shift>7"];
        move-to-workspace-8    = ["<Control><Shift>8"];
        move-to-workspace-9    = ["<Control><Shift>9"];
        move-to-workspace-10   = ["<Control><Shift>0"];

	switch-input-source          = ["<Shift>Alt_L"];
	switch-input-source-backward = ["<Alt>Shift_L"];

	close = ["<Control>d"];
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = false;
	auto-maximize = true;
      };

      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        two-finger-scrolling-enabled = true;
        tap-to-click = true;
      };

      "org/gnome/shell" = {
        disabled-extensions = [];
        enabled-extensions = map (extension: extension.extensionUuid) (gnome-extensions-packages ++ default-extensions-packages);
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
	custom-keybindings = [
	  "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
	];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
	name    = "New Terminal";
	binding = "<Control>Return";
	command = "alacritty";
      };

      "org/gnome/nautilus/preferences".default-folder-viewer = "list-view";

      "org/gnome/shell/extensions/dash-to-panel" = {
	# Even when we are not using multiple panels on multiple monitors,
	# the extension still creates them in the config, so we set the same
	# configuration for each (up to 2 monitors).
	panel-positions = builtins.toJSON (lib.genAttrs [ "0" "1" ] (x: "LEFT"));
	panel-sizes = builtins.toJSON (lib.genAttrs [ "0" "1" ] (x: 48));
	panel-element-positions = builtins.toJSON (lib.genAttrs [ "0" "1" ] (x: [
	  { element = "showAppsButton"; visible = true; position = "stackedTL"; }
	  { element = "activitiesButton"; visible = false; position = "stackedTL"; }
	  { element = "dateMenu"; visible = true; position = "stackedTL"; }
	  { element = "leftBox"; visible = true; position = "stackedTL"; }
	  { element = "taskbar"; visible = true; position = "centerMonitor"; }
	  { element = "centerBox"; visible = false; position = "centered"; }
	  { element = "rightBox"; visible = true; position = "stackedBR"; }
	  { element = "systemMenu"; visible = true; position = "stackedBR"; }
	  { element = "desktopButton"; visible = false; position = "stackedBR"; }
	]));
	multi-monitors = false;
	show-apps-icon-file = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
	show-apps-icon-padding = 4;
	focus-highlight-dominant = true;
	dot-size = 0;
	appicon-padding = 4;
	appicon-margin = 0;
	trans-use-custom-opacity = true;
	trans-panel-opacity = 0.25;
	show-favorites = false;
	group-apps = true;
	isolate-workspaces = false;
	hide-overview-on-startup = false;
	intellihide = true;
      };

      # "/org/gnome/shell/extensions/custom-hot-corners-extended/misc".panel-menu-enable = false;
      # "/org/gnome/shell/extensions/custom-hot-corners-extended/monitor-0-top-left-0".action = "show-overview";

      "io/missioncenter/MissionCenter" = {
	apps-page-sorting-column = "None";
	apps-page-sorting-order  = "None";

	performance-page-cpu-graph = 2;
	performance-page-kernel-times = true;
	performance-selected-page = "cpu";

	update-speed = 2;

	window-selected-page = "performance-page";

	window-width = 1920;
	window-height = 1080;
      };

      # "/io/missioncenter/MissionCenter".performance-page-kernel-times = true; # Show kernel times too
      # "/io/missioncenter/MissionCenter".performance-page-cpu-graph = 2;       # Show all CPUs
    };

    xdg.enable = true;
    xdg.desktopEntries = {

      # Overrides for desktop entries that are listed in `~/.nix-profile/share/applications/`.
      # We can also generate a new entry ourselves if we really need to:
      nvim = { name = "Neovim"; noDisplay = true; };
      htop = { name = "Htop"; noDisplay = true; };

      obsidian = {
	name = "Obsidian";

        # --disable-gpu, because otherwise obsidian refuses to work on Wayland :)
	# `prefersNonDefaultGPU = true` also didn't work, damn you NVIDIA.
	# Bug: https://github.com/NixOS/nixpkgs/issues/244742
	exec = "obsidian --disable-gpu %U";
	icon = "${unstable.pkgs.obsidian}/share/icons/hicolor/128x128/apps/obsidian.png";
      };

      "org.pwmt.zathura" = {
	name = "Zathura";
	exec = "zathura --mode=fullscreen %U";
        icon = "${pkgs.zathura}/share/icons/hicolor/scalable/apps/org.pwmt.zathura.svg";
	mimeType = [ "application/pdf" ];
      };

      "Milton" = {
	name = "Milton";
	exec = "wine \"c:\\Program Files\\Milton\\Milton.exe\"";
      };
    };
  };

  users.users.gdm.packages = with pkgs; [
    bibata-cursors
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."paul.dobrogost" = {
    isNormalUser = true;
    description = "Paul Dobrogost";
    extraGroups = [ "networkmanager" "wheel" "video" "kvm" ];
    packages = (with pkgs; [
      neofetch
      # valgrind
      # premake5
      # make
      # cmake
      # meson

      p7zip   # .7z

      sysstat
      # nvtop

      killall
      unzip   # .tar.gz.
      jq


      # A style to bend Qt applications to look like they belong into GNOME Shell
      adwaita-qt

      freetube
      ani-cli

      gamemode
      gamescope
      wineWowPackages.wayland
      # wineWowPackages.stable
      mangohud
      goverlay

      # Using unstable channel, because obsidian devs can't update their dependencies in time and we get EOL electron.
      unstable.obsidian

      # IDE for C++
      # jetbrains.rider  # Requires a license.

      telegram-desktop
      discord
      slack

      # Desktop reader for Reddit.
      # giara  # It is so bad, you have no idea.

      # Task manager for GNOME.
      mission-center

      # Timer for GNOME.
      gnome.pomodoro

      riseup-vpn
      libreoffice-fresh
      # thunderbird
      deluge-gtk
      newsflash
      vlc
      mpv # Is used with ani-cli and freetube.

    ]) ++ (gnome-extensions-packages
    );
  };

  # Android emulation
  virtualisation.waydroid.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [];


  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "paul_dobrogost";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  environment.gnome.excludePackages = with pkgs; [
    snapshot
    gnome-tour
    gnome-console
    gnome-connections
    gnome-text-editor

    gnome.gnome-system-monitor
    gnome.gnome-contacts
    gnome.gnome-logs

    gnome.simple-scan
    gnome.epiphany
    gnome.devhelp
    gnome.geary
    gnome.totem
    gnome.yelp

    # TODO: remove all unnecessary pkgs.gnomeExtensions.???
    # gnomeExtensions.auto-move-windows
    # gnomeExtensions.applications-menu
    # gnomeExtensions.light-style
    # gnomeExtensions.launch-new-instance
    # gnomeExtensions.native-window-placement
    # gnomeExtensions.places-status-indicator
    # gnomeExtensions.removable-drive-menu
    # gnomeExtensions.screenshot-window-sizer
    # gnomeExtensions.user-themes
    # gnomeExtensions.window-list
    # gnomeExtensions.windownavigator
    # gnomeExtensions.workspace-indicator
  ];

  environment.sessionVariables = {
    # Enable Wayland for Electron apps.
    NIXOS_OZONE_WL = "1";
  };

  environment.shellAliases = {
    down      = "systemctl poweroff";
    reboot    = "systemctl reboot";
    suspend   = "systemctl suspend";
    hibernate = "systemctl hibernate";
    uefi      = "systemctl reboot --firmware-setup";
  };

    # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  system.autoUpgrade.enable = true;
  system.autoUpgrade = {
    allowReboot = false;
    dates = "daily";

    flags = [ # `systemctl status nixos-upgrade.service` to print build logs.
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
    ];

    randomizedDelaySec = "45min"; # Don't start updating while booting in.
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 5d";
    randomizedDelaySec = "45min";
  };
}


{ pkgs, user, host, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${host}";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  security.rtkit.enable = true;

  #==== Programs ============================================
  programs = {

    mtr.enable = true; #mtr is a network diagnostic tool that combines ping and traceroute into one program.

    dconf.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  #==== Services ============================================
  services = {
    auto-cpufreq.enable = true;
    tlp.enable = true;

    #== Logind
    logind = {
      lidSwitch = "ignore";
    };

    #== Pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    gnome = {
      gnome-keyring.enable = true;
    };

    #== Xorg
    xserver = {
      enable = true;

      layout = "us";

      excludePackages = [
        pkgs.xterm
      ];

      libinput = {
        enable = true;
        mouse = {
          accelProfile = "flat";
        };
        touchpad = {
          tapping = true;
          scrollMethod = "twofinger";
          naturalScrolling = true;
          accelProfile = "adaptive";
          disableWhileTyping = true;
        };
      };

      displayManager = {
        startx.enable = false;
        lightdm = {
          enable = true;
          background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
          greeters = {
            gtk = {
              theme = {
                name = "Dracula";
                package = pkgs.dracula-theme;
              };
              cursorTheme = {
                name = "Dracula-cursors";
                package = pkgs.dracula-theme;
                size = 16;
              };
            };
          };
        };
        defaultSession = "none+i3";
        setupCommands = "
        MONITOR='eDP-1'
        ${pkgs.xorg.xrandr}/bin/xrandr --output $MONITOR --off
        ";
      };

      desktopManager = {
        xterm.enable = false;
      };

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };
  };

  #==== User ============================================
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # initialPassword = "password";
  };


  #==== Environment ============================================
  environment = {
    systemPackages = with pkgs;
      [
        home-manager
        neovim
        xdg-user-dirs
        #== utils
        ripgrep
        rsync
        wget
        p7zip
        unrar
        zip
        unzip
      ];
  };

  #==== System ============================================
  system.stateVersion = "23.05";

  #==== Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}

{ config, inputs, lib, pkgs, ... }:
let
  wallpaperDir = "/home/tillo/Pictures/wallpaper";
  localPluginSourceDir = "${config.home.homeDirectory}/projects/noctalia-plugins";
  defaultWallpaper = "${wallpaperDir}/joel-vodell-TApAkERW5pQ-unsplash.jpg";

  noctaliaSettings = {
  backdrop = {
    blur_intensity = 0.0;
    enabled = true;
    tint_intensity = 0.0;
  };
  bar = {
    default = {
      background_opacity = 0.6299999859184027;
      capsule_group = [
        {
          fill = "surface_variant";
          id = "g1";
          members = [
            "clipboard"
            "clock"
          ];
          opacity = 1.0;
          padding = 6.0;
        }
      ];
      center = [
        "group:g1"
        "cat"
      ];
      end = [
        "notifications"
        "volume"
        "brightness"
        "battery"
        "control-center"
        "session"
      ];
      font_weight = 700;
      margin_edge = 0;
      margin_ends = 0;
      padding = 12;
      radius = 0;
      scale = 1.15;
      start = [
        "launcher"
        "keybind-cheatsheet"
        "wallpaper"
        "cpu"
        "temp"
        "network"
        "ram"
      ];
      thickness = 43;
      widget_spacing = 9;
    };
  };
  desktop_widgets = {
    enabled = true;
    grid = {
      cell_size = 16;
      major_interval = 4;
      visible = true;
    };
    schema_version = 2;
    widget = {
      desktop-widget-0000000000000001 = {
        box_height = 128.0;
        box_width = 192.0;
        cx = 2400.0;
        cy = 144.0;
        output = "DP-2";
        rotation = 0.0;
        settings = {
          center_text = false;
          clock_style = "digital";
        };
        type = "clock";
      };
      desktop-widget-0000000000000002 = {
        box_height = 128.0;
        box_width = 192.0;
        cx = 2400.0;
        cy = 288.0;
        output = "DP-2";
        rotation = 0.0;
        settings = {
          background_color = "surface_variant";
          display = "graph";
          show_label = true;
          stat = "cpu_usage";
          stat2 = "cpu_temp";
        };
        type = "sysmon";
      };
      desktop-widget-0000000000000003 = {
        box_height = 128.0;
        box_width = 192.0;
        cx = 2400.0;
        cy = 432.0;
        output = "DP-2";
        rotation = 0.0;
        settings = {
          background_color = "surface_variant";
          display = "graph";
          show_label = true;
          stat = "ram_pct";
          stat2 = "swap_pct";
        };
        type = "sysmon";
      };
      desktop-widget-0000000000000004 = {
        box_height = 128.0;
        box_width = 192.0;
        cx = 2400.0;
        cy = 576.0;
        output = "DP-2";
        rotation = 0.0;
        settings = {
          background_color = "surface_variant";
          display = "graph";
          network_speed_compact = false;
          network_speed_unit = "kb";
          show_label = true;
          stat = "net_rx";
          stat2 = "net_tx";
        };
        type = "sysmon";
      };
      desktop-widget-0000000000000006 = {
        box_height = 144.0;
        box_width = 304.0;
        cx = 2344.0;
        cy = 1128.0;
        output = "DP-2";
        rotation = 0.0;
        settings = {
          background = true;
          background_color = "surface";
          background_opacity = 0.8;
          background_padding = 10;
          background_radius = 12;
          color = "on_surface";
          font_family = "";
          hide_when_no_media = true;
          layout = "horizontal";
          shadow = true;
        };
        type = "media_player";
      };
      desktop-widget-0000000000000007 = {
        box_height = 992.0;
        box_width = 1264.0;
        cx = 2248.0;
        cy = 1128.0;
        output = "DP-2";
        rotation = 0.0;
        settings = {
          background = false;
          bar_width = 0.30000000000000004;
          bloom_intensity = 0.9;
          inner_diameter = 0.30000000000000004;
          rotation_speed = 0.1;
          secondary_color = "on_tertiary";
          sensitivity = 1.3;
          visualization_mode = "bars_rings";
        };
        type = "fancy_audio_visualizer";
      };
    };
    widget_order = [
      "desktop-widget-0000000000000007"
      "desktop-widget-0000000000000001"
      "desktop-widget-0000000000000002"
      "desktop-widget-0000000000000003"
      "desktop-widget-0000000000000004"
      "desktop-widget-0000000000000006"
    ];
  };
  dock = {
    active_monitor_only = true;
    background_opacity = 0.7299999836832285;
    icon_size = 33;
    layer = "overlay";
    radius = 25;
  };
  idle = {
    behavior = {
      lock = {
        action = "lock";
        enabled = true;
        timeout = 600;
      };
      lock-and-suspend = {
        action = "lock_and_suspend";
        enabled = true;
        timeout = 900;
      };
      screen-off = {
        action = "screen_off";
        enabled = false;
        timeout = 660;
      };
    };
    behavior_order = [
      "lock"
      "screen-off"
      "lock-and-suspend"
    ];
  };
  location = {
    auto_locate = true;
  };
  lockscreen = {
    wallpaper = "/home/tillo/Pictures/wallpaper/joel-vodell-TApAkERW5pQ-unsplash.jpg";
  };
  lockscreen_widgets = {
    enabled = false;
    grid = {
      cell_size = 16;
      major_interval = 4;
      visible = true;
    };
    schema_version = 2;
    widget = {
      "lockscreen-login-box@DP-2" = {
        box_height = 196.0;
        box_width = 810.0;
        cx = 1280.0;
        cy = 1258.0;
        output = "DP-2";
        rotation = 0.0;
        settings = {
          background_color = "surface_variant";
          background_opacity = 0.88;
          background_radius = 12.0;
          center_password_text = false;
          input_opacity = 1.0;
          input_radius = 6.0;
          layout = "regular";
          show_caps_lock = true;
          show_keyboard_layout = true;
          show_login_button = true;
          show_media = true;
          show_session_buttons = true;
          show_unlock_hint = true;
          show_weather = true;
        };
        type = "login_box";
      };
      "lockscreen-login-box@DP-3" = {
        box_height = 196.0;
        box_width = 810.0;
        cx = 1280.0;
        cy = 1258.0;
        output = "DP-3";
        rotation = 0.0;
        settings = {
          background_color = "surface_variant";
          background_opacity = 0.88;
          background_radius = 12.0;
          center_password_text = false;
          input_opacity = 1.0;
          input_radius = 6.0;
          layout = "regular";
          show_caps_lock = true;
          show_keyboard_layout = true;
          show_login_button = true;
          show_media = true;
          show_session_buttons = true;
          show_unlock_hint = true;
          show_weather = true;
        };
        type = "login_box";
      };
    };
    widget_order = [
      "lockscreen-login-box@DP-2"
      "lockscreen-login-box@DP-3"
    ];
  };
  nightlight = {
    enabled = true;
  };
  osd = {
    position = "top_right";
  };
  plugin_settings = {
    "gustav0ar/drive-health" = {
      system_collector_enabled = true;
    };
  };
  plugins = {
    enabled = [
      "luixbits/casio-deck"
      "noctalia/bitwarden"
      "kenn/keybind-cheatsheet"
      "noctalia/bongocat"
      "gustav0ar/drive-health"
      "cleboost/ssh-launcher"
    ];
    source = [
      {
        auto_update = true;
        kind = "git";
        location = "https://github.com/noctalia-dev/official-plugins";
        name = "official";
      }
      {
        auto_update = true;
        kind = "git";
        location = "https://github.com/noctalia-dev/community-plugins";
        name = "community";
      }
      {
        auto_update = false;
        kind = "path";
        location = "/home/tillo/projects/noctalia-plugins";
        name = "local-dev";
      }
    ];
  };
  shell = {
    animation = {
      speed = 1.5;
    };
    app_icon_color = "primary";
    avatar_path = "/home/tillo/Pictures/wallpaper/asa-rodger-B8xmtKWLrVo-unsplash.jpg";
    corner_radius_scale = 0.45000000670552254;
    font_family = "Hurmit Nerd Font Mono";
    launcher = {
      app_grid = true;
      compact = true;
    };
    niri_overview_type_to_launch_enabled = true;
    panel = {
      clipboard_placement = "attached";
      launcher_placement = "floating";
      launcher_session_search = true;
      transparency_mode = "glass";
    };
    polkit_agent = true;
    screen_corners = {
      size = 39;
    };
    settings_show_advanced = true;
    shadow = {
      alpha = 0.5;
    };
    ui_scale = 1.35;
  };
  theme = {
    builtin = "Dracula";
    community_palette = "Occult Umbral";
    source = "wallpaper";
    templates = {
      builtin_ids = [
        "btop"
        "gtk3"
        "gtk4"
        "helix"
        "hyprland"
        "kcolorscheme"
        "kitty"
        "mango"
        "niri"
        "qt"
        "scroll"
        "starship"
        "wezterm"
      ];
      community_ids = [
        "neovim"
        "obsidian"
        "heroiclauncher"
        "prismlauncher"
        "steam"
        "yazi"
      ];
    };
  };
  wallpaper = {
    automation = {
      enabled = true;
      interval_seconds = 600;
    };
    default = {
      path = "/home/tillo/Pictures/wallpaper/lobostudio-hamburg-E-3GL4-7P5k-unsplash.jpg";
    };
    directory = "/home/tillo/Pictures/wallpaper";
    enabled = true;
    monitors = {
      DP-2 = {
        path = "/home/tillo/Pictures/wallpaper/lobostudio-hamburg-E-3GL4-7P5k-unsplash.jpg";
      };
      DP-3 = {
        path = "/home/tillo/Pictures/wallpaper/lobostudio-hamburg-E-3GL4-7P5k-unsplash.jpg";
      };
    };
    transition = [
      "honeycomb"
    ];
    transition_duration = 6100;
    transition_on_startup = true;
  };
  widget = {
    cat = {
      audio_spectrum = true;
      tappy_mode = true;
      type = "noctalia/bongocat:cat";
    };
    keybind-cheatsheet = {
      show_label = true;
      type = "kenn/keybind-cheatsheet:keybind-cheatsheet";
    };
    network = {
      show_label = true;
    };
  };
};

  noctaliaIpc = pkgs.writeShellScriptBin "noctalia-ipc" ''
    set -eu

    noctalia=${lib.escapeShellArg (lib.getExe config.programs.noctalia.package)}

    exec "$noctalia" msg "$@"
  '';
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = noctaliaSettings;
  };

  home.packages = [ noctaliaIpc ];
}

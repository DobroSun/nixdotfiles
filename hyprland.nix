{ config, pkgs, lib, ... }:
{

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland = {
    settings = {
      "$mod" = "CTRL";

      bind = [
        "$mod, RETURN, exec, alacritty"
        "$mod, R,      exec, wofi --show=drun --normal-window"

        "$mod, M,      exec, hyprctl dispatch exit"
        "$mod, D,      exec, hyprctl dispatch killactive"

	"$mod, 1, workspace, 1"
	"$mod, 2, workspace, 2"
	"$mod, 3, workspace, 3"
	"$mod, 4, workspace, 4"
	"$mod, 5, workspace, 5"
	"$mod, 6, workspace, 6"
	"$mod, 7, workspace, 7"
	"$mod, 8, workspace, 8"
	"$mod, 9, workspace, 9"
	"$mod, 0, workspace, 10"

	"$mod SHIFT, 1, movetoworkspace, 1"
	"$mod SHIFT, 2, movetoworkspace, 2"
	"$mod SHIFT, 3, movetoworkspace, 3"
	"$mod SHIFT, 4, movetoworkspace, 4"
	"$mod SHIFT, 5, movetoworkspace, 5"
	"$mod SHIFT, 6, movetoworkspace, 6"
	"$mod SHIFT, 7, movetoworkspace, 7"
	"$mod SHIFT, 8, movetoworkspace, 8"
	"$mod SHIFT, 9, movetoworkspace, 9"
	"$mod SHIFT, 0, movetoworkspace, 10"
      ];

      windowrulev2 = [
        "stayfocused, initialClass:^(steam app),floating:1,fullscreen:0"   # Always focus on popup windows spawned from games.
      ];

      general = {
	layout = "dwindle";

	allow_tearing = false;
      };

      input = {
	follow_mouse = false;
	sensitivity = 0;	# -1.0 .. 1.0, 0 means no modification.

        touchpad = {
	  natural_scroll = true;
	};
      };

      dwindle = {
	no_gaps_when_only = true;
      };

      gestures = {
	workspace_swipe = true;
      };

      animations = {
        enabled = true;
      };
    };
  };

}

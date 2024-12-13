-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.color_scheme = "Catppuccin Mocha" -- or Macchiato, Frappe, Latte
-- config.color_scheme = "Dracula"


config.font = wezterm.font("JetBrains Mono")
config.font_size = 16

config.enable_tab_bar = false

-- config.window_decorations = "RESIZE"
-- config.window_background_opacity = 1
-- config.macos_window_background_blur = 10

config.keys = {
	-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	-- Make Option-Right equivalent to Alt-f; forward-word
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
}

-- and finally, return the configuration to wezterm
return config

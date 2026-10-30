#!/bin/sh
# Personal tools for any Debian/Ubuntu-based dev container: nvim (same version as on the
# Mac, for vim.pack) + what the nvim config uses (fzf-lua: rg / fd / fzf; parsers: cc).
# Runs once per container, from each project's postCreateCommand.
set -e
NVIM_VERSION=v0.12.6

sudo=$([ "$(id -u)" = 0 ] || echo sudo)
$sudo apt-get update
$sudo apt-get install -y --no-install-recommends \
  git curl ca-certificates ripgrep fd-find fzf build-essential
$sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd # Debian names it fdfind

arch=$(uname -m)
[ "$arch" = aarch64 ] && arch=arm64 # release names: nvim-linux-x86_64 / nvim-linux-arm64
curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$arch.tar.gz" \
  | $sudo tar -xz -C /opt
$sudo ln -sf "/opt/nvim-linux-$arch/bin/nvim" /usr/local/bin/nvim

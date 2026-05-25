#!/usr/bin/env bash
# claudefm installer — curl-pipe-bash friendly
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/sanhuaaan/claudefm/main/install.sh | bash
# Override the install prefix with: PREFIX=/usr/local curl ... | sudo bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BINDIR="$PREFIX/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/claudefm"
RAW="https://raw.githubusercontent.com/sanhuaaan/claudefm/main"

say() { printf '\033[1;36m→\033[0m %s\n' "$*"; }
ok()  { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn(){ printf '\033[1;33m⚠\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || die "curl is required"

say "installing claudefm to $BINDIR"
install -d "$BINDIR" "$CONFIG_DIR"

curl -fsSL "$RAW/claudefm" -o "$BINDIR/claudefm"
chmod +x "$BINDIR/claudefm"
ok "claudefm → $BINDIR/claudefm"

if [[ -f "$CONFIG_DIR/url" ]]; then
  ok "keeping existing config at $CONFIG_DIR/url"
else
  curl -fsSL "$RAW/.claudefm.url" -o "$CONFIG_DIR/url"
  ok "seeded default config at $CONFIG_DIR/url"
fi

if ! command -v yt-dlp >/dev/null 2>&1; then
  say "yt-dlp not found — downloading standalone binary"
  curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux \
    -o "$BINDIR/yt-dlp"
  chmod +x "$BINDIR/yt-dlp"
  ok "yt-dlp → $BINDIR/yt-dlp"
fi

if ! command -v mpv >/dev/null 2>&1; then
  warn "mpv not found. Install it with your package manager:"
  warn "    sudo apt install -y mpv     # Debian/Ubuntu"
  warn "    brew install mpv            # macOS"
fi

case ":$PATH:" in
  *":$BINDIR:"*) ;;
  *)
    warn "$BINDIR is not in your PATH. Add to your shell config:"
    warn "    export PATH=\"$BINDIR:\$PATH\""
    ;;
esac

echo
ok "done. Run: claudefm"

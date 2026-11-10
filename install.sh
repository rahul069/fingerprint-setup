#!/usr/bin/env bash
# One-line installer for fingerprint-setup:
#
#   curl -fsSL https://raw.githubusercontent.com/rahul069/fingerprint-setup/main/install.sh | bash
#
# Installs the `fingerprint-setup` command and its app-menu entry into /usr/local,
# then starts the guided setup in this terminal. Add `-s -- --gui` after `bash` to
# open the window instead, or `-s -- --no-setup` to only install the app.
set -euo pipefail

# Wrapped in a function so a partly downloaded script never runs.
main() {
  local RAW="${FINGERPRINT_SETUP_RAW:-https://raw.githubusercontent.com/rahul069/fingerprint-setup/main}"
  local MODE=setup
  case "${1:-}" in
    --gui) MODE=gui ;;
    --no-setup) MODE=none ;;
    "") ;;
    *) echo "usage: install.sh [--gui|--no-setup]" >&2; exit 2 ;;
  esac

  [[ $EUID -ne 0 ]] || { echo "Run this as your normal user (it asks for sudo when needed)." >&2; exit 1; }
  command -v apt-get >/dev/null || { echo "Sorry, only Debian/Ubuntu-based systems are supported so far." >&2; exit 1; }

  tmp=$(mktemp -d)
  trap 'rm -rf "${tmp:-}"' EXIT
  echo "==> Downloading fingerprint-setup"
  curl -fsSL "$RAW/fingerprint-setup" -o "$tmp/fingerprint-setup"
  curl -fsSL "$RAW/fingerprint-setup.desktop" -o "$tmp/fingerprint-setup.desktop"
  bash -n "$tmp/fingerprint-setup"

  echo "==> Installing it to /usr/local (asks for your password)"
  sudo install -Dm755 "$tmp/fingerprint-setup" /usr/local/bin/fingerprint-setup
  sudo install -Dm644 "$tmp/fingerprint-setup.desktop" /usr/local/share/applications/fingerprint-setup.desktop
  rm -rf "$tmp"
  echo "✓ Installed. Run 'fingerprint-setup help' or open 'Fingerprint Setup' from your app menu."
  echo

  case $MODE in
    setup) exec /usr/local/bin/fingerprint-setup setup </dev/tty ;;
    gui) exec /usr/local/bin/fingerprint-setup gui </dev/null ;;
  esac
}

main "$@"

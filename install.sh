#!/usr/bin/env bash
# dotfiles installer — zsh, tmux, starship, ghostty, nvim, btop (macOS)
#
#   curl -fsSL https://raw.githubusercontent.com/zvdy/dotfiles-mac/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- --dry-run
#
# Safe to re-run. Existing files are moved to ~/.dotfiles-backup/<timestamp>/,
# never deleted. Flags:
#   --dry-run     print what would happen, change nothing
#   --no-brew     skip Homebrew + `brew bundle`
#   --no-plugins  skip oh-my-zsh, tpm and the nvim plugin sync
#   -h, --help    show this help
set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/zvdy/dotfiles-mac.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0 NO_BREW=0 NO_PLUGINS=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-brew) NO_BREW=1 ;;
    --no-plugins) NO_PLUGINS=1 ;;
    -h | --help) sed -n '2,12p' "${BASH_SOURCE[0]:-$0}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

if [[ -t 1 ]]; then B=$'\e[1m' D=$'\e[2m' G=$'\e[32m' Y=$'\e[33m' R=$'\e[31m' Z=$'\e[0m'; else B='' D='' G='' Y='' R='' Z=''; fi
info() { printf '%s==>%s %s\n' "$B" "$Z" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$Z" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$Z" "$*"; }
die()  { printf '%serror:%s %s\n' "$R" "$Z" "$*" >&2; exit 1; }
run()  { if ((DRY_RUN)); then printf '  %s[dry-run]%s %s\n' "$D" "$Z" "$*"; else "$@"; fi; }

[[ "$(uname -s)" == Darwin ]] || die "this installer targets macOS (got $(uname -s))"
command -v git >/dev/null || die "git is required (run: xcode-select --install)"

# --- 1. locate the repo (curl | bash has no checkout, so clone one) ----------
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/Brewfile" && -d "$SCRIPT_DIR/zsh" ]]; then
  DOTFILES_DIR="$SCRIPT_DIR"
else
  info "Fetching dotfiles into $DOTFILES_DIR"
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    run git -C "$DOTFILES_DIR" pull --ff-only
  else
    run git clone --depth 1 "$REPO_URL" "$DOTFILES_DIR"
  fi
fi
((DRY_RUN)) && [[ ! -d "$DOTFILES_DIR" ]] && { warn "dry-run: nothing cloned, stopping here"; exit 0; }

# --- 2. Homebrew packages ----------------------------------------------------
if ((NO_BREW)); then
  warn "skipping Homebrew (--no-brew)"
else
  info "Homebrew"
  if ! command -v brew >/dev/null; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      warn "Homebrew not found; installing from https://brew.sh"
      run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi
  if command -v brew >/dev/null; then
    run brew bundle --file="$DOTFILES_DIR/Brewfile"
    ok "packages from Brewfile"
  elif ((DRY_RUN)); then
    warn "dry-run: brew would be installed first"
  else
    die "Homebrew install failed"
  fi
fi

# --- 3. symlink configs ------------------------------------------------------
backed_up=0
link() { # link <repo-relative source> <absolute destination>
  local src="$DOTFILES_DIR/$1" dst="$2"
  [[ -e "$src" ]] || { warn "missing in repo: $1"; return; }
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    ok "$dst already linked"; return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    run mkdir -p "$BACKUP_DIR"
    run mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    backed_up=1
    warn "backed up existing $dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  ok "$dst -> $1"
}

info "Linking configs"
link zsh/zshrc               "$HOME/.zshrc"
link tmux/tmux.conf          "$HOME/.config/tmux/tmux.conf"
link starship/starship.toml  "$HOME/.config/starship.toml"
link ghostty/config          "$HOME/.config/ghostty/config"
link nvim                    "$HOME/.config/nvim"
link btop/btop.conf          "$HOME/.config/btop/btop.conf"
((backed_up)) && info "Originals saved in $BACKUP_DIR"

# --- 4. plugin managers ------------------------------------------------------
if ((NO_PLUGINS)); then
  warn "skipping plugins (--no-plugins)"
else
  info "Plugins"
  # Clone oh-my-zsh directly; its own installer would overwrite ~/.zshrc.
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "oh-my-zsh present"
  else
    run git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi

  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    ok "tpm present"
  else
    run git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    run "$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "tpm plugin install failed (run prefix + I in tmux)"
  fi

  if command -v nvim >/dev/null; then
    run nvim --headless "+Lazy! restore" +qa || warn "nvim plugin sync failed (open nvim once to finish)"
  fi
fi

# --- 5. done -----------------------------------------------------------------
info "Done"
cat <<EOF
  Open a new terminal (or run: exec zsh).
  Set your terminal font to a Nerd Font (Ghostty config uses FiraCode Nerd Font).
  Start tmux with: tls   — then Ctrl+A is the prefix (Cmd+A in Ghostty).
EOF

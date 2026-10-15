# ~/.bashrc - Unified Multi-Environment Configuration
# Supports: Debian/Ubuntu, NixOS, Void/Arch, Termux, Wayland & X11

# ------------------------------------------------------------------------------
# 1. Environment Detection
# ------------------------------------------------------------------------------
IS_TERMUX=0
IS_NIXOS=0
IS_WAYLAND=0
IS_X11=0

if [[ -n "${TERMUX_VERSION:-}" || ( -n "${PREFIX:-}" && -d "$PREFIX/etc" ) ]]; then
    IS_TERMUX=1
fi

if [[ -f /etc/NIXOS ]]; then
    IS_NIXOS=1
fi

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    IS_WAYLAND=1
elif [[ -n "${DISPLAY:-}" ]]; then
    IS_X11=1
fi

# ------------------------------------------------------------------------------
# 2. Shell Options & Base Variables (Login + Interactive)
# ------------------------------------------------------------------------------
shopt -s checkwinsize 2>/dev/null || true
shopt -s extglob 2>/dev/null || true
shopt -s globstar 2>/dev/null || true
shopt -s nocaseglob 2>/dev/null || true
shopt -s nullglob 2>/dev/null || true

# XDG Base Directories
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

if [[ $IS_TERMUX -eq 0 && -z "${XDG_RUNTIME_DIR:-}" ]]; then
    export XDG_RUNTIME_DIR="/tmp/${USER:-$(id -u -n)}-runtime"
    mkdir -p -m 0700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
fi

# Core defaults
export EDITOR="nvim"
export PAGER="less"
export LANG="${LANG:-en_US.UTF-8}"
export GTK_THEME="Adwaita:dark"
export TIMEFORMAT=$'\nreal: %0R'

[[ -x /usr/bin/chromium ]] && export EDGE_PATH="/usr/bin/chromium"

# Hardware video acceleration fallback
if [[ -e /dev/dri/renderD128 ]] && lspci 2>/dev/null | grep -qi 'VGA.*Intel'; then
    export LIBVA_DRIVER_NAME="i965"
fi

# Wayland flags
if [[ $IS_WAYLAND -eq 1 ]]; then
    export MOZ_ENABLE_WAYLAND="1"
else
    export MOZ_ENABLE_WAYLAND="0"
fi

# Dynamic build parallelism
if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"
elif command -v getconf >/dev/null 2>&1; then
    JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"
else
    JOBS=4
fi

export MAKEFLAGS="-j${JOBS}"
export CMAKE_BUILD_PARALLEL_LEVEL="${JOBS}"
export MAX_JOBS="${JOBS}"
export CARGO_BUILD_JOBS="${JOBS}"

# Termux specifics
if [[ $IS_TERMUX -eq 1 ]]; then
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8

    if [[ -f "$PREFIX/etc/tls/cert.pem" ]]; then
        export SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
    fi
fi

# ------------------------------------------------------------------------------
# 3. PATH Construction
# ------------------------------------------------------------------------------
add_to_path() {
    local target="$1"
    local position="${2:-append}"
    if [[ -d "$target" ]] && [[ ":$PATH:" != *":$target:"* ]]; then
        if [[ "$position" == "prepend" ]]; then
            PATH="$target:$PATH"
        else
            PATH="$PATH:$target"
        fi
    fi
}

add_to_path "$HOME/scripts/bash" prepend
add_to_path "$HOME/.local/bin" prepend
add_to_path "$HOME/.bin" prepend
add_to_path "$HOME/.local/pip/bin" append
add_to_path "$HOME/.local/share/pip/bin" append
add_to_path "/usr/local/bin" append
add_to_path "/usr/local/bin/x86_64-linux" append
add_to_path "/opt/bin" append
add_to_path "/usr/sbin" append
add_to_path "/var/lib/flatpak/exports/bin" append

# Android SDK
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_HOME="/opt/android-sdk"
export ANDROID_AVD_HOME="${HOME}/.android/avd"

add_to_path "/opt/android-studio/bin" append
add_to_path "/opt/kotlinc/bin" append
add_to_path "$ANDROID_HOME/tools/bin" append
add_to_path "$ANDROID_HOME/platform-tools" append
add_to_path "/opt/android-sdk/cmdline-tools/latest/bin" append

export PATH

if [[ -d /usr/local/texmf-dist/doc ]]; then
    export MANPATH="${MANPATH:-}:/usr/local/texmf-dist/doc/man"
    export INFOPATH="${INFOPATH:-}:/usr/local/texmf-dist/doc/info"
fi

# ------------------------------------------------------------------------------
# 4. TTY1 Graphical Autostart (Login Shells)
# ------------------------------------------------------------------------------
if [[ $IS_TERMUX -eq 0 && "$(tty 2>/dev/null)" == "/dev/tty1" && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    [[ -z "${TMUX:-}" ]] && setterm -blank 1 -powersave powerdown 2>/dev/null || true
    echo "Starting graphical environment..."
    if command -v sway >/dev/null 2>&1; then
        exec dbus-run-session sway > /tmp/sway-session.log 2>&1
    elif command -v startx >/dev/null 2>&1; then
        exec startx > /tmp/xorg-session.log 2>&1
    fi
fi

# Bail out here if non-interactive
[[ $- != *i* ]] && return

# ------------------------------------------------------------------------------
# 5. Interactive UI & Terminal Settings
# ------------------------------------------------------------------------------
PS1='\[\e[0;32m\]\w\[\e[0m\] \[\e[0;97m\]\$\[\e[0m\] '

bind -r '"\C-r"' 2>/dev/null || true
bind -r '"\e[A"' 2>/dev/null || true

# ------------------------------------------------------------------------------
# 6. Universal Clipboard
# ------------------------------------------------------------------------------
if [[ $IS_TERMUX -eq 1 ]]; then
    xclip() { termux-clipboard-set "$@"; }
    xpaste() { termux-clipboard-get; }
elif [[ $IS_WAYLAND -eq 1 ]] && command -v wl-copy >/dev/null 2>&1; then
    xclip() { wl-copy "$@"; }
    xpaste() { wl-paste; }
elif command -v xclip >/dev/null 2>&1; then
    xclip() { command xclip -sel clipboard "$@"; }
    xpaste() { command xclip -sel clipboard -o; }
fi

# ------------------------------------------------------------------------------
# 7. Aliases & Functions
# ------------------------------------------------------------------------------
alias ls='ls --color=auto -ht'
alias sl='ls'
alias grep='grep --color=auto'
alias cdtmp='cd "$(mktemp -d)"'
alias reset='reset -Q'

command -v fzf >/dev/null 2>&1 && alias fnvim='nvim "$(fzf)"'
command -v feh >/dev/null 2>&1 && alias feh='feh --scale-down -S mtime'

if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat --style=full --theme=OneHalfLight --paging=never'
    alias batt='batcat --style=header-filename --paging=never'
elif command -v bat >/dev/null 2>&1; then
    alias bat='bat --style=full --theme=OneHalfLight --paging=never'
    alias batt='bat --style=header-filename --paging=never'
fi

cp --help 2>&1 | grep -q -- '--reflink' && alias cp='cp --reflink=auto'

if [[ $IS_TERMUX -eq 1 ]]; then
    alias pkg='apt'
    alias qemu='proot-distro login debian --user void'
fi

fcat() {
    if [[ $# -eq 0 ]]; then
        printf "Usage: fcat <file1> [file2...]\n"
        return 1
    fi
    for file in "$@"; do
        printf "\n\033[1;34m=== %s ===\033[0m\n" "$file"
        cat "$file"
    done
}

# ------------------------------------------------------------------------------
# 8. Node Version Manager (NVM)
# ------------------------------------------------------------------------------
export NVM_DIR="$HOME/.config/nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    \. "$NVM_DIR/nvm.sh"
    # shellcheck source=/dev/null
    [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
fi

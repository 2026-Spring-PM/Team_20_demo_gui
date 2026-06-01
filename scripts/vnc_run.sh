#!/bin/bash
# scripts/vnc_run.sh
# Runs INSIDE the Docker container (invoked by `bash scripts/run.sh`, the
# default no-argument mode). It:
#   1. installs the headless display / VNC tool-chain if the image lacks it,
#   2. builds build/main if it is missing AND source is present,
#   3. starts a virtual X display (Xvfb) + a window manager (fluxbox),
#   4. serves that display to the browser via x11vnc + noVNC (websockify),
#   5. launches the game on the virtual display.
# Open http://localhost:6080/vnc.html in your browser to play.
#
# You normally do NOT run this on the host directly.

set -e

export DISPLAY=:99
SCREEN_W="${SCREEN_W:-1280}"
SCREEN_H="${SCREEN_H:-800}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
VNC_PORT="${VNC_PORT:-5900}"

# Xvfb has no GPU -> force Mesa software OpenGL so SFML can create a context.
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe

# -------- 1. Ensure the VNC tool-chain is present --------------------
# The course base image ships SFML + X11 libs but not the headless display
# stack. Install whatever is missing (a no-op on a custom image that baked
# these in via docker/Dockerfile).
need_pkgs=()
command -v Xvfb       >/dev/null 2>&1 || need_pkgs+=(xvfb)
command -v x11vnc     >/dev/null 2>&1 || need_pkgs+=(x11vnc)
command -v websockify >/dev/null 2>&1 || need_pkgs+=(websockify)
command -v fluxbox    >/dev/null 2>&1 || need_pkgs+=(fluxbox)
[ -d /usr/share/novnc ] || need_pkgs+=(novnc)
# Mesa software rasteriser (swrast/llvmpipe) for OpenGL under Xvfb.
ls /usr/lib/*/dri/swrast_dri.so >/dev/null 2>&1 || need_pkgs+=(libgl1-mesa-dri)

if [ "${#need_pkgs[@]}" -gt 0 ]; then
    echo ">> Installing VNC tools in the container: ${need_pkgs[*]}"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y --no-install-recommends "${need_pkgs[@]}"
    rm -rf /var/lib/apt/lists/*
fi

# Locate the noVNC web root across distro layouts.
NOVNC_DIR=""
for d in /usr/share/novnc /usr/share/webapps/novnc /usr/local/share/novnc; do
    if [ -f "$d/vnc.html" ] || [ -f "$d/vnc_lite.html" ]; then NOVNC_DIR="$d"; break; fi
done
if [ -z "$NOVNC_DIR" ]; then
    echo "ERROR: noVNC web files not found after install." >&2
    exit 1
fi
# Prefer the "lite" client. The full vnc.html shipped by some distro novnc
# packages is mismatched with its app/ui.js and fails in the browser with
# "document.getElementById(...) is null"; vnc_lite.html is a self-contained
# client that avoids that. Fall back to vnc.html only if lite is absent.
if [ -f "$NOVNC_DIR/vnc_lite.html" ]; then
    VNC_PAGE="vnc_lite.html"
else
    VNC_PAGE="vnc.html"
fi
# Make the bare URL (http://localhost:PORT/) open the working client too.
ln -sf "$VNC_PAGE" "$NOVNC_DIR/index.html" 2>/dev/null || true

# -------- 2. Build the game if there is no prebuilt binary -----------
# The DEMO repo commits a prebuilt build/main (no source) -> skipped.
# The full source repo builds it on first run.
if [ ! -x build/main ]; then
    if [ -f CMakeLists.txt ]; then
        echo ">> No build/main found -- building from source first..."
        bash scripts/build.sh
    else
        echo "ERROR: build/main is missing and there is no source to build it from." >&2
        echo "       (Demo repo: commit the prebuilt build/main produced inside this image.)" >&2
        exit 1
    fi
fi

# -------- 3. Virtual display + window manager ------------------------
echo ">> Starting virtual display ${DISPLAY} (${SCREEN_W}x${SCREEN_H})"
Xvfb "${DISPLAY}" -screen 0 "${SCREEN_W}x${SCREEN_H}x24" -nolisten tcp &
XVFB_PID=$!

# Wait for the X socket before starting clients.
for _ in $(seq 1 50); do
    [ -S "/tmp/.X11-unix/X${DISPLAY#:}" ] && break
    sleep 0.1
done

# A lightweight WM so the game window gets keyboard focus.
fluxbox >/dev/null 2>&1 &
FLUX_PID=$!
sleep 0.3

# -------- 4. VNC server + noVNC web bridge ---------------------------
echo ">> Starting VNC server + noVNC web bridge on port ${NOVNC_PORT}"
x11vnc -display "${DISPLAY}" -rfbport "${VNC_PORT}" -forever -shared -nopw -quiet \
       >/tmp/x11vnc.log 2>&1 &
X11VNC_PID=$!
websockify --web="${NOVNC_DIR}" "${NOVNC_PORT}" "localhost:${VNC_PORT}" \
       >/tmp/websockify.log 2>&1 &
WS_PID=$!

# -------- 5. Clean shutdown ------------------------------------------
cleanup() {
    echo ""
    echo ">> Shutting down..."
    kill "${GAME_PID:-}" "${WS_PID:-}" "${X11VNC_PID:-}" "${FLUX_PID:-}" "${XVFB_PID:-}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo ""
echo "============================================================"
echo "  noVNC ready.  Open in your browser:"
echo ""
echo "    http://localhost:${NOVNC_PORT}/${VNC_PAGE}?autoconnect=true&resize=scale"
echo ""
echo "  Press Ctrl+C here to stop the game and the container."
echo "============================================================"
echo ""

# -------- 6. Launch the game (foreground; exit ends the session) -----
./build/main &
GAME_PID=$!
wait "${GAME_PID}"

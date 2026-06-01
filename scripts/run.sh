#!/bin/bash
# scripts/run.sh
# Build and run Dragonshire.
#
# Modes:
#   bash scripts/run.sh            -> Docker + VNC  (DEFAULT, recommended).
#                                     Plays in your web browser at
#                                       http://localhost:6080/vnc.html
#                                     No display server needed on the host, so
#                                     it works the same on Windows / macOS /
#                                     Linux. This is the demo / grading path.
#   bash scripts/run.sh --vnc      -> same as the default (explicit).
#   bash scripts/run.sh --docker   -> Docker with HOST X11 forwarding. Opens a
#                                     native OS window. Needs an X server
#                                     (Linux desktop / WSLg / macOS XQuartz).
#   bash scripts/run.sh --native   -> Native build + run, no Docker. Needs a
#                                     local SFML install and a display.
#   bash scripts/run.sh --help     -> this usage text.
#
# Docker prerequisites: docker installed + permission to run it.
#
# Why this script: the engine loads assets/ relative to the current working
# directory, so we always cd to the project root (the container mounts it at
# /workspace and launches from there) so those relative paths resolve.

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/.." &> /dev/null && pwd )"

# -------- Config (override via env) ------------------------------------
# Team Docker image. The course base image (chwoong/team_00_project:0.1.0)
# also works; the VNC tools are installed on first run if the image lacks
# them (see scripts/vnc_run.sh). Rebuild with docker/docker_build.sh to
# bake them in and skip that step.
IMAGE_NAME="${IMAGE_NAME:-mono1ka/team_20_project:0.1.0}"
# Host port that serves the noVNC web client.
NOVNC_PORT="${NOVNC_PORT:-6080}"

# -------- Parse flags --------------------------------------------------
MODE="vnc"              # default: play in the browser over VNC
for arg in "$@"; do
    case "$arg" in
        --vnc)     MODE="vnc" ;;
        --docker)  MODE="docker" ;;
        --native)  MODE="native" ;;
        --help|-h)
            grep '^#' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            echo "Run '$0 --help' for usage." >&2
            exit 1
            ;;
    esac
done

cd "${PROJECT_ROOT}"

# =====================================================================
# Native mode (--native): local build + run, no Docker.
# =====================================================================
if [[ "$MODE" == "native" ]]; then
    echo ">> Native build + run"
    echo "   (Use 'bash scripts/run.sh' with no args to play in a browser.)"
    bash "${SCRIPT_DIR}/build.sh"
    echo ""
    echo ">> Launching game..."
    exec "${PROJECT_ROOT}/build/main"
fi

# ---- Both Docker modes need docker on PATH --------------------------
if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker is not installed or not on PATH." >&2
    echo "       Install Docker, or run 'bash scripts/run.sh --native' to build locally." >&2
    exit 1
fi

# =====================================================================
# VNC mode (DEFAULT): play in a browser, no host display needed.
# =====================================================================
if [[ "$MODE" == "vnc" ]]; then
    echo ">> Docker + VNC   (image: ${IMAGE_NAME})"
    echo ">> Starting the container..."
    echo "   First run may take ~30s while VNC tools install inside the container."
    echo ""
    echo "   When you see 'noVNC ready', open this URL in your browser:"
    echo ""
    echo "       http://localhost:${NOVNC_PORT}/vnc_lite.html?autoconnect=true&resize=scale"
    echo ""
    echo "   Stop the game with Ctrl+C in this terminal."
    echo "---------------------------------------------------------------"

    exec docker run --rm -it \
        --platform linux/amd64 \
        -p "${NOVNC_PORT}:6080" \
        -e "NOVNC_PORT=6080" \
        -v "${PROJECT_ROOT}":/workspace:z \
        -w /workspace \
        --name dragonshire-vnc \
        "${IMAGE_NAME}" \
        bash scripts/vnc_run.sh
fi

# =====================================================================
# Docker mode (--docker): host X11 forwarding -> native OS window.
# (Kept from the original script; behaviour unchanged.)
# =====================================================================
echo ">> Docker build + run with host X11   (image: ${IMAGE_NAME})"

# Decide X11 mount arguments based on host OS.
X11_ARGS=()
case "$(uname -s)" in
    Linux*)
        # Native Linux or WSL2 with WSLg.
        if [[ -n "$DISPLAY" ]]; then
            xhost +local:docker >/dev/null 2>&1 || true
            X11_ARGS=(
                -e "DISPLAY=${DISPLAY}"
                -v /tmp/.X11-unix:/tmp/.X11-unix
            )
            # WSLg paths (Windows 11). Mount them if they exist.
            if [[ -d /mnt/wslg ]]; then
                X11_ARGS+=(-v /mnt/wslg:/mnt/wslg)
            fi
            if [[ -e /run/user/1000/wayland-0 ]]; then
                X11_ARGS+=(-v /run/user/1000:/run/user/1000)
            fi
        else
            echo "Warning: DISPLAY is not set. The game window will not appear."
            echo "         Tip: run 'bash scripts/run.sh' (no args) to play in a browser instead."
        fi
        ;;
    Darwin*)
        # macOS: requires XQuartz with "Allow connections from network clients" enabled.
        X11_ARGS=(
            -e "DISPLAY=host.docker.internal:0"
        )
        ;;
    *)
        echo "Warning: Unknown OS. You may need to set up X11 forwarding manually."
        echo "         Tip: run 'bash scripts/run.sh' (no args) to play in a browser instead."
        ;;
esac

# Build inside the container only if there is no prebuilt binary and the
# source is present (the demo repo ships a prebuilt build/main and no
# source, so the build step is skipped there), then launch the game.
docker run --rm -it \
    --platform linux/amd64 \
    "${X11_ARGS[@]}" \
    -v "${PROJECT_ROOT}":/workspace:z \
    -w /workspace \
    --name dragonshire-run \
    "${IMAGE_NAME}" \
    bash -c "if [ ! -x build/main ] && [ -f CMakeLists.txt ]; then bash scripts/build.sh; fi && ./build/main"

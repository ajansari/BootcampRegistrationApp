#!/usr/bin/env bash
# Launches the AL MCP server (altool launchmcpserver) for this project.
#
# Deliberately does not hardcode an AL extension version or a specific .NET
# runtime path — both drift (extension updates, VS Code's own provisioned
# runtime version changes) and a config file pointing at a fixed version
# breaks silently on the next update. This script re-discovers both at
# launch time instead. See CLAUDE.md, "AL MCP Server" (ALL ALONG).
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. Find the AL extension's bin/ folder — newest installed version wins.
AL_EXT_DIR="$(ls -d "$HOME"/.vscode/extensions/ms-dynamics-smb.al-* 2>/dev/null | sort -V | tail -1)"
if [ -z "$AL_EXT_DIR" ]; then
    echo "al-mcp-server.sh: no ms-dynamics-smb.al-* extension found under ~/.vscode/extensions/" >&2
    exit 1
fi
ALTOOL_DLL="$AL_EXT_DIR/bin/altool.dll"
if [ ! -f "$ALTOOL_DLL" ]; then
    echo "al-mcp-server.sh: altool.dll not found at $ALTOOL_DLL (AL extension too old? need 17.0+)" >&2
    exit 1
fi

# 2. altool.exe ships Windows-only; on macOS/Linux invoke the .dll directly
#    against a .NET runtime. Prefer one already on PATH; otherwise fall back
#    to VS Code's own privately-provisioned runtime (the ".NET Install Tool"
#    extension puts one there for exactly this kind of use, without any
#    system-wide install — see Operating Rule 6b before installing anything).
if command -v dotnet >/dev/null 2>&1; then
    DOTNET_BIN="dotnet"
else
    DOTNET_BIN="$(ls "$HOME"/Library/Application\ Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet/*/dotnet 2>/dev/null | sort -V | tail -1)"
    if [ -z "$DOTNET_BIN" ]; then
        echo "al-mcp-server.sh: no dotnet on PATH and none found in VS Code's provisioned runtime path." >&2
        echo "Do not install one without asking first (Operating Rule 6b)." >&2
        exit 1
    fi
fi

exec "$DOTNET_BIN" "$ALTOOL_DLL" launchmcpserver "$PROJECT_DIR" --transport stdio

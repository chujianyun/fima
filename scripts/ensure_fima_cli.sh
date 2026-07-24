#!/bin/sh
# Install Fima CLI once per user and print the executable path.
set -eu

FIMA_CLI_REPO_URL="${FIMA_CLI_REPO_URL:-https://github.com/chujianyun/fima-cli.git}"
FIMA_CLI_BRANCH="${FIMA_CLI_BRANCH:-main}"
FIMA_CLI_INSTALL_ROOT="${FIMA_CLI_INSTALL_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/fima-cli}"
FIMA_CLI_BIN="${HOME}/.local/bin/fima"

if [ -x "$FIMA_CLI_BIN" ] && [ "${FIMA_CLI_UPDATE:-0}" != "1" ]; then
  printf '%s\n' "$FIMA_CLI_BIN"
  exit 0
fi

command -v git >/dev/null 2>&1 || {
  printf '%s\n' 'fima-cli 安装失败：未找到 git。' >&2
  exit 1
}

if [ ! -d "$FIMA_CLI_INSTALL_ROOT/.git" ]; then
  if [ -e "$FIMA_CLI_INSTALL_ROOT" ]; then
    printf '%s\n' "fima-cli 安装失败：$FIMA_CLI_INSTALL_ROOT 已存在但不是 Git 仓库。请设置 FIMA_CLI_INSTALL_ROOT。" >&2
    exit 1
  fi
  git clone --depth 1 --branch "$FIMA_CLI_BRANCH" "$FIMA_CLI_REPO_URL" "$FIMA_CLI_INSTALL_ROOT" >&2
elif [ "${FIMA_CLI_UPDATE:-0}" = "1" ]; then
  git -C "$FIMA_CLI_INSTALL_ROOT" fetch origin "$FIMA_CLI_BRANCH" >&2
  git -C "$FIMA_CLI_INSTALL_ROOT" checkout --detach "origin/$FIMA_CLI_BRANCH" >&2
fi

"$FIMA_CLI_INSTALL_ROOT/install.sh" >&2

if [ ! -x "$FIMA_CLI_BIN" ]; then
  printf '%s\n' "fima-cli 安装失败：未生成 $FIMA_CLI_BIN。" >&2
  exit 1
fi

printf '%s\n' "$FIMA_CLI_BIN"

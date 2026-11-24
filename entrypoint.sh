#!/bin/bash
set -e

DATA_DIR="${DATA_DIR:-/data}"

# Avoid slow recursive chown on network volumes (e.g. AWS EFS Access Points)
# whose UID/GID already matches openclaw or cannot be changed by chown.
TARGET_UID=$(id -u openclaw)
TARGET_GID=$(id -g openclaw)
CUR_UID=$(stat -c '%u' "$DATA_DIR" 2>/dev/null || echo "")
if [ -n "$CUR_UID" ] && [ "$CUR_UID" != "$TARGET_UID" ]; then
  chown "$TARGET_UID:$TARGET_GID" "$DATA_DIR" 2>/dev/null || true
  NEW_UID=$(stat -c '%u' "$DATA_DIR" 2>/dev/null || echo "")
  if [ "$NEW_UID" = "$TARGET_UID" ]; then
    chown -R openclaw:openclaw "$DATA_DIR" 2>/dev/null || true
  fi
fi
chmod 700 "$DATA_DIR" 2>/dev/null || true

if [ ! -d "$DATA_DIR/.linuxbrew" ]; then
  cp -a /home/linuxbrew/.linuxbrew "$DATA_DIR/.linuxbrew" 2>/dev/null || true
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn "$DATA_DIR/.linuxbrew" /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js

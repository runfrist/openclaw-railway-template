#!/bin/bash
set -e

DATA_DIR="${DATA_DIR:-/data}"

chown -R openclaw:openclaw "$DATA_DIR" 2>/dev/null || true
chmod 700 "$DATA_DIR" 2>/dev/null || true

if [ ! -d "$DATA_DIR/.linuxbrew" ]; then
  cp -a /home/linuxbrew/.linuxbrew "$DATA_DIR/.linuxbrew" 2>/dev/null || true
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn "$DATA_DIR/.linuxbrew" /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js

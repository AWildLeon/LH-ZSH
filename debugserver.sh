#!/bin/bash
cd "$(dirname "$0")" || exit 1
cd www
python3 -m http.server 8235 -b 127.0.0.1 
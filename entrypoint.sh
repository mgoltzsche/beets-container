#!/bin/sh

set -e

mkdir -p /data/beets-state

exec beet -c /etc/beets.yaml "$@"

#!/bin/sh

mkdir -p /tmp/xtractor
[ -f "$BEETSDIR/config.yaml" ] || cp /etc/beets/default-config.yaml "$BEETSDIR/config.yaml"

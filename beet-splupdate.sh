#!/bin/sh

set -eu

: ${BEETS_ADDRESS:=http://beets:8337}

#mkdir -p /data/public

beet splupdate
beet splupdate --uri-format "$BEETS_ADDRESS"'/item/$id/file' -d /data/web/playlists
beet splupdate --uri-format 'beets:library:track;$id' -d /data/web/mopidy

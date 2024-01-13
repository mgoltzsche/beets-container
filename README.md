# beets container

An opinionated, containerized [beets](https://github.com/beetbox/beets) distribution.

## Container variants

The beets container image is provided in two flavours:
* [`ghcr.io/mgoltzsche/beets`](https://github.com/mgoltzsche/beets-container/pkgs/container/beets): beets without additional plugins but the [web API](https://beets.readthedocs.io/en/stable/plugins/web.html) installed.
* [`ghcr.io/mgoltzsche/beets-plugins`](https://github.com/mgoltzsche/beets-container/pkgs/container/beets-plugins): beets with additional plugins (using the configuration within the library directory):
  * [ytimport](https://github.com/mgoltzsche/beets-ytimport): Adds a command to import (liked) tracks from Youtube/SoundCloud into your beets library.
  * [chroma](https://beets.readthedocs.io/en/stable/plugins/chroma.html): Generates/matches an acoustic fingerprint on track import.
  * [lastgenre](https://beets.readthedocs.io/en/stable/plugins/lastgenre.html): Gets the genre for a track [Last.fm](https://www.last.fm/) on import.
  * [discogs](https://beets.readthedocs.io/en/stable/plugins/discogs.html): Allows to match tracks against [Discogs](https://www.discogs.com) (optional; requires credentials to be configured).
  * [xtractor](https://github.com/adamjakab/BeetsPluginXtractor): Adds a command to analyze your library using [Essentia](https://essentia.upf.edu/index.html) and store the results as additional track fields within your library.
  * [describe](https://github.com/adamjakab/BeetsPluginDescribe): Adds a command to visualize the data distribution of a given field within your beets library.
  * [mpdstats](https://beets.readthedocs.io/en/stable/plugins/mpdstats.html): Adds a command to connect with an [MPD](https://mpd.readthedocs.io/en/latest/protocol.html) player to automatically rate tracks based on play and skip actions.

## Usage

The following examples assume you have configured a directory as your beets music library as follows:
```sh
BEETS_LIBRARY=path/to/your/music/library
mkdir -p $BEETS_LIBRARY
```
The beets container will store the imported music as well as an SQLite DB and the Beet configuration within that directory.
The `ghcr.io/mgoltzsche/beets-plugins` container creates the configuration file `$BEETS_LIBRARY/beets/config.yaml` if it does not exist yet.
For more information, see the [beets documentation](https://beets.readthedocs.io/en/stable/).

### Managing your music library

To initialize/manage your beets library, you can use the `ghcr.io/mgoltzsche/beets-plugins` container image.

You can start a containerized shell as follows:
```sh
docker run -it --rm -u `id -u`:`id -g` \
	--mount "type=bind,src=${BEETS_LIBRARY},dst=/data" \
	ghcr.io/mgoltzsche/beets-plugins
```

Within the containerized shell you can perform maintenance operations with your music library interactively, e.g.:
```sh
# Import songs from Youtube:
beet ytimport https://www.youtube.com/watch?v=8soQkubMk1g \
	https://www.youtube.com/watch?v=gtiZL33hoTY
# Import 3 liked songs from Youtube (prompts for login):
beet ytimport --likes --max-likes 3
# List the tracks within your library:
beet ls -f '$artist - $title ($genre)'
# Inspect a particular track:
beet info -l "Ça plane pour moi"
# Assign genres to all tracks:
beet autogenre
# Generate local m3u8 playlists (based on configured rules/queries):
beet splupdate
# Generate remotely playable m3u8 playlists (using script)
beet-splupdate
# Inspect the distribution of genres within your library:
beet describe genre
# Analyze your library using Essentia and save the results as metadata:
beet xtractor
# List supported fields
beet fields
# List the danceable tracks within your library, sorted by danceability:
beet ls -f '$danceable - $artist - $title' danceable:0.8..1 danceable-
# Get a random danceable track:
beet random danceable:0.8..1
```

To import a local music directory into your beets audio library, run e.g.:
```sh
IMPORT_SÒURCE_DIR=path/to/import/audio/from
docker run -it --rm -u `id -u`:`id -g` \
	--mount "type=bind,src=${BEETS_LIBRARY},dst=/data" \
	--mount "type=bind,src=${IMPORT_SOURCE_DIR},dst=/import" \
	ghcr.io/mgoltzsche/beets-plugins import /import -si
```
_Please note that the `import` command is prompting you for input for each track without a strong match._

To play tracks via pulseaudio, run e.g.:
```sh
docker run -ti --rm -u `id -u`:`id -g` \
	--mount "type=bind,src=${BEETS_LIBRARY},dst=/data" \
	-v /run:/host/run \
	-e PULSE_SERVER=unix:/host/run/user/`id -u`/pulse/native \
	ghcr.io/mgoltzsche/beets-plugins play mood_happy:0.8..1 --args=--shuffle
```
_Please note that the `PULSE_SERVER` env var has to be specified and, when using a unix socket, the socket to be mounted._

### Using your music library

You can access the audio files and generated m3u playlists within your library locally directly using a player of your choice.
Similarly, you can copy/sync the library to your mobile phone or export it to an mp3 player in order to be able to listen to your music library even when there's no internet connectivity.

Alternatively, the beets web plugin serves a minimal web GUI and an API that enables (remote) players to browse, search and stream music from your library via HTTP.
To serve the beets web API, run:
```sh
docker run --rm -u `id -u`:`id -g` -p 8337:8337 \
	--mount "type=bind,src=${BEETS_LIBRARY},dst=/data" \
	ghcr.io/mgoltzsche/beets
```
Now you can access your library at e.g. [`http://localhost:8337`](http://localhost:8337).

When you generated playlists using the `beet-splupdate` script within the maintenance container previously, you can access them at [`http://localhost:8337/m3u/`](http://localhost:8337/m3u/).

## Development

To list all supported targets, run `make help`.

### Prerequisites

* git
* make
* [docker 20+](https://docs.docker.com/engine/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) (optional; if you want to deploy to Kubernetes)

### Build the application
To build the application container image using [skaffold](https://skaffold.dev), run:
```sh
make image
```

### Run a containerized shell

```sh
make beets-sh
```

### Deploy the application to Kubernetes
To deploy the application using [skaffold](https://skaffold.dev), run:
```sh
make deploy
```
To deploy the application in debug mode (debug ports forwarded), stream its logs and redeploy on source code changes automatically, run:
```sh
make debug
```

To undeploy the application, run:
```sh
make undeploy
```

### Apply blueprint updates
To apply blueprint updates to the application codebase, update the [kpt](https://kpt.dev/) package:
1. Before updating the package, make sure you don't have uncommitted changes in order to be able to distinguish package update changes from others.
2. Call `make blueprint-update` or rather [`kpt pkg update`](https://kpt.dev/reference/cli/pkg/update/) and [`kpt fn render`](https://kpt.dev/reference/cli/fn/render/) (applies the configuration within [`setters.yaml`](./setters.yaml) to the manifests and `skaffold.yaml`).
3. Before committing the changes, review them carefully and make manual changes if necessary.

TL;DR: [Variant Constructor Pattern](https://kpt.dev/guides/variant-constructor-pattern)

## Release

The release process is driven by [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.4/), letting the CI pipeline generate a version and publish a release depending on the [commit messages](https://semantic-release.gitbook.io/semantic-release/#commit-message-format) on the `main` branch.

## Credits

The `ghcr.io/mgoltzsche/beets-plugins` container image produced by this repository includes a custom build of [Essentia](https://essentia.upf.edu/) extractors as well as a copy of [the models](https://essentia.upf.edu/svm_models/).
Essentia is licensed under the GNU Affero General Public License v3.0.

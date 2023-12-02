# beets container

An opinionated, containerized [beets](https://github.com/beetbox/beets) distribution.

## Usage

The following examples assume you have configured your beets media library directory as follows:
```sh
BEETS_DIR=path/to/your/music/library
```

To import music into your media library, run e.g.:
```sh
IMPORT_SÒURCE_DIR=path/to/import/audio/from
docker run -ti --rm -v "$BEETS_DIR:/data" -u `id -u`:`id -g` \
	-v "$BEETS_DIR:/data" \
	-v "$IMPORT_SOURCE_DIR:/import" \
	ghcr.io/mgoltzsche/beets import /import -si
```

To generate playlists from your music library, run:
```sh
docker run --rm -v "$BEETS_DIR:/data" -u `id -u`:`id -g` \
	-v "$BEETS_DIR:/data" \
	ghcr.io/mgoltzsche/beets splupdate
```

To inspect the distribution of genres within your music library, run e.g.:
```sh
docker run -ti --rm -v "$BEETS_DIR:/data" -u `id -u`:`id -g` \
	-v "$BEETS_DIR:/data" \
	ghcr.io/mgoltzsche/beets describe genre
```

To run the beets web server, call:
```sh
docker run -ti --rm -v "$BEETS_DIR:/data" -u `id -u`:`id -g` \
	-v "$BEETS_DIR:/data" \
	ghcr.io/mgoltzsche/beets web
```

To play tracks via pulseaudio, run e.g.:
```sh
docker run -ti --rm -v "$BEETS_DIR:/data" -u `id -u`:`id -g` \
	-v "$BEETS_DIR:/data" \
	-v /run:/host/run \
	-e PULSE_SERVER=unix:/host/run/user/`id -u`/pulse/native \
	ghcr.io/mgoltzsche/beets play House --args=--shuffle
```

## Development

To list the supported targets, run `make help`.

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

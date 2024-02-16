##@ Interactive Testing

.PHONY: beets-web
beets-web: SKAFFOLD_OPTS=-t dev
beets-web: image ## Run containerized beets web API.
	mkdir -p data/beets
	docker run -ti --rm -u `id -u`:`id -g` --network=host \
		-v "`pwd`/data:/data" \
		ghcr.io/mgoltzsche/beets:dev

.PHONY: beetstream
beetstream: SKAFFOLD_OPTS=-t dev
beetstream: image ## Run containerized beetstream (Subsonic) server.
	mkdir -p data/beets
	docker run -ti --rm -u `id -u`:`id -g` --network=host \
		-v "`pwd`/data:/data" \
		ghcr.io/mgoltzsche/beetstream:dev

.PHONY: beets-sh
beets-sh: SKAFFOLD_OPTS=-t dev
beets-sh: image ## Run a shell within the beets-plugins container.
	mkdir -p data/beets
	docker run -ti --rm -u `id -u`:`id -g` --network=host \
		-v "`pwd`/data:/data" \
		-v /run:/host/run \
		-e PULSE_SERVER=unix:/host/run/user/`id -u`/pulse/native \
		ghcr.io/mgoltzsche/beets-plugins:dev

.PHONY: clean-data
clean-data: ## Clean temporary beets library.
	rm -rf data


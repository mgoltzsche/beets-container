##@ Interactive Testing

.PHONY: beets-sh
beets-sh: SKAFFOLD_OPTS=-t dev
beets-sh: image ## Run a shell within a beets container.
	mkdir -p data/beets
	docker run -ti --rm -u `id -u`:`id -g` --network=host \
		-v "`pwd`/data:/data" \
		-v /run:/host/run \
		-e PULSE_SERVER=unix:/host/run/user/`id -u`/pulse/native \
		ghcr.io/mgoltzsche/beets:dev sh

.PHONY: clean-data
clean-data: ## Clean temporary beets library.
	rm -rf data


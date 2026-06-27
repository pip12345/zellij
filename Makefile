DOCKER ?= docker
IMAGE ?= zellij-builder
DOCKERFILE ?= Dockerfile.build

UID := $(shell id -u)
GID := $(shell id -g)
DOCKER_TTY := $(shell [ -t 1 ] && echo -it || echo -i)

DOCKER_RUN = $(DOCKER) run --rm $(DOCKER_TTY) \
	--user $(UID):$(GID) \
	-e CARGO_HOME=/tmp/cargo \
	-e CARGO_TARGET_DIR=/workspace/target \
	-e HOME=/tmp \
	-v $(CURDIR):/workspace \
	-w /workspace \
	$(IMAGE)

.PHONY: docker-image build release test test-tab test-scrolled-output clean shell docker-clean

docker-image:
	$(DOCKER) build -f $(DOCKERFILE) -t $(IMAGE) .

build: docker-image
	$(DOCKER_RUN) cargo xtask build $(BUILD_ARGS)

release: docker-image
	$(DOCKER_RUN) cargo xtask build --release $(BUILD_ARGS)

test: docker-image
	$(DOCKER_RUN) cargo test $(TEST_ARGS)

test-tab: docker-image
	$(DOCKER_RUN) cargo test -p zellij-server tab::tab_tests --no-default-features

test-scrolled-output: docker-image
	$(DOCKER_RUN) cargo test -p zellij-server pty_output_while_ --no-default-features

clean: docker-image
	$(DOCKER_RUN) cargo clean

shell: docker-image
	$(DOCKER_RUN) bash

docker-clean:
	-$(DOCKER) image rm $(IMAGE)

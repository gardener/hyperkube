# SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Gardener contributors
#
# SPDX-License-Identifier: Apache-2.0

IMAGE_REPOSITORY   := europe-docker.pkg.dev/gardener-project/releases/hyperkube
IMAGE_TAG          := $(shell cat KUBERNETES_VERSION)
KUBERNETES_VERSION := $(shell cat KUBERNETES_VERSION)
ARCH               := $(shell uname -m | sed 's/x86_64/amd64/')

.PHONY: build
build: docker-image

.PHONY: release
release: build docker-login docker-push

.PHONY: docker-image
docker-image:
	@docker buildx build -t $(IMAGE_REPOSITORY):$(IMAGE_TAG) --build-arg=KUBERNETES_VERSION=$(KUBERNETES_VERSION) --platform linux/$(ARCH) --load .

.PHONY: docker-login
docker-login:
	@gcloud auth activate-service-account --key-file .kube-secrets/gcr/gcr-readwrite.json

.PHONY: docker-push
docker-push:
	@docker buildx build -t $(IMAGE_REPOSITORY):$(IMAGE_TAG) --build-arg=KUBERNETES_VERSION=$(KUBERNETES_VERSION) --platform linux/amd64,linux/arm64 --push .

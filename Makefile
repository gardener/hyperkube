# Copyright (c) 2020 SAP SE or an SAP affiliate company. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

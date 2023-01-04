VERSION ?= 8.2
REGISTRY ?= ghcr.io

VERSION_DIR := docker/${VERSION}
DOCKERFILE := ${VERSION_DIR}/Dockerfile
IMAGE_NAME := ${REGISTRY}/luislavena/greek-steam

GOSS_FILE := ${VERSION_DIR}/goss.yaml
export GOSS_FILE

.PHONY: test
test: build ${GOSS_FILE}
	dgoss run ${IMAGE_NAME}:${VERSION} sleep infinity

.PHONY: build
build: ${DOCKERFILE}
	docker build --progress=plain --pull -t ${IMAGE_NAME}:${VERSION} ${VERSION_DIR}

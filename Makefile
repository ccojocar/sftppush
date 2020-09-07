
.PHONY: build build-alpine clean test help default



BIN_NAME=sftppush

OSTYPE := linux_amd64

VERSION := $(shell grep "const Version " version/version.go | sed -E 's/.*"(.+)"$$/\1/')
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_DIRTY=$(shell test -n "`git status --porcelain`" && echo "+CHANGES" || true)
BUILD_DATE=$(shell date '+%Y-%m-%d-%H:%M:%S')
IMAGE_NAME := "olmax/sftppush"

default: test

help:
	@cat LICENCE.md
	@echo
	@echo 'Management commands for sftppush:'
	@echo
	@echo 'Usage:'
	@echo '    make build           Compile the project.'
	@echo '    make get-deps        runs dep ensure, mostly used for ci.'
	@echo '    make build-alpine    Compile optimized for alpine linux.'
	@echo '    make package         Build final docker image with just the go binary inside'
	@echo '    make tag             Tag image created by package with latest, git commit and version'
	@echo '    make test            Run tests on a compiled project.'
	@echo '    make push            Push tagged images to registry'
	@echo '    make clean           Clean the directory tree.'
	@echo

build:
	@echo "building ${BIN_NAME}-${VERSION}-${OSTYPE}"
	@echo "GOPATH=${GOPATH}"
        # -X write changes to variable at build time: update GitCommit, update BuildDate
	go build -ldflags "-X github.com/olmax99/sftppush/version.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -X github.com/olmax99/sftppush/version.BuildDate=${BUILD_DATE}" -o bin/${BIN_NAME}-${VERSION}-${OSTYPE}

get-deps:
	dep ensure

build-alpine:
	@echo "building ${BIN_NAME} ${VERSION} for Docker Alpine"
	@echo "GOPATH=${GOPATH}"
        # -w reduce binary size: turn off DWARF debugging information
        # -linkmode external -extldflags "-static": CGo compile options details at cmd/cgo/doc.go
	go build -ldflags '-w -linkmode external -extldflags "-static" -X github.com/olmax99/sftppush/version.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -X github.com/olmax99/sftppush/version.BuildDate=${BUILD_DATE}' -o bin/${BIN_NAME}

package:
	@echo "building image ${BIN_NAME} ${VERSION} $(GIT_COMMIT)"
	docker build --build-arg VERSION=${VERSION} --build-arg GIT_COMMIT=$(GIT_COMMIT) -t $(IMAGE_NAME):local .

tag: 
	@echo "Tagging: latest ${VERSION} $(GIT_COMMIT)"
	docker tag $(IMAGE_NAME):local $(IMAGE_NAME):$(GIT_COMMIT)
	docker tag $(IMAGE_NAME):local $(IMAGE_NAME):${VERSION}
	docker tag $(IMAGE_NAME):local $(IMAGE_NAME):latest

push: tag
	@echo "Pushing docker image to registry: latest ${VERSION} $(GIT_COMMIT)"
	docker push $(IMAGE_NAME):$(GIT_COMMIT)
	docker push $(IMAGE_NAME):${VERSION}
	docker push $(IMAGE_NAME):latest

clean:
	@test ! -e bin/${BIN_NAME} || rm bin/${BIN_NAME}

test:
	go test ./...


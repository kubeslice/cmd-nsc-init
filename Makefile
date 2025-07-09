# Makefile for cmd-nsc-init
IMG ?= kubeslice/cmd-nsc-init:latest
PLATFORMS ?= linux/amd64,linux/arm64

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

##@ Development

.PHONY: build
build: ## Build binary locally
	go build -o bin/cmd-nsc-init .

.PHONY: run
run: ## Run binary locally
	go run ./main.go

.PHONY: test
test: ## Run tests
	go test -v ./...

.PHONY: fmt
fmt: ## Run go fmt against code
	go fmt ./...

.PHONY: vet
vet: ## Run go vet against code
	go vet ./...

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf bin/

##@ Docker

.PHONY: docker-build
docker-build: ## Build docker image (multi-arch)
	docker buildx create --name container --driver=docker-container || true
	docker build --builder container --platform $(PLATFORMS) -t $(IMG) .

.PHONY: docker-push
docker-push: ## Push docker image (multi-arch)
	docker buildx create --name container --driver=docker-container || true
	docker build --push --builder container --platform $(PLATFORMS) -t $(IMG) .

##@ Help

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
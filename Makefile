GOPATH     ?= $(shell go env GOPATH)
DEP        ?= $(GOPATH)/bin/dep
GORELEASER ?= $(GOPATH)/bin/goreleaser
VERSION    := v$(shell cat VERSION)

.PHONY: setup test build build-snapshot sync-tag release docker-build docker-release
all: setup test build build-snapshot sync-tag release docker-build docker-release

setup: $(DEP)
	@echo '>> setup'
	@$(DEP) ensure -v

test:
	@echo '>> unit test'
	@go test ./...

build:
	@echo '>> build'
	@go build -ldflags='\
	-X github.com/kobtea/dummy_exporter/vendor/github.com/prometheus/common/version.Version=$(shell cat VERSION) \
	-X github.com/kobtea/dummy_exporter/vendor/github.com/prometheus/common/version.Revision=$(shell git rev-parse HEAD) \
	-X github.com/kobtea/dummy_exporter/vendor/github.com/prometheus/common/version.Branch=$(shell git rev-parse --abbrev-ref HEAD) \
	-X github.com/kobtea/dummy_exporter/vendor/github.com/prometheus/common/version.BuildUser=$(shell whoami)@$(shell hostname) \
	-X github.com/kobtea/dummy_exporter/vendor/github.com/prometheus/common/version.BuildDate=$(shell date +%Y%m%d-%H:%M:%S)' \
	./

build-snapshot: $(GORELEASER)
	@echo '>> cross-build for testing'
	BUILD_BRANCH=$(shell git rev-parse --abbrev-ref HEAD) \
	BUILD_USER=$(shell whoami) \
	BUILD_HOST=$(shell hostname) \
	BUILD_DATE=$(shell date +%Y%m%d-%H:%M:%S) \
	$(GORELEASER) release --snapshot --rm-dist --debug

sync-tag:
	@git config user.name  || git config --local user.name  "circleci-job"
	@git config user.email || git config --local user.email "kobtea9696@gmail.com"
	@git rev-parse $(VERSION) > /dev/null 2>&1 || \
	(git tag -a $(VERSION) -m "release $(VERSION)" && git push origin $(VERSION))

release: $(GORELEASER)
	@echo '>> release'
	BUILD_BRANCH=$(shell git rev-parse --abbrev-ref HEAD) \
	BUILD_USER=$(shell whoami) \
	BUILD_HOST=$(shell hostname) \
	BUILD_DATE=$(shell date +%Y%m%d-%H:%M:%S) \
	$(GORELEASER) release --rm-dist --debug

docker-build:
	@echo '>> build docker image'
	@docker build -t kobtea/dummy_exporter:$(shell cat VERSION) .
	@docker build -t kobtea/dummy_exporter:latest .

docker-release: docker-build
	@echo '>> release docker image'
	@docker login -u ${DOCKERHUB_USER} -p ${DOCKERHUB_PASS}
	@docker push kobtea/dummy_exporter:$(shell cat VERSION)
	@docker push kobtea/dummy_exporter:latest

$(DEP):
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

$(GORELEASER): $(DEP)
	go get golang.org/x/tools/cmd/stringer
	go get -d github.com/goreleaser/goreleaser
	cd $(GOPATH)/src/github.com/goreleaser/goreleaser && \
	$(DEP) ensure -vendor-only && \
	make build && \
	mv ./goreleaser $(GOPATH)/bin

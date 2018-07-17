SHELL := /bin/bash
GO := GO15VENDOREXPERIMENT=1 go
NAME := helmez-bin

OS := $(shell uname)
MAIN_GO := helmez.go
ROOT_PACKAGE := github.com/ysaakpr/$(NAME)
GO_VERSION := $(shell $(GO) version | sed -e 's/^[^0-9.]*\([0-9.]*\).*/\1/')
PACKAGE_DIRS := $(shell $(GO) list ./... | grep -v /vendor/)
PKGS := $(shell go list ./... | grep -v /vendor | grep -v generated)
BUILDFLAGS := ''
CGO_ENABLED = 0
VENDOR_DIR=vendor

all: build

check: fmt build test

build:
	CGO_ENABLED=$(CGO_ENABLED) $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME) $(MAIN_GO)

test: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test $(PACKAGE_DIRS) -test.v

full: $(PKGS)

install:
	GOBIN=${GOPATH}/bin $(GO) install -ldflags $(BUILDFLAGS) $(MAIN_GO)

fmt:
	@FORMATTED=`$(GO) fmt $(PACKAGE_DIRS)`
	@([[ ! -z "$(FORMATTED)" ]] && printf "Fixed unformatted files:\n$(FORMATTED)") || true

clean:
	rm -rf build release bin

linux-amd64:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=amd64 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME).linux.amd64 $(MAIN_GO)
linux-386:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=386 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME).linux.386 $(MAIN_GO)
darwin-amd64:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=darwin GOARCH=amd64 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME).darwin.amd64 $(MAIN_GO)
darwin-386:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=darwin GOARCH=386 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME).darwin.386 $(MAIN_GO)
windows-amd64:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=windows GOARCH=amd64 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME).windows.amd64 $(MAIN_GO)
windows-386:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=windows GOARCH=386 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME).windows.386 $(MAIN_GO)

.PHONY: release clean

release-all: linux-amd64 linux-386 darwin-amd64 darwin-386

release-plugin: release-all
	sh  plugin-release.sh

FGT := $(GOPATH)/bin/fgt
$(FGT):
	go get github.com/GeertJohan/fgt

GOLINT := $(GOPATH)/bin/golint
$(GOLINT):
	go get github.com/golang/lint/golint

$(PKGS): $(GOLINT) $(FGT)
	@echo "LINTING"
	@$(FGT) $(GOLINT) $(GOPATH)/src/$@/*.go
	@echo "VETTING"
	@go vet -v $@
	@echo "TESTING"
	@go test -v $@

.PHONY: lint
lint: vendor | $(PKGS) $(GOLINT) # ❷
	@cd $(BASE) && ret=0 && for pkg in $(PKGS); do \
	    test -z "$$($(GOLINT) $$pkg | tee /dev/stderr)" || ret=1 ; \
	done ; exit $$ret


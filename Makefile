GOCMD=go
GOINSTALL=$(GOCMD) install
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get

BINARY_NAME=encryptodon
BINARY_DESC=Encrypted Mastodon CLI Client
BINARY_LINUX=$(BINARY_NAME)
BINARY_WINDOWS=$(BINARY_NAME).exe
BINARY_MACOS=$(BINARY_NAME)-darwin

VERSION=`git describe --tags --abbrev=0`
BUILDDATE=`date +%FT%T%z`
LDFLAGS=-ldflags "-w -s -X main.version=$(VERSION) -X main.buildDate=$(BUILDDATE)"

.PHONY: all
all:
    $(GOINSTALL)

.PHONY: test
test:
    $(GOTEST) -v ./...

.PHONY: build
build:
    env GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o bin/$(BINARY_LINUX) -v
    env GOOS=windows GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o bin/$(BINARY_WINDOWS) -v
    env GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o bin/$(BINARY_MACOS) -v

.PHONY: install
install:
    $(GOINSTALL) $(LDFLAGS)

.PHONY: clean
clean:
    $(GOCLEAN)
    if [ -f bin/$(BINARY_LINUX) ] ; then rm bin/$(BINARY_LINUX) ; fi
    if [ -f bin/$(BINARY_WINDOWS) ] ; then rm bin/$(BINARY_WINDOWS) ; fi
    if [ -f bin/$(BINARY_MACOS) ] ; then rm bin/$(BINARY_MACOS) ; fi

.PHONY: changelog
changelog:
    git pull
    git-chglog -o CHANGELOG.md
    git commit -a -m "changelog"
    git push
    git push origin $(VERSION)

.PHONY: release
release:
    hub release create -a "bin/$(BINARY_LINUX)#$(BINARY_LINUX) (Linux-amd64)" -a "bin/$(BINARY_WINDOWS)#$(BINARY_WINDOWS) (Windows-amd64)" -a "bin/$(BINARY_MACOS)#$(BINARY_MACOS) (MacOS-amd64)" -m "$(BINARY_NAME) $(VERSION)" -m "$(BINARY_DESC)" $(VERSION)

.PHONY: run
run:
    $(GOBUILD) -o $(BINARY_NAME) -v ./...
    ./$(BINARY_NAME)

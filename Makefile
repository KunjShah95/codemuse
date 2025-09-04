.PHONY: help build run test

help:
	@echo "build  - compile binaries"
	@echo "run    - run the agent locally"
	@echo "test   - run unit tests"

build:
	go build -o bin/agent ./cmd/agent
	go build -o bin/ui ./cmd/ui
	go build -o bin/web ./cmd/web

run: build
	./bin/agent

test:
	go test ./... -coverprofile=cover.out
	go tool cover -func=cover.out

.PHONY: help build run test

help:
	@echo "build  - compile binaries (when cmd/ directories exist)"
	@echo "run    - run the agent locally (when implemented)"
	@echo "test   - run unit tests"
	@echo "config - show current configuration"

build:
	@echo "Building project..."
	@if [ -d "cmd/agent" ]; then \
		go build -o bin/agent ./cmd/agent; \
	else \
		echo "cmd/agent directory not found - this will be available when core agent is implemented"; \
	fi
	@if [ -d "cmd/ui" ]; then \
		go build -o bin/ui ./cmd/ui; \
	else \
		echo "cmd/ui directory not found - this will be available when UI is implemented"; \
	fi
	@if [ -d "cmd/web" ]; then \
		go build -o bin/web ./cmd/web; \
	else \
		echo "cmd/web directory not found - this will be available when web UI is implemented"; \
	fi

run: 
	@echo "Run functionality will be available when agent is implemented"
	@echo "Current configuration:"
	@cat config.yaml

test:
	go test ./... -coverprofile=cover.out
	go tool cover -func=cover.out

config:
	@echo "Current configuration:"
	@cat config.yaml

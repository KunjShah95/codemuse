# Build stage
FROM golang:1.24-alpine AS build
WORKDIR /app
COPY . .
RUN go mod tidy && go build -o agent ./cmd/agent

# Final stage
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/agent /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/agent"]

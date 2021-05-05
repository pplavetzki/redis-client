# Build the manager binary
FROM golang:1.16.2 as builder

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.* ./
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

COPY main.go main.go

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -o redis-client /workspace/.

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /workspace/redis-client .
USER nonroot:nonroot

ENTRYPOINT ["/redis-client"]
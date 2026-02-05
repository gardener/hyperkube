### sleep go program that allows to instantiate a container to use `docker cp` for coping the binaries out of it

FROM golang:1.25.7 AS golang

RUN echo "package main\nimport \"time\"\nfunc main() { time.Sleep(time.Hour) }" > sleep.go && \
    GOOS=linux go build -o /sleep sleep.go

### binary downloader
# Arch specific stages are required to set arg appropriately, see https://github.com/docker/buildx/issues/157#issuecomment-538048500
FROM alpine:3.23 AS builder-amd64
ARG ARCH=amd64

FROM alpine:3.23 AS builder-arm64
ARG ARCH=arm64

FROM builder-$TARGETARCH AS builder
ARG KUBERNETES_VERSION

WORKDIR /tmp/hyperkube
COPY . .

RUN apk add --update --no-cache bash cosign && \
    scripts/get-k8s-binary.sh kubelet $KUBERNETES_VERSION linux/$ARCH && \
    scripts/get-k8s-binary.sh kubectl $KUBERNETES_VERSION linux/$ARCH

### actual container
FROM scratch

COPY --from=golang /sleep .
COPY --from=builder /tmp/hyperkube/kubelet /kubelet
COPY --from=builder /tmp/hyperkube/kubectl /kubectl

ENTRYPOINT ["/sleep"]

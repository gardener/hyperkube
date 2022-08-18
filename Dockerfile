### sleep go program that allows to instantiate a container to use `docker cp` for coping the binaries out of it

FROM golang:1.19 AS golang

RUN echo "package main\nimport \"time\"\nfunc main() { time.Sleep(time.Hour) }" > sleep.go && \
    GOOS=linux go build -o /sleep sleep.go

### binary downloader
# Arch specific stages are required to set arg appropriately, see https://github.com/docker/buildx/issues/157#issuecomment-538048500

FROM alpine:3.16 AS builder-amd64
ARG ARCH=amd64

FROM alpine:3.16 AS builder-arm64
ARG ARCH=arm64

FROM builder-$TARGETARCH as builder

WORKDIR /tmp/hyperkube
COPY . .

ARG KUBERNETES_VERSION

RUN wget https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/$ARCH/kubelet && \
    wget https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/$ARCH/kubectl && \
    chmod +x kubectl kubelet

### actual container

FROM scratch

COPY --from=golang /sleep .
COPY --from=builder /tmp/hyperkube/kubelet /kubelet
COPY --from=builder /tmp/hyperkube/kubectl /kubectl

ENTRYPOINT ["/sleep"]

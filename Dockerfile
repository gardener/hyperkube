### sleep go program that allows to instantiate a container to use `docker cp` for coping the binaries out of it

FROM golang:1.15 AS golang

RUN echo "package main\nimport \"time\"\nfunc main() { time.Sleep(time.Hour) }" > sleep.go && \
    GOOS=linux go build -o /sleep sleep.go

### binary downloader

FROM alpine:3.12 AS builder

WORKDIR /tmp/hyperkube
COPY . .

ARG KUBERNETES_VERSION

RUN wget https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubelet && \
    wget https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl

### actual container

FROM scratch

COPY --from=golang /sleep .
COPY --from=builder /tmp/hyperkube/kubelet /kubelet
COPY --from=builder /tmp/hyperkube/kubectl /kubectl

ENTRYPOINT ["/sleep"]

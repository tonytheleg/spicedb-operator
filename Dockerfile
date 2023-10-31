FROM registry.ci.openshift.org/openshift/release:rhel-8-release-golang-1.20-openshift-4.14 AS builder
WORKDIR /go/src/app

COPY go.mod go.sum ./
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build --mount=type=cache,target=/go/pkg/mod go mod download && \
    go mod tidy && \
    GOEXPERIMENT=strictfipsruntime,boringcrypto GOOS=linux GOARCH=amd64 CGO_ENABLED=1 GOFLAGS="" go build -tags=fips_enabled -gcflags=all=-trimpath=/go -asmflags=all=-trimpath=/go ./cmd/...

FROM FROM registry.access.redhat.com/ubi8/ubi-minimal:8.8-1072.1697626218

COPY --from=builder /go/src/app/validated-update-graph.yaml /opt/operator/config.yaml
COPY --from=builder /go/src/app/spicedb-operator /usr/local/bin/spicedb-operator
ENTRYPOINT ["spicedb-operator"]

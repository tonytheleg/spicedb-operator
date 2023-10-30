FROM registry.ci.openshift.org/openshift/release:golang-1.20 AS builder
WORKDIR /go/src/app
ENV CGO_ENABLED=1

COPY go.mod go.sum ./
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build --mount=type=cache,target=/go/pkg/mod go build ./cmd/...

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest 

COPY --from=builder /go/src/app/validated-update-graph.yaml /opt/operator/config.yaml
COPY --from=builder /go/src/app/spicedb-operator /usr/local/bin/spicedb-operator
ENTRYPOINT ["spicedb-operator"]

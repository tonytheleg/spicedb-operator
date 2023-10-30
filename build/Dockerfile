FROM quay.io/app-sre/boilerplate:image-v3.0.5 AS builder

WORKDIR /workdir
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download
COPY . .
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=1 GOFLAGS="" GOOS=linux go build -tags strictfipsruntime -gcflags=all=-trimpath=/go -asmflags=all=-trimpath=/go -o build/_output/bin/spicedb-operator .

####
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.8-1072

ENV USER_UID=1001 \
    USER_NAME=spicedb-operator

COPY --from=builder /workdir/validated-update-graph.yaml /opt/operator/config.yaml
COPY --from=builder /workdir/build/_output/bin/* /usr/local/bin/


COPY build/bin /usr/local/bin
RUN  /usr/local/bin/user_setup

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}

LABEL io.openshift.managed.name="spicedb-operator" \
      io.openshift.managed.description="Operator to manage registering clusters with GoAlert"

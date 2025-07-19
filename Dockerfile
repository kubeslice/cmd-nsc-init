# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM golang:1.24.4 AS go

ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOBIN=/bin

RUN go install github.com/go-delve/delve/cmd/dlv@v1.22.1

ARG SPIRE_VERSION=1.12.3
RUN case "${TARGETARCH}" in \
        "amd64") SPIRE_ARCH="amd64" ;; \
        "arm64") SPIRE_ARCH="arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -sSL -o spire.tar.gz \
        "https://github.com/spiffe/spire/releases/download/v${SPIRE_VERSION}/spire-${SPIRE_VERSION}-linux-${SPIRE_ARCH}-musl.tar.gz" && \
    tar xzf spire.tar.gz -C /bin --strip=2 \
        "spire-${SPIRE_VERSION}/bin/spire-server" \
        "spire-${SPIRE_VERSION}/bin/spire-agent" && \
    rm spire.tar.gz

FROM --platform=$BUILDPLATFORM go AS build
ARG TARGETOS
ARG TARGETARCH

WORKDIR /build
COPY go.mod go.sum ./
COPY ./internal/imports imports

RUN go mod download
RUN go build ./imports
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /bin/app .

FROM build AS test
CMD ["go", "test", "-test.v", "./..."]

FROM test AS debug
CMD ["dlv", "-l", ":40000", "--headless=true", "--api-version=2", "test", "-test.v", "./..."]

FROM gcr.io/distroless/static-debian12:nonroot AS runtime
COPY --from=build /bin/app /bin/app
USER 65532:65532
ENTRYPOINT ["/bin/app"]
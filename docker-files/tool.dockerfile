FROM golang:1.24.5-bookworm

RUN apt update && apt -y install mc && \
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest && \
    go install github.com/swaggo/swag/cmd/swag@v1.16.6 && \
    go install github.com/yitsushi/totp-cli@v1.9.2

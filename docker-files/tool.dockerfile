FROM golang:1.24.5-bookworm

RUN apt update && apt -y install mc
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

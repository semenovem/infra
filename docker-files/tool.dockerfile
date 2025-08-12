FROM golang:1.24.5-bookworm

RUN apt update && apt -y install mc

RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
RUN go install github.com/swaggo/swag/cmd/swag@v1.16.6

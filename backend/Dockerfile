FROM golang:1.21 AS builder

RUN apt-get update && apt-get install -y curl && \
        curl -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz | tar xvz && \
        mv migrate /usr/local/bin/migrate

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod tidy

COPY . .

RUN go build -o main .

CMD migrate -path ./migrations -database "postgres://admin:secret@postgres:5432/chillspot?sslmode=disable" up && ./main

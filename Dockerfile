
FROM node:20-alpine AS frontend


WORKDIR /frontend

RUN apk add --no-cache python3 py3-pip make g++


COPY ./frontend/chatapp/package.json ./frontend/chatapp/package-lock.json ./


RUN npm install
COPY ./frontend/chatapp ./
RUN npm run build


FROM golang:1.20-alpine AS backend

WORKDIR /app

COPY ./backend/go.mod ./backend/go.sum ./
RUN go mod download

COPY ./backend ./
RUN go build -o chatapp

FROM alpine:latest

WORKDIR /app

# Copy backend binary and frontend build
COPY --from=backend /app/chatapp .
COPY --from=frontend /frontend/build /app/frontend

EXPOSE 8080 3000

CMD ["./chatapp"]

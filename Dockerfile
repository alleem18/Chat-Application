# ===========================
# Stage 1: Build the Frontend (Updated)
# ===========================
FROM node:20-alpine AS frontend

# Set the working directory for the frontend
WORKDIR /frontend

# Install Python and build tools (node-gyp requirements)
RUN apk add --no-cache python3 py3-pip make g++

# Copy the frontend files
COPY ./frontend/chatapp/package.json ./frontend/chatapp/package-lock.json ./

# Install dependencies and build the React app
RUN npm install
COPY ./frontend/chatapp ./
RUN npm run build

# ===========================
# Stage 2: Build the Backend (Unchanged)
# ===========================
FROM golang:1.20-alpine AS backend

WORKDIR /app

COPY ./backend/go.mod ./backend/go.sum ./
RUN go mod download

COPY ./backend ./
RUN go build -o chatapp

# ===========================
# Stage 3: Final Image
# ===========================
FROM alpine:latest

WORKDIR /app

# Copy backend binary and frontend build
COPY --from=backend /app/chatapp .
COPY --from=frontend /frontend/build /app/frontend

EXPOSE 8080 3000

CMD ["./chatapp"]

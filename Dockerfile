
# -------- Build stage --------
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Install git (needed for go mod download)
RUN apk add --no-cache git

# Copy go mod files first (cache optimization)
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -o app

# -------- Runtime stage --------
FROM gcr.io/distroless/base-debian12

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/app /app/app

# Expose app port (adjust if needed)
EXPOSE 8080

# Run the app
USER nonroot:nonroot
ENTRYPOINT ["/app/app"]

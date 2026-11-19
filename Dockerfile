FROM python:3.12.16-slim-trixie

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends socat curl && rm -rf /var/lib/apt/lists/*

# Create data directory for C2
RUN mkdir -p /data

WORKDIR /app

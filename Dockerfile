# Use a lightweight Debian-based image
FROM debian:stable-slim

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y curl unzip xz-utils git && \
    rm -rf /var/lib/apt/lists/*

# Download and install the latest stable Flutter version
RUN curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux.tar.xz | tar -xJ

# Set Flutter path
ENV PATH="/app/flutter/bin:$PATH"

# Verify Flutter installation
RUN flutter --version

# Copy project files
COPY . .

# Enable Flutter web
RUN flutter config --enable-web

# Get dependencies
RUN flutter pub get

# Build the Flutter web app
RUN flutter build web

# Expose the web server port
EXPOSE 8080

# Start a simple HTTP server
CMD ["python3", "-m", "http.server", "-d", "/app/build/web", "8080"]

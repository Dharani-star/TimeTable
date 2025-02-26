# Use a base image with Debian/Ubuntu for compatibility
FROM debian:latest

# Set environment variables
ENV FLUTTER_VERSION=3.7.0  
ENV FLUTTER_HOME=/flutter

# Install required dependencies
RUN apt update && apt install -y \
    git curl unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Set Flutter path
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Verify Flutter installation
RUN flutter --version

# Enable Flutter web
RUN flutter config --enable-web

# Create a directory for the app
WORKDIR /app

# Copy pubspec and get dependencies first (to leverage Docker cache)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the app
COPY . .

# Build the Flutter web app
RUN flutter build web

# Expose the port for serving the web app
EXPOSE 8080

# Use a lightweight HTTP server to serve the app
CMD ["sh", "-c", "cd build/web && python3 -m http.server 8080"]

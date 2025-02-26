# Use a base image with Debian/Ubuntu for compatibility
FROM debian:latest

# Set environment variables
ENV FLUTTER_VERSION=3.7.0  
ENV FLUTTER_HOME=/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Install required dependencies
RUN apt update && apt install -y \
    git curl unzip xz-utils zip libglu1-mesa \
    openjdk-11-jdk && \
    rm -rf /var/lib/apt/lists/*

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Verify Flutter installation
RUN flutter --version

# Enable Flutter web
RUN flutter config --enable-web

# Pre-download all required Flutter dependencies, including Gradle
RUN flutter precache

# Create a directory for the app
WORKDIR /app

# Copy pubspec and get dependencies first (to leverage Docker cache)
COPY pubspec.yaml pubspec.lock ./

# Run pub get separately to ensure dependencies are installed before copying full app
RUN flutter pub get || (flutter clean && flutter pub get)

# Copy the rest of the app
COPY . .

# Build the Flutter web app
RUN flutter build web

# Expose the port for serving the web app
EXPOSE 8080

# Use a lightweight HTTP server to serve the app
CMD ["sh", "-c", "cd build/web && python3 -m http.server 8080"]

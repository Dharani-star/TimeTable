# Use an official Flutter image
FROM cirrusci/flutter:stable

# Set the working directory inside the container
WORKDIR /app

# Copy the Flutter project files into the container
COPY . .

# Get dependencies
RUN flutter pub get

# Build the Flutter web app
RUN flutter build web

# Expose the port for the web server
EXPOSE 8080

# Start a simple HTTP server to serve the web app
CMD ["python3", "-m", "http.server", "-d", "/app/build/web", "8080"]

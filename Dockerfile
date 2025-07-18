# Build stage
FROM swift:6.1.2-jammy AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
  libssl-dev \
  libcurl4-openssl-dev \
  git \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy entire project
COPY . .

# Clean any previous builds
RUN rm -rf .build

# Build the application
RUN swift build -c release --product F1DashServer

# Runtime stage
FROM swift:6.0-jammy-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
  libssl3 \
  libcurl4 \
  && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1001 -s /bin/bash f1dash

# Set working directory
WORKDIR /app

# Copy built executable from builder
COPY --from=builder /app/.build/release/F1DashServer /app/F1DashServer

# Copy simulation data if needed
COPY --from=builder /app/scripts /app/scripts

# Change ownership
RUN chown -R f1dash:f1dash /app

# Switch to non-root user
USER f1dash

# Expose port
EXPOSE 3000

# Set environment variables
ENV LOG_LEVEL=info
ENV HOST=0.0.0.0
ENV PORT=3000

# Run the server
ENTRYPOINT ["/app/F1DashServer"]
CMD ["--host", "0.0.0.0", "--port", "3000"]

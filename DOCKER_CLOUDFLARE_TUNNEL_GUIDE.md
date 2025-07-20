# Docker + Cloudflare Tunnel Setup for iPhone Testing

This guide will help you run F1DashServer in Docker and expose it via Cloudflare Tunnel for testing on your iPhone.

## Prerequisites

- Docker Desktop installed on your Mac
- Homebrew installed
- An iPhone connected to the internet

## Step 1: Build and Run Docker Container

1. **Build the Docker image**:
```bash
cd /Users/frankmac/projects/learn_swift/f1-dash-ui-improve
docker build -t f1-dash-server .
```

2. **Run the Docker container**:
```bash
docker run -d --name f1-dash -p 8080:8080 f1-dash-server
```

3. **Verify it's running**:
```bash
# Check if container is running
docker ps

# Check the logs
docker logs f1-dash

# Test locally
curl http://localhost:8080/health
```

## Step 2: Setup Cloudflare Tunnel

1. **Install Cloudflare Tunnel**:
```bash
brew install cloudflare/cloudflare/cloudflared
```

2. **Start a quick tunnel** (easiest for testing):
```bash
cloudflared tunnel --url http://localhost:8080
```

3. **Look for your public URL** in the output:
```
+--------------------------------------------------------------------------------------------+
|  Your quick tunnel has been created! Visit it at:                                         |
|  https://random-name-here.trycloudflare.com                                              |
+--------------------------------------------------------------------------------------------+
```

## Step 3: Configure Your iPhone App

1. **Find where the server URL is configured** in your iOS app code:
```bash
grep -r "localhost:8080" F1DashAppXCode/
```

2. **Update the server URL** to use your Cloudflare tunnel URL.

3. **Build and deploy** to your iPhone via Xcode.

## Docker Commands Reference

```bash
# Stop the container
docker stop f1-dash

# Start it again
docker start f1-dash

# Remove the container
docker rm f1-dash

# Rebuild after code changes
docker build -t f1-dash-server .
docker run -d --name f1-dash -p 8080:8080 f1-dash-server

# View real-time logs
docker logs -f f1-dash
```

## Advanced: Docker Compose Setup

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  f1-dash-server:
    build: .
    ports:
      - "8080:8080"
    environment:
      - LOG_LEVEL=debug
      - HOST=0.0.0.0
      - PORT=8080
    restart: unless-stopped
```

Then run:
```bash
docker-compose up -d
```

## Persistent Cloudflare Tunnel (Optional)

For a more permanent setup with a custom subdomain:

1. **Login to Cloudflare**:
```bash
cloudflared tunnel login
```

2. **Create a named tunnel**:
```bash
cloudflared tunnel create f1-dash-iphone
```

3. **Create tunnel config** at `~/.cloudflared/config.yml`:
```yaml
tunnel: f1-dash-iphone
credentials-file: /Users/frankmac/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: f1-dash-test.example.com
    service: http://localhost:8080
  - service: http_status:404
```

4. **Add DNS route** (if using your own domain):
```bash
cloudflared tunnel route dns f1-dash-iphone f1-dash-test.example.com
```

5. **Run the tunnel**:
```bash
cloudflared tunnel run f1-dash-iphone
```

## Troubleshooting

**Container not starting?**
```bash
# Check logs
docker logs f1-dash

# Check if port 8080 is already in use
lsof -i :8080
```

**Tunnel not working?**
```bash
# Test local connection first
curl http://localhost:8080/health

# Make sure Docker container is running
docker ps

# Try restarting both
docker restart f1-dash
# Then restart cloudflared tunnel
```

**iPhone can't connect?**
- Ensure you're using HTTPS URL from Cloudflare
- Check that the tunnel is still running
- Verify the URL is correctly set in your iOS app

## Security Notes

- Cloudflare tunnels are public by default
- Consider adding authentication to your server
- Only run tunnels during active testing
- Stop the tunnel when done: `Ctrl+C` in the terminal

## Quick Start Script

Save this as `start-dev-tunnel.sh`:

```bash
#!/bin/bash

echo "Starting F1 Dash Server in Docker..."
docker stop f1-dash 2>/dev/null
docker rm f1-dash 2>/dev/null
docker build -t f1-dash-server .
docker run -d --name f1-dash -p 8080:8080 f1-dash-server

echo "Waiting for server to start..."
sleep 5

echo "Starting Cloudflare Tunnel..."
cloudflared tunnel --url http://localhost:8080
```

Make it executable:
```bash
chmod +x start-dev-tunnel.sh
./start-dev-tunnel.sh
```

This will build, run, and tunnel your server in one command!
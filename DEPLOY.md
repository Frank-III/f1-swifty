# Deploying F1 Dashboard to Fly.io

## Prerequisites

1. Install Fly CLI:
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. Sign up/Login to Fly.io:
   ```bash
   fly auth login
   ```

## Initial Deployment

1. Create the Fly app (first time only):
   ```bash
   fly launch --no-deploy
   ```
   
   When prompted:
   - App name: `f1-dashboard` (or your preferred name)
   - Region: Choose closest to your users (e.g., `iad` for US East)
   - Postgres database: No (unless you need it)
   - Redis: No (unless you need it)

2. Deploy the application:
   ```bash
   fly deploy
   ```

## Configuration

The `fly.toml` file is already configured with:
- Primary region: `iad` (US East)
- Ports: 8080 (HTTP/HTTPS) and 3001 (WebSocket)
- Memory: 512MB
- CPU: 1 shared CPU
- Auto-scaling: 20-25 concurrent connections

## Environment Variables

To set environment variables:
```bash
fly secrets set LOG_LEVEL=info
fly secrets set F1_API_KEY=your_api_key_here
```

## Monitoring

View logs:
```bash
fly logs
```

Check app status:
```bash
fly status
```

SSH into the container:
```bash
fly ssh console
```

## Updating the Deployment

After making changes:
```bash
fly deploy
```

## Scaling

Scale horizontally:
```bash
fly scale count 2  # Run 2 instances
```

Scale vertically:
```bash
fly scale vm shared-cpu-1x --memory 1024  # Increase to 1GB RAM
```

## Custom Domain

1. Add your domain:
   ```bash
   fly certs add yourdomain.com
   ```

2. Configure DNS with the provided CNAME/A records

## Troubleshooting

- If deployment fails, check logs: `fly logs`
- Ensure the Swift version in Dockerfile.linux matches your local version
- The app uses Dockerfile.linux which is optimized for Linux deployment
- WebSocket connections use port 3001

## Costs

- Free tier includes 3 shared VMs with 256MB RAM
- Current config (512MB) will use paid resources
- Monitor usage: `fly dashboard`
# Hello World

A simple React app served through an nginx reverse proxy. Public HTTPS is provided by a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) (no public IP or Let’s Encrypt required).

## Requirements

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose
- A free [Cloudflare](https://dash.cloudflare.com) account
- Domain `olama.so` using Cloudflare nameservers

## Run locally (no tunnel)

```bash
docker compose up -d --build
```

Open [http://localhost](http://localhost). nginx listens on port **80** and proxies to the React frontend.

Stop:

```bash
docker compose down
```

## Cloudflare Tunnel (https://olama.so)

1. Add `olama.so` to Cloudflare and point Namecheap nameservers at the two Cloudflare NS records. Wait until the zone is **Active**.

2. Zero Trust → Networks → Tunnels → Create a **Cloudflared** tunnel. Copy the token.

3. In the tunnel, add Public Hostnames:

   | Subdomain | Domain   | Type | URL              |
   |-----------|----------|------|------------------|
   | *(empty)* | olama.so | HTTP | `http://nginx:80` |
   | www       | olama.so | HTTP | `http://nginx:80` |

4. SSL/TLS → Overview → **Full**. Optional: Edge Certificates → Always Use HTTPS.

5. On the host:

   ```bash
   cp .env.example .env
   ```

   Put the tunnel token in `.env` as `TUNNEL_TOKEN=...` (keep `COMPOSE_PROFILES=cloudflare`).

6. Start the stack:

   ```bash
   docker compose up -d --build
   docker compose logs -f cloudflared
   ```

   Connector logs should show the tunnel is connected. Then open [https://olama.so](https://olama.so).

Cloudflare terminates HTTPS. The tunnel reaches nginx over HTTP on the Docker network (`http://nginx:80`). Do not point DNS at a Tailscale or CGNAT address.

## Local development (without Docker)

```bash
cd frontend
npm install
npm run dev
```

The Vite dev server runs at [http://localhost:3000](http://localhost:3000).

## Project layout

```
├── docker-compose.yml    # frontend, nginx, cloudflared
├── .env.example          # TUNNEL_TOKEN (copy to .env)
├── frontend/             # Vite + React app
│   └── Dockerfile
└── nginx/
    └── nginx.conf        # reverse proxy to frontend:3000
```

# Hello World

A simple React app served through an nginx reverse proxy. Public HTTPS is provided by a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) run separately (no public IP or Let’s Encrypt required).

## Requirements

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose
- A free [Cloudflare](https://dash.cloudflare.com) account
- Domain `olama.so` using Cloudflare nameservers

## Run the app

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

3. In the tunnel, add Public Hostnames. Because `cloudflared` runs **outside** this Compose file, the origin is the host, not the `nginx` service name:

   | Subdomain | Domain   | Type | URL                 |
   |-----------|----------|------|---------------------|
   | *(empty)* | olama.so | HTTP | `http://127.0.0.1:80` |
   | www       | olama.so | HTTP | `http://127.0.0.1:80` |

4. SSL/TLS → Overview → **Full**. Optional: Edge Certificates → Always Use HTTPS.

5. Start the app with Compose, then start the tunnel on the host (`--network host` so `127.0.0.1:80` is nginx on this machine):

   ```bash
   docker compose up -d --build

   sudo docker run -d --name cloudflared --restart unless-stopped --network host \
     cloudflare/cloudflared:latest tunnel --no-autoupdate run --token YOUR_TOKEN
   ```

   Connector logs (`docker logs -f cloudflared`) should show the tunnel is connected. Then open [https://olama.so](https://olama.so).

Do not commit the tunnel token. Do not point DNS at a Tailscale or CGNAT address.

## Local development (without Docker)

```bash
cd frontend
npm install
npm run dev
```

The Vite dev server runs at [http://localhost:3000](http://localhost:3000).

## Project layout

```
├── docker-compose.yml    # frontend + nginx
├── frontend/             # Vite + React app
│   └── Dockerfile
└── nginx/
    └── nginx.conf        # reverse proxy to frontend:3000
```

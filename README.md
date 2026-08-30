# Hello World

A simple React app served through an nginx reverse proxy, run with Docker Compose. TLS is issued by Let’s Encrypt.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose
- DNS A records for `olama.so` and `www.olama.so` pointing at the VPS **public** IP
- Ports **80** and **443** open on the host firewall

## Run with Docker

From the project root:

```bash
docker compose up -d --build
```

nginx listens on ports **80** and **443** and proxies to the React frontend. Until a real certificate is issued, it uses a temporary self-signed cert.

Stop the stack:

```bash
docker compose down
```

## Let’s Encrypt TLS

1. Confirm the site answers on HTTP (needed for the ACME challenge):

   ```bash
   curl -I http://olama.so
   ```

2. Issue the certificate (set `EMAIL` to a real address):

   ```bash
   chmod +x init-letsencrypt.sh
   EMAIL=you@olama.so ./init-letsencrypt.sh
   ```

   If `www.olama.so` has no DNS record, remove it from `domains` in `init-letsencrypt.sh` first.

3. Open [https://olama.so](https://olama.so).

To re-issue, run `FORCE=1 EMAIL=you@olama.so ./init-letsencrypt.sh`.

### Renewal

Certificates last 90 days. Add a cron job on the VPS:

```bash
0 3 * * * cd /apps/boiler-plate && docker compose run --rm --no-deps certbot renew && docker compose exec nginx nginx -s reload
```

## Local development (without Docker)

```bash
cd frontend
npm install
npm run dev
```

The Vite dev server runs at [http://localhost:3000](http://localhost:3000).

## Project layout

```
├── docker-compose.yml    # frontend, nginx, certbot
├── init-letsencrypt.sh   # issue / replace Let’s Encrypt certs
├── certbot/              # certificates and ACME webroot (not committed)
├── frontend/             # Vite + React app
│   └── Dockerfile
└── nginx/
    └── nginx.conf        # HTTP→HTTPS, ACME challenge, reverse proxy
```

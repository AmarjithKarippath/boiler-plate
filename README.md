# Hello World

A simple React app served through an nginx reverse proxy, run with Docker Compose.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose

## Run with Docker

From the project root:

```bash
docker compose up --build
```

Then open [http://olama.so](http://olama.so) (or [http://localhost](http://localhost) on this machine).

nginx listens on port **80** and proxies requests to the React frontend container. Point the domain’s A record at the VPS public IP.

Stop the stack:

```bash
docker compose down
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
├── docker-compose.yml    # frontend + nginx services
├── frontend/             # Vite + React app
│   └── Dockerfile
└── nginx/
    └── nginx.conf        # reverse proxy to frontend:3000
```

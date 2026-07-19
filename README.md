# docker-gephi-lite-path

A Docker container that serves [**Gephi Lite**](https://github.com/gephi/gephi-lite) - the
open-source graph exploration and visualization tool - as static assets rooted at
**`/gephi-lite/`**, so it drops cleanly behind a reverse proxy or alongside other web
apps on the same host.

Maintained by **[PSA Intelligence](https://github.com/psaintelligence)**.

## Features

Gephi Lite runs entirely in the browser - this container only ships the compiled
static build with nginx. There is no server-side processing, persistence layer, or
graph compute endpoint.

- **Path-rooted** - served from `/gephi-lite/` so it can sit behind any path-aware
  reverse proxy without conflicts.
- **Static hosting** - shipped as a single nginx container, trivially deployable
  behind any reverse proxy or load balancer.
- **Pinned upstream releases** - each image tag is built from a specific
  `gephi/gephi-lite` release for reproducibility.

## Quick start

Images are published to both Docker Hub and the GitHub Container Registry (GHCR).
Pick whichever registry you prefer - the image content is identical.

```bash
# Docker Hub
docker pull psaintelligence/gephi-lite-path:latest

# GHCR
docker pull ghcr.io/psaintelligence/gephi-lite-path:latest

# Run on http://localhost:8080/gephi-lite/
docker run -d \
  --name gephi-lite \
  -p 8080:80 \
  --restart unless-stopped \
  psaintelligence/gephi-lite-path:latest
```

Open <http://localhost:8080/gephi-lite/> in your browser.

> The trailing slash matters: the app is rooted at `/gephi-lite/`, so relative
> asset paths resolve correctly only when the path ends with `/`.

### Docker Compose

```yaml
services:
  gephi-lite:
    image: ghcr.io/psaintelligence/gephi-lite-path:latest  # or psaintelligence/gephi-lite-path:latest
    ports:
      - "8080:80"
    restart: unless-stopped
```

```bash
docker compose up -d
```

### Serving behind a reverse proxy

Because the app is rooted at `/gephi-lite/`, you can place it behind any path-aware
front proxy. Example with nginx upstream:

```nginx
location /gephi-lite/ {
    proxy_pass http://gephi-lite:80/gephi-lite/;
    proxy_set_header Host              $host;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Container Repos
- Docker Hub - <https://hub.docker.com/r/psaintelligence/gephi-lite-path/tags>
- GHCR - <https://github.com/psaintelligence/docker-gephi-lite-path/pkgs/container/gephi-lite-path>

## Building from source

This repository clones the upstream `gephi/gephi-lite` source at a pinned tag,
runs `npm install` + `npm run build` with `BASE_URL=/gephi-lite/`, then ships the
compiled static output with nginx.

```bash
git clone https://github.com/psaintelligence/docker-gephi-lite-path.git
cd docker-gephi-lite-path

# Build with the default upstream tag (@gephi/gephi-lite@1.0.2)
docker build -t gephi-lite-path:local .

# Build against a different upstream tag
docker build -t gephi-lite-path:local \
  --build-arg COMMIT_TAG='@gephi/gephi-lite@1.0.2' .

docker run --rm -p 8080:80 gephi-lite-path:local
```

See the [`Dockerfile`](./Dockerfile) for the full multi-stage build definition.

## Credits

- **Upstream project** - [`gephi/gephi-lite`](https://github.com/gephi/gephi-lite).

## License

GNU General Public License v3.0 - see [`LICENSE`](./LICENSE).

# Playwright Node on Ubuntu 24.04

Docker image with:

- Ubuntu 24.04
- Node.js
- Yarn
- Playwright **browsers + dependencies** preinstalled
- Non-root user: `pwuser`
- Versioned by **Playwright version**

Image name (example):

`ferraobox/playwright-node`

## Tags

- `<PLAYWRIGHT_VERSION>` – Playwright version used in the image (e.g. `1.56.0`)
- `latest` – always points to the most recently published Playwright version

Examples:

- `ferraobox/playwright-node:1.56.0`
- `ferraobox/playwright-node:latest`

## How the versioning works

The Playwright version is provided at build time via:

```dockerfile
ARG PLAYWRIGHT_VERSION
````

That version is used to:

1. Install `playwright-core@PLAYWRIGHT_VERSION` inside the image
2. Mark the docker image via `mark-docker-image`
3. Tag the pushed Docker image as `<PLAYWRIGHT_VERSION>` and `latest`

## Local build

```bash
PLAYWRIGHT_VERSION=1.49.0

docker build \
  --build-arg PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION} \
  --build-arg DOCKER_IMAGE_NAME_TEMPLATE="mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble" \
  -t ferraobox/playwright-node:${PLAYWRIGHT_VERSION} \
  -t ferraobox/playwright-node:latest \
  .
```

## Usage

Run a container:

```bash
docker run --rm -it \
  ferraobox/playwright-node:latest \
  bash
```

Run Playwright tests from a host project (mount current directory):

```bash
docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  ferraobox/playwright-node:latest \
  npx playwright test
```

The default user inside the container is `pwuser`.

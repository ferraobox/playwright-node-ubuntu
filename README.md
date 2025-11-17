# Playwright Node on Ubuntu 24.04

Docker image with:

- Ubuntu 24.04
- Node.js 22 (NodeSource)
- Yarn
- Playwright **browsers + dependencies** preinstalled
- Non-root user: `pwuser`
- Versioned by **Playwright version**

Image name (example):

`your-dockerhub-username/playwright-node22-ubuntu24.04`

## Tags

- `<PLAYWRIGHT_VERSION>` – Playwright version used in the image (e.g. `1.49.0`)
- `latest` – always points to the most recently published Playwright version

Examples:

- `your-dockerhub-username/playwright-node22-ubuntu24.04:1.49.0`
- `your-dockerhub-username/playwright-node22-ubuntu24.04:latest`

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
  -t your-dockerhub-username/playwright-node22-ubuntu24.04:${PLAYWRIGHT_VERSION} \
  -t your-dockerhub-username/playwright-node22-ubuntu24.04:latest \
  .
```

## Usage

Run a container:

```bash
docker run --rm -it \
  your-dockerhub-username/playwright-node22-ubuntu24.04:latest \
  bash
```

Run Playwright tests from a host project (mount current directory):

```bash
docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  your-dockerhub-username/playwright-node22-ubuntu24.04:latest \
  npx playwright test
```

The default user inside the container is `pwuser`.

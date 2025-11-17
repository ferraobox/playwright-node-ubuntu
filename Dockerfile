# syntax=docker/dockerfile:1.4

FROM ubuntu:24.04

# Build-time args
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Los_Angeles
ARG PLAYWRIGHT_VERSION="1.56.0"
ARG DOCKER_IMAGE_NAME_TEMPLATE="mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble"

# Basic env
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=${TZ} \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION}

# 1) Keep Ubuntu up to date and install Node 25 + patched npm + Yarn
RUN set -eux; \
    # bring base image to latest security fixes
    apt-get update; \
    apt-get -y dist-upgrade; \
    # minimal tools needed just for NodeSource repo setup
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gpg \
    ; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_25.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs; \
    # *** important: upgrade npm so it pulls a fixed glob version ***
    npm install -g npm@latest yarn@1.22.22 dd-trace; \
    npm cache clean --force; \
    # tools above are no longer needed at runtime – drop them to reduce surface
    apt-get purge -y curl wget gpg; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

# 2) Install playwright-core@PLAYWRIGHT_VERSION and all browsers / system deps
RUN set -eux; \
    mkdir /ms-playwright /ms-playwright-agent; \
    cd /ms-playwright-agent; \
    npm init -y >/dev/null 2>&1; \
    npm i playwright-core@"${PLAYWRIGHT_VERSION}"; \
    npx playwright-core mark-docker-image "${DOCKER_IMAGE_NAME_TEMPLATE}"; \
    # this installs browsers AND required Ubuntu libraries
    npx playwright install --with-deps; \
    # cleanup
    rm -rf /var/lib/apt/lists/* /ms-playwright-agent ~/.npm; \
    chmod -R 777 /ms-playwright

# 3) Final OS security refresh for libraries that Playwright just installed
RUN set -eux; \
    apt-get update; \
    apt-get -y dist-upgrade; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["/bin/bash"]

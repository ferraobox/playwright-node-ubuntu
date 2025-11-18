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

# 1) Keep Ubuntu up to date and install Node 25 (with bundled npm just for build)
RUN set -eux; \
    apt-get update; \
    apt-get -y dist-upgrade; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gpg \
    ; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_25.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*

# 2) Install playwright@PLAYWRIGHT_VERSION and all browsers / system deps using npm,
RUN set -eux; \
    mkdir -p /ms-playwright /ms-playwright-agent; \
    cd /ms-playwright-agent; \
    npm init -y >/dev/null 2>&1; \
    npm install -g playwright@"${PLAYWRIGHT_VERSION}"; \
    npx playwright mark-docker-image "${DOCKER_IMAGE_NAME_TEMPLATE}"; \
    npx playwright install --with-deps; \
    cd /; \
    rm -rf /ms-playwright-agent ~/.npm; \
    chmod -R 777 /ms-playwright; \
    rm -rf /usr/lib/node_modules/npm /usr/bin/npm /usr/bin/npx; \
    apt-get purge -y curl gpg || true; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

# 3) Final OS security refresh + remove high-risk media plugins (CVE-2025-3887 etc.)
RUN set -eux; \
    apt-get update; \
    apt-get -y dist-upgrade; \
    apt-get purge -y \
      'gstreamer1.0-plugins-bad*' \
      'libgstreamer-plugins-bad1.0-0' \
      'gstreamer1.0-libav' \
      || true; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["/bin/bash"]

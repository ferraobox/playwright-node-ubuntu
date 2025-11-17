# syntax=docker/dockerfile:1.4

FROM ubuntu:24.04

# Build-time args
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Los_Angeles
ARG PLAYWRIGHT_VERSION="1.49.0"
ARG DOCKER_IMAGE_NAME_TEMPLATE="mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble"

# Basic env
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=${TZ} \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION}

# Install Node 25, git, openssh-client, yarn
RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND} \
    TZ=${TZ} \
    DOCKER_IMAGE_NAME_TEMPLATE=${DOCKER_IMAGE_NAME_TEMPLATE} \
    /bin/sh -c 'apt-get update && \
    apt-get install -y curl wget gpg ca-certificates && \
    mkdir -p /etc/apt/keyrings && \
    curl -sL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_25.x nodistro main" \
      >> /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get install -y --no-install-recommends git openssh-client && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/* && \
    adduser --disabled-password --gecos "" pwuser'

# Install playwright-core@PLAYWRIGHT_VERSION and all browsers/OS deps
RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND} \
    TZ=${TZ} \
    DOCKER_IMAGE_NAME_TEMPLATE=${DOCKER_IMAGE_NAME_TEMPLATE} \
    PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION} \
    /bin/sh -c 'mkdir /ms-playwright && \
    mkdir /ms-playwright-agent && \
    cd /ms-playwright-agent && npm init -y >/dev/null 2>&1 && \
    npm i playwright-core@"${PLAYWRIGHT_VERSION}" && \
    npx playwright-core mark-docker-image "${DOCKER_IMAGE_NAME_TEMPLATE}" && \
    npx playwright-core install --with-deps && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /ms-playwright-agent && \
    rm -rf ~/.npm/ && \
    chmod -R 777 /ms-playwright'

# Optional: install some global helpers via yarn (customise as you like)
RUN yarn global add \
    playwright \
    @playwright/test

WORKDIR /work
USER pwuser
CMD ["/bin/bash"]

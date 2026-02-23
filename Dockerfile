
# https://hub.docker.com/r/alpine/git/
FROM docker.io/alpine/git:latest AS clone

# https://github.com/gephi/gephi-lite/tags
#  @gephi/gephi-lite@1.0.2 = 2025-12-01
ARG COMMIT_TAG=" @gephi/gephi-lite@1.0.2"
ARG SOURCE_REPO="https://github.com/gephi/gephi-lite.git"

WORKDIR /clone

RUN set -x && \
    export SOURCE_COMMIT_ID="$(echo ${COMMIT_TAG} | cut -d'+' -f2)" && \
    export SOURCE_TAG_BRANCH="$(echo ${COMMIT_TAG} | cut -d'+' -f1)" && \
    git clone --config advice.detachedHead=false --depth 1 --branch "${SOURCE_TAG_BRANCH}" "${SOURCE_REPO}" "/clone" && \
    git reset --hard "${SOURCE_COMMIT_ID}" && \
    git log

# ===
# https://hub.docker.com/_/node/tags
FROM docker.io/node:lts AS build

WORKDIR /gephi-lite
COPY --from=clone /clone/ /gephi-lite/
RUN npm install
RUN BASE_URL=/gephi-lite/ npm run build

# ===
# https://hub.docker.com/_/node/tags
FROM nginx:latest AS production

COPY --from=build /gephi-lite/packages/gephi-lite/build/ /var/www/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

# OCI Labels
LABEL org.opencontainers.image.title="Docker Gephi Lite (/gephi-lite path)"
LABEL org.opencontainers.image.authors="Nicholas de Jong <ndejong@psaintelligence.ai>"
LABEL org.opencontainers.image.source="https://github.com/psaintelligence/docker-gephi-lite-path"

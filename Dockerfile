#
# Dockerfile for reader-webview
#

FROM alpine as source
COPY --from=hectorqin/remote-webview /app /app

WORKDIR /app
RUN set -ex \
    && rm -rf .git* .dockerignore Dockerfile package-lock.json node_modules \
    && cat package.json | grep -e name -e version | sed -e 's/^[[:space:]]\+//g;s/"//g;s/,//g' \
    && ls -al

FROM ubuntu:jammy
COPY --from=source /app /app

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_SKIP_BROWSER_GC=1

WORKDIR /app
RUN set -ex \
    && apt-get update && apt-get install -y \
       curl wget gpg \
    && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get remove -y curl wget gpg \
    && npm install \
    && npx playwright install --with-deps webkit \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8050

CMD ["node","index.js"]

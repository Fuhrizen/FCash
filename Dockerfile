FROM debian:bookworm-slim

ARG HEMTT_VERSION=1.21.0
ARG HEMTT_SHA256=3ace226eac57bf80203ee40b28a67320d4abecba24e0ddb8c5ed1dcfeb1f46f3

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL "https://github.com/BrettMayson/HEMTT/releases/download/v${HEMTT_VERSION}/linux-x64.zip" -o /tmp/hemtt.zip \
    && echo "${HEMTT_SHA256}  /tmp/hemtt.zip" | sha256sum -c - \
    && mkdir -p /tmp/hemtt \
    && unzip -q /tmp/hemtt.zip -d /tmp/hemtt \
    && HEMTT_BIN="$(find /tmp/hemtt -type f -name hemtt -print -quit)" \
    && test -n "${HEMTT_BIN}" \
    && install -m 0755 "${HEMTT_BIN}" /usr/local/bin/hemtt \
    && rm -rf /tmp/hemtt /tmp/hemtt.zip

WORKDIR /workspace
COPY . /workspace

RUN test -f /workspace/.hemtt/project.toml

ENTRYPOINT ["/workspace/docker/fcash-build.sh"]

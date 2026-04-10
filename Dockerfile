FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu24.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential curl git pkg-config unzip cmake \
    libwebkit2gtk-4.1-dev \
    libssl-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libjavascriptcoregtk-4.1-dev \
    libsoup-3.0-dev \
    libglib2.0-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libgdk-pixbuf-2.0-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    clang \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:$PATH"

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

WORKDIR /app

COPY . .

RUN bun install
RUN bun run build

FROM ubuntu:24.04 AS runtime-cpu

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 \
    libayatana-appindicator3-1 \
    librsvg2-2 \
    libssl3 \
    ca-certificates \
    libfontconfig1 \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    xvfb \
    x11-utils \
    libglib2.0-0 \
    libcairo2 \
    libpango-1.0-0 \
    libgdk-pixbuf-2.0-0 \
    libjavascriptcoregtk-4.1-0 \
    libsoup-3.0-0 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m koharu
USER koharu
WORKDIR /home/koharu

COPY --from=builder --chown=koharu:koharu /app/target/release/koharu ./koharu

RUN mkdir -p /home/koharu/.local/share/koharu

EXPOSE 4000

COPY --chown=koharu:koharu entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

FROM nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04 AS runtime-cuda

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 \
    libayatana-appindicator3-1 \
    librsvg2-2 \
    libssl3 \
    ca-certificates \
    libfontconfig1 \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    xvfb \
    x11-utils \
    libglib2.0-0 \
    libcairo2 \
    libpango-1.0-0 \
    libgdk-pixbuf-2.0-0 \
    libjavascriptcoregtk-4.1-0 \
    libsoup-3.0-0 \
    libgomp1 \
    libvulkan1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m koharu
USER koharu
WORKDIR /home/koharu

COPY --from=builder --chown=koharu:koharu /app/target/release/koharu ./koharu
RUN mkdir -p /home/koharu/.local/share/koharu

EXPOSE 4000

COPY --chown=koharu:koharu entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
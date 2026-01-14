FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 必要なツールのインストール
RUN apt-get update && apt-get install -y \
    build-essential cmake lcov python3 python3-pip curl git rsync \
    && rm -rf /var/lib/apt/lists/*

# uv のインストール
# COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /app

# end


# syntax=docker/dockerfile:experimental

# First stage: Run venv setup 
FROM ghcr.io/astral-sh/uv:0.7.2-python3.13-alpine AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Disable Python downloads, because we want to use the system interpreter
# across both images. If using a managed Python version, it needs to be
# copied from the build image into the final image; see `standalone.Dockerfile`
# for an example.
ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


COPY docs docs

ENV PATH="/app/.venv/bin:$PATH"

RUN mkdocs build

FROM busybox:1.37 AS final

RUN adduser -D static
USER static
WORKDIR /home/static

COPY --from=builder --chown=static /app/site/ .

CMD ["busybox", "httpd", "-f", "-v", "-p", "3000"]

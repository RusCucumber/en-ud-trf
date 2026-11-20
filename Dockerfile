# change base image as needed
FROM python:3.11-slim-trixie
COPY --from=ghcr.io/astral-sh/uv:0.9.18 /uv /uvx /bin/

WORKDIR /app
COPY uv.lock .
COPY pyproject.toml .
COPY .python-version .
COPY README.md .

COPY src ./src
COPY tests ./tests

RUN uv sync --no-dev

ENV PYTHONPATH=/app
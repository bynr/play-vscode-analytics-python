# Base
FROM python:3.8-slim-buster AS base
WORKDIR /workspace
ENV PYTHONPATH /workspace
COPY pip.conf /etc/
COPY requirements.txt .
RUN pip install -r requirements.txt

# Production image
FROM base AS production
COPY . .
ENTRYPOINT ["python", "./play/main.py"]

# Test base
FROM base AS testbase
COPY requirements-test.txt .
RUN pip install -r requirements-test.txt

# Test image
FROM testbase AS test
COPY . .
ENTRYPOINT ["pytest", "./play/tests"]

# VS Code Dev Container image
FROM testbase AS devcontainer
RUN apt-get -qq update \
        && apt-get -qq install --no-install-recommends --no-install-suggests -y \
        bash \
        curl \
        jq \
        ca-certificates \
        zip \
        build-essential \
        git \
        gnupg \
        openssh-client

RUN curl -L -o shfmt \
        https://github.com/mvdan/sh/releases/download/v3.1.2/shfmt_v3.1.2_linux_amd64 \
        && chmod 0700 shfmt \
        && mv shfmt /usr/bin

COPY requirements-dev.txt .
RUN pip install -r requirements-dev.txt

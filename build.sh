#!/bin/bash

IMAGE=mereith/tcp-cal
VERSION=v0.1.0

echo "Building Docker image: ${IMAGE}:${VERSION}"

docker buildx build \
  --platform linux/amd64 \
  --tag ${IMAGE}:${VERSION} \
  --tag ${IMAGE}:latest \
  --push \
  .
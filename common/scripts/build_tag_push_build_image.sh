#! /bin/bash

##
# Build, tag, and push a docker image
#
# Usage:
#
#    $ ./build_tag_push_build_image.sh <docker-repo> <dockerfile-path> <docker-build-context-dir>
##

# Helpful tips on writing build scripts:
# https://buildkite.com/docs/pipelines/writing-build-scripts
set -euxo pipefail

##
# Gather user input/environment variables
##
DOCKER_REPO="$1"
DOCKERFILE_PATH="$2"
DOCKER_BUILD_CONTEXT_DIR="$3"
BUILDKITE_COMMIT=${BUILDKITE_COMMIT:-unknown_git_commit}

build_image_tag=$(buildkite-agent meta-data get "build_image_tag")

docker build --rm --force-rm \
  --build-arg COMMIT_SHA="${BUILDKITE_COMMIT}" \
  --build-arg BUILD_IMAGE_TAG="${build_image_tag}" \
  -t "${DOCKER_REPO}:${build_image_tag}" \
  -f "$DOCKERFILE_PATH" \
  "$DOCKER_BUILD_CONTEXT_DIR"

docker push "${DOCKER_REPO}:${build_image_tag}"

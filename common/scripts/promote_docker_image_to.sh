#! /bin/bash

##
# Gets the build image tag from buildkite metadata and promotes the image by
# retagging it with the provided tag.
##

# Helpful tips on writing build scripts:
# https://buildkite.com/docs/pipelines/writing-build-scripts
set -euxo pipefail

##
# Local variables
##
docker_image_name="$1"

##
# Required arguments
##
new_image_tag="$2"

build_image_tag=$(buildkite-agent meta-data get "build_image_tag")

# If this is being deployed for a different build variant (e.g. ekiden-hw) then
# the tag will add a suffix.
tag_suffix=${BUILD_VARIANT:+-$BUILD_VARIANT}

##
# Add the provided tag to the build image
##

docker pull "${docker_image_name}:${build_image_tag}${tag_suffix}"

docker tag \
  "${docker_image_name}:${build_image_tag}${tag_suffix}" \
  "${docker_image_name}:${new_image_tag}"

docker push "${docker_image_name}:${new_image_tag}"

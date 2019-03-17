#! /bin/bash
##
# Determines the correct docker tag to use based on the current git branch/tag.
# This tag is saved as metadata in the buildkite pipeline so that it can be
# retrieved in steps that want to pull the same exact image from Docker Hub.
# 
# This tag value must be calculated once and saved as metadata in buildkite
# because it is possible that the tag name includes a timestamp, which could
# obviously change if the tag were recalculated.
##

# Helpful tips on writing build scripts:
# https://buildkite.com/docs/pipelines/writing-build-scripts
set -euxo pipefail

docker_tag=$(.buildkite/common/scripts/get_docker_tag.sh \
              "${BUILDKITE_BRANCH:-unknown_git_branch}"  \
              "${BUILDKITE_COMMIT:-unknown_git_commit}"  \
              "${BUILDKITE_TAG}"
            )

buildkite-agent meta-data set "build_image_tag" "${docker_tag}"

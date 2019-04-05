#!/bin/bash

##
# Script to lint generated yaml for pipelines.
#
# NOTE: Due to issues with using Buildkite's Docker plugin, the script uses
# Docker's CLI directly.
##

set -euxo pipefail

temp_test_file=.yamllint.temp.yml

clean () {
    if [ -f "$temp_test_file" ]; then
        rm "$temp_test_file"
    fi
}
# Always clean if the temp file exists
trap clean EXIT

yamllint () {
    docker run --rm -i -v "$(pwd):/workdir" giantswarm/yamllint:latest "$@"
}

yamllint_generated_pipeline () {
    pipeline_path="common/pipelines/$1.sh"

    shift 1

    "$pipeline_path" --output-only "$@" > "$temp_test_file"

    yamllint -c ./yamllint.yml "$temp_test_file"

    # TODO Upload generated pipelines to buildkite in a way that is safe
}

# Test generic checks
yamllint_generated_pipeline generic_checks

# Test generic_docker_build_publish_and_deploy
yamllint_generated_pipeline generic_docker_build_publish_and_deploy docker_repo name dockerfile_path

# Test generic_docker_build_publish_and_deploy with the --trigger-deploy flag
yamllint_generated_pipeline generic_docker_build_publish_and_deploy --trigger-deploy docker_repo name dockerfile_path

# Test generic_docker_build_publish_and_deploy with the --trigger-deploy flag
yamllint_generated_pipeline generic_docker_build_publish_and_deploy --docker-build-arg SOME=test docker_repo name dockerfile_path

# Test deployment_trigger
yamllint_generated_pipeline deployment_trigger name deployment_env cloud_provider region chart_name

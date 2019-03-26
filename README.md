# Oasis Buildkite Tools

These are a set of common buildkite tools that can be used in any given
repository. These tools are invoked by referencing this repository as a
plugin into buildkite. Once invoked, the plugin will copy everything in the
`common/` directory of this repository into `.buildkite/common`. It is
expected that no `.buildkite/common` directory exists in any given
repository and this plugin will fail to load if that is not true.
Additionally, if the `pipelines/generic_checks.sh` script is used to generate
a set of generic checks for a given repository, CI will ensure that this is
always true.

## Usage Examples

### Using one of the common scripts

In the `./.buildkite/pipeline.yml`:

```
steps:
  - label: Run a common script to setup gitconfig
    command: .buildkite/common/scripts/setup_gitconfig.sh
    plugins:
      # v0.1.1 immediately below is the git ref of the plugin. You can also use
      # branches or commit SHA
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~

      # Example: Using a branch
      # Note: buildkite caches plugin downloads so this is not recommended
      # - oasislabs/private-oasis-buildkite-tools#some/feature/branch: ~

      # Example: Using a commit
      # - oasislabs/private-oasis-buildkite-tools#ece9352e4da33e70ed6cf4e72cde22058d35d638: ~
```

### Using a generic pipeline

In the `./.buildkite/pipeline.yaml`:

```
steps:
  - label: Generate a set of generic checks
    command: .buildkite/common/pipelines/generic_checks.sh
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

This will then generate the following steps:

1. Ensure that no `.buildkite/common` directory has been checked into the repository
2. Ensure that all git commits are linted using [gitlint](https://github.com/jorisroovers/gitlint)
3. Ensure that all shell scripts are linted using [shellcheck](https://github.com/koalaman/shellcheck)

## Available Common Scripts

_Note: The examples show a plugin version of v0.1.1. You will want to use the
latest version instead._

### argbash_checks.sh

For any projects that use argbash, this allows you to check if there are any
ungenerated changes in directories with files that use argbash.

#### Example Pipeline Usage

```
steps:
  - label: Run argbash check on directory1 and directory2
    command: .buildkite/common/scripts/argbash_checks.sh dir1/ dir2/
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

### build_tag_push_build_image.sh

Build, tag, and push a docker image. This script assumes that a
`build_image_tag` buildkite meta-data value has been set.

#### Example Pipeline Usage

```
steps:
  - label: Build tag and push a docker image
    command: .buildkite/common/scripts/build_tag_push_build_image.sh dockerrepo/name path/to/dockerfile
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

### get_docker_tag.sh

Utility script to determine the value to use for a docker tag. You should
rarely need to call this directly. It is used by
[set_docker_tag_meta_data.sh](#set_docker_tag_meta_datash)

### lint_git.sh

Runs git linting. Currently this is dependent on the
`oasislabs/testing:0.2.0` docker image

#### Example Pipeline Usage

```
steps:
  - label: Lint Git Commits
    command: .buildkite/common/scripts/lint_git.sh
    plugins:
      - docker#v2.0.0:
          image: "oasislabs/testing:0.2.0"
          always_pull: true
          workdir: /workdir
          volumes:
            - .:/workdir

      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

### promote_docker_image_to.sh

Promotes a `build_image_tag` to a different tag. `build_image_tag` is assumed
to be set in the buildkite meta-data. For our purposes, the `build_image_tag`
is considered an immutable tag. Only a single `docker push` should ever be
made to that tag. This script allows us to promote the `build_image_tag` to
one of the mutable tags that we use. The mutable tags we use are `staging`
and `latest`. Setting these tags allows us to track which images _should_ be
deployed to staging (using the `staging` tag) or production (using the
`latest` tag).

#### Example Pipeline Usage

```
steps:
  - label: ":rocket: Publish docker container to production (latest)"
    branches: master
    command:
      - .buildkite/common/scripts/promote_docker_image_to.sh dockerrepo/name latest
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

### set_docker_tag_meta_data.sh

Sets the `build_image_tag` meta-data value for a given pipeline. The value is
derived from either the tag or commit hash. This script should be used
instead of something custom within your repository.

#### Example Pipeline Usage

```
steps:
  - label: Get docker tag and save it as metadata for use later
    branches: master
    command: .buildkite/common/scripts/set_docker_tag_meta_data.sh
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

### setup_gitconfig.sh

Sets the `~/.gitconfig` for a container so that anything using
`https://github.com` will use `git@github.com`. This is used mostly for cargo
builds, but may be useful for other things. Often, this script won't be used
on it's own in a single step.

#### Example Pipeline Usage

```
steps:
  - label: Run some command
    command:
      - .buildkite/common/scripts/setup_gitconfig.sh
      - scripts/some-command.sh
    plugins:
      - docker#v2.0.0:
          image: ubuntu:bionic
          workdir: /workdir
          volumes:
            - .:/workdir
```

## Available Common Pipelines

_Note: The examples show a plugin version of v0.1.1. You will want to use the
latest version instead._

### deployment_trigger.sh

Generates a deployment trigger to the [generic deployment
pipeline](https://buildkite.com/oasislabs/private-ops-deploy-any-chart/) in
private-ops.

#### Example Pipeline Usage

```
steps:
  - label: Generate deployment trigger step for a deployment to staging
    branches: master
    command: >
      .buildkite/common/pipelines/deployment_trigger.sh
      --deployment-branches "master"
      project-name
      staging
      aws
      us-west-2
      project-chart-name
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

### generic_checks.sh

Generates a set of generic checks that does the following:

1. Ensure that no `.buildkite/common` directory has been checked into the repository
2. Ensure that all git commits are linted using [gitlint](https://github.com/jorisroovers/gitlint)
3. Ensure that all shell scripts are linted using [shellcheck](https://github.com/koalaman/shellcheck)

#### Example Pipeline Usage

```
steps:
  - label: Generate a set of generic checks
    command: .buildkite/common/pipelines/generic_checks.sh
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

### generic_docker_build_publish_and_deploy.sh

Generates a staging to production docker publishing and, optionally, deployment pipeline. The following steps are generated:

1. Derive docker tag (using [set_docker_tag_meta_data.sh](#set_docker_tag_meta_datash))
2. Build, tag, push a docker image for this build
3. Promote the docker image to the `staging` docker tag
4. If the `--trigger-deploy` flag is set, deploy the image to staging
   using the [generic deployment pipeline](https://buildkite.com/oasislabs/private-ops-deploy-any-chart/)
5. Hold for a production promotion
6. Promote the docker image to the `latest` docker tag
7. If the `--trigger-deploy` flag is set, deploy the image to production
   using the [generic deployment pipeline](https://buildkite.com/oasislabs/private-ops-deploy-any-chart/)

This generic pipeline has many options. You can check out this repository and
run the script's help to see what the options are like so:

```
$ common/pipelines/generic_docker_build_publish_and_deploy.sh --help
```

#### Example Pipeline Usage


##### Create a docker build and publish pipeline

```
steps:
  - label: Generate docker build and publish pipeline
    command: >
      .buildkite/common/pipelines/generic_docker_build_publish_and_deploy.sh
      oasislabs/some-docker-repo
      some-chart-name
      docker/Dockerfile
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

##### Create a docker build, publish, and deployment pipeline

```
steps:
  - label: Generate docker build and publish pipeline
    command: >
      .buildkite/common/pipelines/generic_docker_build_publish_and_deploy.sh
      --trigger-deploy
      oasislabs/some-docker-repo
      some-chart-name
      docker/Dockerfile
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

##### Create a docker build, publish, and deployment pipeline that deploys to ops-staging and ops-production

```
steps:
  - label: Generate docker build and publish pipeline
    command: >
      .buildkite/common/pipelines/generic_docker_build_publish_and_deploy.sh
      --trigger-deploy
      --staging-environment ops-staging
      --production-environment ops-production
      oasislabs/some-docker-repo
      some-chart-name
      docker/Dockerfile
    plugins:
      - oasislabs/private-oasis-buildkite-tools#v0.1.1: ~
```

#!/bin/bash

##
# Generates a generic staging->production pipeline for a docker build and
# optionally a deployment. At this time, this can only be used with projects
# that define all of the build steps in a Dockerfile. Eventually this script
# will support custom build steps.
#
# To see usage instructions
#
#     $ ./generic_docker_build_publish_and_deploy.sh --help
#
# Example: Create a build pipeline
#
#     $ ./generic_docker_build_publish_and_deploy.sh oasislabs/some-docker-repo some-chart-name docker/Dockerfile
#
# Example: Create a build and deployment pipeline
#
#     $ ./generic_docker_build_publish_and_deploy.sh --trigger-deploy oasislabs/some-docker-repo some-chart-name docker/Dockerfile
#
# Example: Create a build and deployment pipeline that targets ops-staging and ops-production
#
#     $ ./generic_docker_build_publish_and_deploy.sh --staging-environment ops-staging --production-environment ops-production \
#                           --trigger-deploy oasislabs/some-docker-repo some-chart-name docker/Dockerfile
#
# This script's options were generated using argbash
##

# ARG_OPTIONAL_SINGLE([staging-environment],[],[Project's target staging environment],[staging])
# ARG_OPTIONAL_SINGLE([staging-region],[],[Project's target staging environment. Defaults to region])
# ARG_OPTIONAL_SINGLE([staging-cloud-provider],[],[Project's target staging cloud provider. Overrides cloud-provider])
# ARG_OPTIONAL_SINGLE([staging-chart-name],[],[Project's staging chart name. Overrides chart-name])
# ARG_OPTIONAL_SINGLE([production-environment],[],[Project's target production environment],[production])
# ARG_OPTIONAL_SINGLE([production-region],[],[Project's target production region. Overrides region])
# ARG_OPTIONAL_SINGLE([production-cloud-provider],[],[Project's target production cloud-provider. Overrides cloud-provider])
# ARG_OPTIONAL_SINGLE([production-chart-name],[],[Project's production chart name. Overrides chart-name])
# ARG_OPTIONAL_SINGLE([cloud-provider],[],[Project's deployment region],[aws])
# ARG_OPTIONAL_SINGLE([region],[],[Project's deployment region],[us-west-2])
# ARG_OPTIONAL_SINGLE([chart-name],[],[Project's chart name if it's different than the name of the project])
# ARG_OPTIONAL_SINGLE([tools-plugin-version],[],[The private-oasis-buildkite-tools plugin version to use for the generated steps. Defaults to using the PLUGIN_VERSION file in private-oasis-buildkite-tools])
# ARG_OPTIONAL_SINGLE([deployment-branches],[],[Branches to deploy],[master])
# ARG_OPTIONAL_SINGLE([private-ops-deployment-branch],[],[Branch of private-ops to use for generic deploys],[master])
# ARG_OPTIONAL_SINGLE([docker-build-context-dir],[],[Where to set the docker build path. Defaults to the root of the repository],[.])
# ARG_OPTIONAL_BOOLEAN([trigger-deploy],[],[Trigger deploys])
# ARG_POSITIONAL_SINGLE([docker-repo],[Docker repo name])
# ARG_POSITIONAL_SINGLE([name],[name of the project])
# ARG_POSITIONAL_SINGLE([dockerfile-path],[path to dockerfile])
# ARG_OPTIONAL_BOOLEAN([output-only],[],[Do not call buildkite. Used for testing])
# ARG_HELP([Generates a generic deployment pipeline for a docker build])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}


begins_with_short_option()
{
	local first_option all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_staging_environment="staging"
_arg_staging_region=
_arg_staging_cloud_provider=
_arg_staging_chart_name=
_arg_production_environment="production"
_arg_production_region=
_arg_production_cloud_provider=
_arg_production_chart_name=
_arg_cloud_provider="aws"
_arg_region="us-west-2"
_arg_chart_name=
_arg_tools_plugin_version=
_arg_deployment_branches="master"
_arg_private_ops_deployment_branch="master"
_arg_docker_build_context_dir="."
_arg_trigger_deploy="off"
_arg_output_only="off"


print_help()
{
	printf '%s\n' "Generates a generic deployment pipeline for a docker build"
	printf 'Usage: %s [--staging-environment <arg>] [--staging-region <arg>] [--staging-cloud-provider <arg>] [--staging-chart-name <arg>] [--production-environment <arg>] [--production-region <arg>] [--production-cloud-provider <arg>] [--production-chart-name <arg>] [--cloud-provider <arg>] [--region <arg>] [--chart-name <arg>] [--tools-plugin-version <arg>] [--deployment-branches <arg>] [--private-ops-deployment-branch <arg>] [--docker-build-context-dir <arg>] [--(no-)trigger-deploy] [--(no-)output-only] [-h|--help] <docker-repo> <name> <dockerfile-path>\n' "$0"
	printf '\t%s\n' "<docker-repo>: Docker repo name"
	printf '\t%s\n' "<name>: name of the project"
	printf '\t%s\n' "<dockerfile-path>: path to dockerfile"
	printf '\t%s\n' "--staging-environment: Project's target staging environment (default: 'staging')"
	printf '\t%s\n' "--staging-region: Project's target staging environment. Defaults to region (no default)"
	printf '\t%s\n' "--staging-cloud-provider: Project's target staging cloud provider. Overrides cloud-provider (no default)"
	printf '\t%s\n' "--staging-chart-name: Project's staging chart name. Overrides chart-name (no default)"
	printf '\t%s\n' "--production-environment: Project's target production environment (default: 'production')"
	printf '\t%s\n' "--production-region: Project's target production region. Overrides region (no default)"
	printf '\t%s\n' "--production-cloud-provider: Project's target production cloud-provider. Overrides cloud-provider (no default)"
	printf '\t%s\n' "--production-chart-name: Project's production chart name. Overrides chart-name (no default)"
	printf '\t%s\n' "--cloud-provider: Project's deployment region (default: 'aws')"
	printf '\t%s\n' "--region: Project's deployment region (default: 'us-west-2')"
	printf '\t%s\n' "--chart-name: Project's chart name if it's different than the name of the project (no default)"
	printf '\t%s\n' "--tools-plugin-version: The private-oasis-buildkite-tools plugin version to use for the generated steps. Defaults to using the PLUGIN_VERSION file in private-oasis-buildkite-tools (no default)"
	printf '\t%s\n' "--deployment-branches: Branches to deploy (default: 'master')"
	printf '\t%s\n' "--private-ops-deployment-branch: Branch of private-ops to use for generic deploys (default: 'master')"
	printf '\t%s\n' "--docker-build-context-dir: Where to set the docker build path. Defaults to the root of the repository (default: '.')"
	printf '\t%s\n' "--trigger-deploy, --no-trigger-deploy: Trigger deploys (off by default)"
	printf '\t%s\n' "--output-only, --no-output-only: Do not call buildkite. Used for testing (off by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--staging-environment)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_staging_environment="$2"
				shift
				;;
			--staging-environment=*)
				_arg_staging_environment="${_key##--staging-environment=}"
				;;
			--staging-region)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_staging_region="$2"
				shift
				;;
			--staging-region=*)
				_arg_staging_region="${_key##--staging-region=}"
				;;
			--staging-cloud-provider)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_staging_cloud_provider="$2"
				shift
				;;
			--staging-cloud-provider=*)
				_arg_staging_cloud_provider="${_key##--staging-cloud-provider=}"
				;;
			--staging-chart-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_staging_chart_name="$2"
				shift
				;;
			--staging-chart-name=*)
				_arg_staging_chart_name="${_key##--staging-chart-name=}"
				;;
			--production-environment)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_production_environment="$2"
				shift
				;;
			--production-environment=*)
				_arg_production_environment="${_key##--production-environment=}"
				;;
			--production-region)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_production_region="$2"
				shift
				;;
			--production-region=*)
				_arg_production_region="${_key##--production-region=}"
				;;
			--production-cloud-provider)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_production_cloud_provider="$2"
				shift
				;;
			--production-cloud-provider=*)
				_arg_production_cloud_provider="${_key##--production-cloud-provider=}"
				;;
			--production-chart-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_production_chart_name="$2"
				shift
				;;
			--production-chart-name=*)
				_arg_production_chart_name="${_key##--production-chart-name=}"
				;;
			--cloud-provider)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_cloud_provider="$2"
				shift
				;;
			--cloud-provider=*)
				_arg_cloud_provider="${_key##--cloud-provider=}"
				;;
			--region)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_region="$2"
				shift
				;;
			--region=*)
				_arg_region="${_key##--region=}"
				;;
			--chart-name)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_chart_name="$2"
				shift
				;;
			--chart-name=*)
				_arg_chart_name="${_key##--chart-name=}"
				;;
			--tools-plugin-version)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_tools_plugin_version="$2"
				shift
				;;
			--tools-plugin-version=*)
				_arg_tools_plugin_version="${_key##--tools-plugin-version=}"
				;;
			--deployment-branches)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_deployment_branches="$2"
				shift
				;;
			--deployment-branches=*)
				_arg_deployment_branches="${_key##--deployment-branches=}"
				;;
			--private-ops-deployment-branch)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_private_ops_deployment_branch="$2"
				shift
				;;
			--private-ops-deployment-branch=*)
				_arg_private_ops_deployment_branch="${_key##--private-ops-deployment-branch=}"
				;;
			--docker-build-context-dir)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_docker_build_context_dir="$2"
				shift
				;;
			--docker-build-context-dir=*)
				_arg_docker_build_context_dir="${_key##--docker-build-context-dir=}"
				;;
			--no-trigger-deploy|--trigger-deploy)
				_arg_trigger_deploy="on"
				test "${1:0:5}" = "--no-" && _arg_trigger_deploy="off"
				;;
			--no-output-only|--output-only)
				_arg_output_only="on"
				test "${1:0:5}" = "--no-" && _arg_output_only="off"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'docker-repo', 'name' and 'dockerfile-path'"
	test "${_positionals_count}" -ge 3 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 3 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 3 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 3 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_docker_repo _arg_name _arg_dockerfile_path "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash
set -euxo pipefail

# shellcheck disable=SC2154
DOCKER_REPO="$_arg_docker_repo"

# shellcheck disable=SC2154
NAME="$_arg_name"

# shellcheck disable=SC2154
DOCKERFILE_PATH="$_arg_dockerfile_path"

DOCKER_BUILD_CONTEXT_DIR="$_arg_docker_build_context_dir"

pipeline_file="$(mktemp)"

if [[ $_arg_output_only = on ]]; then
  tools_plugin_version="fake-tools_plugin_version"
else
  tools_plugin_version="${_arg_tools_plugin_version:-$(cat .buildkite/common/VERSION)}"
fi


REGION="$_arg_region"
CLOUD_PROVIDER="$_arg_cloud_provider"

# Set chart name to the project name if chart name does not exist
CHART_NAME="$_arg_chart_name"
if [[ -z $CHART_NAME ]]; then
  CHART_NAME="$NAME"
fi

# Handle staging environment value overrides
STAGING_ENVIRONMENT="$_arg_staging_environment"

STAGING_CLOUD_PROVIDER="$_arg_staging_cloud_provider"
if [[ -z $STAGING_CLOUD_PROVIDER ]]; then
  STAGING_CLOUD_PROVIDER="$CLOUD_PROVIDER"
fi

STAGING_REGION="$_arg_staging_region"
if [[ -z $STAGING_REGION ]]; then
  STAGING_REGION="$REGION"
fi

STAGING_CHART_NAME="$_arg_staging_chart_name"
if [[ -z $STAGING_CHART_NAME ]]; then
  STAGING_CHART_NAME="$CHART_NAME"
fi

# Handle production environment value overrides
PRODUCTION_ENVIRONMENT="$_arg_production_environment"

PRODUCTION_CLOUD_PROVIDER="$_arg_production_cloud_provider"
if [[ -z $PRODUCTION_CLOUD_PROVIDER ]]; then
  PRODUCTION_CLOUD_PROVIDER="$CLOUD_PROVIDER"
fi

PRODUCTION_REGION="$_arg_production_region"
if [[ -z $PRODUCTION_REGION ]]; then
  PRODUCTION_REGION="$REGION"
fi

PRODUCTION_CHART_NAME="$_arg_production_chart_name"
if [[ -z $PRODUCTION_CHART_NAME ]]; then
  PRODUCTION_CHART_NAME="$CHART_NAME"
fi

cat << EOF > "$pipeline_file"
steps:
  - label: Tag, build, and publish $NAME docker container for staging
    branches: "$_arg_deployment_branches"
    command:
      - .buildkite/common/scripts/set_docker_tag_meta_data.sh
      - .buildkite/common/scripts/build_tag_push_image.sh $DOCKER_REPO $DOCKERFILE_PATH $DOCKER_BUILD_CONTEXT_DIR
      - .buildkite/common/scripts/promote_docker_image_to.sh $DOCKER_REPO staging
    plugins:
      - oasislabs/private-oasis-buildkite-tools#${tools_plugin_version}: ~
EOF


# Trigger a staging deployment if this is set to trigger deployments
if [[ $_arg_trigger_deploy = on ]]; then

cat << EOF >> "$pipeline_file"
  - wait

  - label: Generate deployment trigger step for a deployment to $STAGING_ENVIRONMENT
    branches: "$_arg_deployment_branches"
    command: >
      .buildkite/common/pipelines/deployment_trigger.sh
      --private-ops-deployment-branch $_arg_private_ops_deployment_branch
      --deployment-branches "$_arg_deployment_branches"
      $NAME
      $STAGING_ENVIRONMENT
      $STAGING_CLOUD_PROVIDER
      $STAGING_REGION
      $STAGING_CHART_NAME
    plugins:
      - oasislabs/private-oasis-buildkite-tools#${tools_plugin_version}: ~
EOF

fi

cat << EOF >> "$pipeline_file"
  - wait

  - block: Human approval required to promote $NAME to production
    branches: "$_arg_deployment_branches"
    prompt: |
      Clicking "OK" below will unblock this step and
      permit the deployment to production.
      NOTE - It is possible to click the "OK" button to
      unblock this step even if the staging deploy is
      still working. Be sure you tested on staging before
      clicking this button.
      - The Friendly Oasis Labs Robo

  - label: ":rocket: Publish $NAME docker container to production"
    branches: "$_arg_deployment_branches"
    command:
      - .buildkite/common/scripts/promote_docker_image_to.sh $DOCKER_REPO latest
    plugins:
      - oasislabs/private-oasis-buildkite-tools#${tools_plugin_version}: ~
EOF

# Trigger a production deployment if this is set to trigger deployments
if [[ $_arg_trigger_deploy = on ]]; then

cat << EOF >> "$pipeline_file"
  - wait

  - label: Generate deployment trigger step for a deployment to $PRODUCTION_ENVIRONMENT
    branches: "$_arg_deployment_branches"
    command: >
      .buildkite/common/pipelines/deployment_trigger.sh
      --private-ops-deployment-branch $_arg_private_ops_deployment_branch
      --deployment-branches "$_arg_deployment_branches"
      $NAME
      $PRODUCTION_ENVIRONMENT
      $PRODUCTION_CLOUD_PROVIDER
      $PRODUCTION_REGION
      $PRODUCTION_CHART_NAME
    plugins:
      - oasislabs/private-oasis-buildkite-tools#${tools_plugin_version}: ~
EOF

fi

if [[ $_arg_output_only = on ]]; then
  cat "$pipeline_file"
else
  buildkite-agent pipeline upload "$pipeline_file"
fi
rm -rf "$pipeline_file"

# ] <-- needed because of Argbash

#!/bin/bash

##
# Generates a generic pipeline for the following checks:
#
#  * Lint Git
#  * Lint Scripts
#
# Usage:
#
#     $ ./generic_checks.sh
##

# ARG_OPTIONAL_SINGLE([tools-plugin-version],[],[The private-oasis-buildkite-tools plugin version to use for the generated steps. Defaults to using the PLUGIN_VERSION file in private-oasis-buildkite-tools])
# ARG_OPTIONAL_BOOLEAN([output-only],[],[Do not call buildkite. Used for testing])
# ARG_HELP([Generates a set of generic checks for any repository])
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

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_tools_plugin_version=
_arg_output_only="off"


print_help()
{
	printf '%s\n' "Generates a set of generic checks for any repository"
	printf 'Usage: %s [--tools-plugin-version <arg>] [--(no-)output-only] [-h|--help]\n' "$0"
	printf '\t%s\n' "--tools-plugin-version: The private-oasis-buildkite-tools plugin version to use for the generated steps. Defaults to using the PLUGIN_VERSION file in private-oasis-buildkite-tools (no default)"
	printf '\t%s\n' "--output-only, --no-output-only: Do not call buildkite. Used for testing (off by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--tools-plugin-version)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_tools_plugin_version="$2"
				shift
				;;
			--tools-plugin-version=*)
				_arg_tools_plugin_version="${_key##--tools-plugin-version=}"
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
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

set -euxo pipefail

# Setup a temporary directory
pipeline_file="$(mktemp)"

if [[ $_arg_output_only = on ]]; then
  tools_plugin_version="fake-tools_plugin_version"
else
  tools_plugin_version="${_arg_tools_plugin_version:-$(cat .buildkite/common/VERSION)}"
fi

cat << EOF > "$pipeline_file"
steps:
  - label: "Check that no .buildkite/common directory has been checked in"
    command:
      # Ensure that no .buildkite/common directory exists by checking if there
      # are any number of files checked into git for that directory. This will
      # fail if that number is anything but 0
      - '[ "\$\$(git ls-files .buildkite/common | wc -l)" -eq 0 ]'

  - label: "Lint Git Commits"
    command: .buildkite/common/scripts/lint_git.sh
    plugins:
      - docker#v2.0.0:
          image: "oasislabs/testing:0.2.0"
          always_pull: true
          workdir: /workdir
          volumes:
            - .:/workdir

      - oasislabs/private-oasis-buildkite-tools#${tools_plugin_version}: ~

  - label: "Lint scripts"
    command:
      - find . -type f -name '*.sh' -print0 | xargs -0 shellcheck --external-sources
    plugins:
      - docker#v2.0.0:
          image: "koalaman/shellcheck-alpine:v0.5.0"
          always_pull: false
          workdir: /workdir
          volumes:
            - .:/workdir

      - oasislabs/private-oasis-buildkite-tools#${tools_plugin_version}: ~
EOF

if [[ $_arg_output_only = on ]]; then
    cat "$pipeline_file"
else
    buildkite-agent pipeline upload "$pipeline_file"
fi
rm -rf "$pipeline_file"
# ] <-- needed because of Argbash
#!/bin/bash

##
# Runs argbash against the passed in directories and checks that no scripts
# have ungenerated argbash changes
#
# Usage:
#
#     ./argbash_check.sh dir1/ dir2/
#
##
set -euxo pipefail

BASE_DIR=$(pwd)

for directory in "$@"
do
    cd "${BASE_DIR}/${directory}"

    # Always ignore self as part of this check
    # shellcheck disable=SC2038
    find . -type f -name '*.sh' ! -path '*/argbash_check.sh' \
         -exec grep -l 'ARGBASH_GO' {} \; | \
         xargs -I {} docker run -i --rm -e PROGRAM=argbash -v "$(pwd):/work" \
         matejak/argbash:2.8.0-2 -o {} {}

done

git diff --exit-code

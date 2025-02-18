#!/bin/bash
home=$(pwd)
cd "$REPO_PATH" || exit 1
set -e
# shellcheck disable=SC2086
$BUILD_CMD $BUILD_ARGS "$home/$SRC_DIR" "./$OUT_DIR"
set +e
cd "$home" || exit 1

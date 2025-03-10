#!/bin/bash
home=$(pwd)
cd "$SRC_BRANCH" || exit
set -e
if [ -x "$EXPECT_SCRIPT" ]
then
    ./"$EXPECT_SCRIPT"
else
    # shellcheck disable=SC2086
    $BUILD_CMD $BUILD_ARGS "./$SRC_DIR" "../$OUT_BRANCH/$OUT_DIR"
fi
set +e
cd "$home" || exit

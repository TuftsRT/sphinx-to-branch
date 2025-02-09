#!/bin/bash
home=$(pwd)
cd $REPO_PATH
git pull --all
git checkout $BRANCH -- || git switch --orphan $BRANCH
if [ "$CLEAR" == "true" ]; then git rm -rfq *; fi
set -e
$BUILD_CMD $BUILD_ARGS "$home/$SRC_DIR" "./$OUT_DIR"
set +e
touch .nojekyll
git add -A
git commit -m "$MESSAGE"
git push -u origin $BRANCH
cd $home

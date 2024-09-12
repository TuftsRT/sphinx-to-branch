#!/bin/bash
home=$(pwd)
tmp=$(mktemp -d)
gh repo clone $REPOSITORY $tmp
cd $tmp
git checkout $BRANCH -- || git switch --orphan $BRANCH
if [ "$CLEAR" == "true" ]; then git rm -rfq *; fi
$BUILD_CMD $BUILD_ARGS ../$SRC_DIR ./$OUT_DIR
touch .nojekyll
git add -A
git commit -m "$MESSAGE"
git push -u origin $BRANCH
cd $home

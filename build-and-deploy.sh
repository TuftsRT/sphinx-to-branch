#!/bin/bash
gh repo clone $REPO destination
cd destination
git pull --all
git config user.name "$(git show -s --format='%an' HEAD)"
git config user.email "$(git show -s --format='%ae' HEAD)"
git checkout $BRANCH -- || git switch --orphan $BRANCH
if [ "$CLEAR" == "true" ]; then git rm -rfq *; fi
$BUILD_CMD $BUILD_ARGS ../$SRC_DIR ./$OUT_DIR
touch .nojekyll
git add -A
git commit -m "$MESSAGE"
git push -u origin $BRANCH

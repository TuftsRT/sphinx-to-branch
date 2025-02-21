#!/bin/bash
home=$(pwd)
cd "$REPO_PATH" || exit 1
if [ "$ADD_NOJEKYLL" == "true" ]
then
    touch .nojekyll
fi
git add -A
git commit -m "$MESSAGE"
git push -u origin "$BRANCH"
cd "$home" || exit 1

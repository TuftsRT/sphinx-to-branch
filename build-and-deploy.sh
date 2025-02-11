#!/bin/bash
home=$(pwd)
cd "$REPO_PATH"
git pull --all
git checkout "$BRANCH" -- || git switch --orphan "$BRANCH"
if [ "$CLEAR" == "true" ]
then
    git rm -rfq -- *
else
    while IFS="" read -r pattern
    do
        rm -rf -- "$pattern"
    done <<< "$(grep '\S' <<< "$RM_LIST")"
fi
set -e
$BUILD_CMD "$BUILD_ARGS" "$home/$SRC_DIR" "./$OUT_DIR"
set +e
if [ "$DRY_RUN" != "true" ]
then
    if [ "$ADD_NOJEKYLL" == "true" ]
    then
        touch .nojekyll
    fi
    git add -A
    git commit -m "$MESSAGE"
    git push -u origin "$BRANCH"
fi
cd "$home"

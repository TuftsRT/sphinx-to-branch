#!/bin/bash
home=$(pwd)
cd "$REPO_PATH" || exit 1
git pull --all
git checkout "$BRANCH" -- || git switch --orphan "$BRANCH"
if [ "$CLEAR" == "true" ]
then
    git rm -rfq -- *
    # shellcheck disable=SC2086
    while IFS="" read -r pattern
    do
        git checkout HEAD -- $pattern
    done <<< "$(grep '\S' <<< $KEEP_LIST)"
else
    # shellcheck disable=SC2086
    while IFS="" read -r pattern
    do
        rm -rf -- $pattern
    done <<< "$(grep '\S' <<< $RM_LIST)"
fi
cd "$home" || exit 1

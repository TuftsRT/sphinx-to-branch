#!/bin/bash
home=$(pwd)
cd "$REPO_PATH" || exit 1
git pull --all
git checkout "$BRANCH" -- || git switch --orphan "$BRANCH"
if [ "$CLEAR" == "true" ]
then
    git rm -rfq -- *
else
    while IFS="" read -r pattern
    do
        # shellcheck disable=SC2086
        rm -rf -- $pattern
    done <<< "$(grep '\S' <<< "$RM_LIST")"
fi
cd "$home" || exit 1

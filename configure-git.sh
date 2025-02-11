#!/bin/bash
if [ "$USE_BOT" == "true" ]; then
    git config --global user.name "github-actions[bot]"
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
else
    home=$(pwd)
    cd $REPO_PATH
    git config --global user.name "$(git show -s --format='%an' HEAD)"
    git config --global user.email "$(git show -s --format='%ae' HEAD)"
    cd $home
fi

#!/bin/bash
home=$(pwd)
cd $REPO_PATH
git config user.name "$(git show -s --format='%an' HEAD)"
git config user.email "$(git show -s --format='%ae' HEAD)"
cd $home

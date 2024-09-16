#!/bin/bash
home=$(pwd)
cd $REPO_PATH
git config --global user.name "$(git show -s --format='%an' HEAD)"
git config --global user.email "$(git show -s --format='%ae' HEAD)"
cd $home

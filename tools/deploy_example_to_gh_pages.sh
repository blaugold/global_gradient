#!/usr/bin/env bash

set -e

if [ -n "$(git status --porcelain)" ]; then
  echo 'Repository has to be clean.'
  exit 1
fi

git checkout -b deploy-gh-pages

cd ./example
flutter build web --release
mv ./build/web ./gh-pages

git add ./gh-pages
git commit -m 'deploy gh-pages'

cd ../

git push -d origin gh-pages
git subtree push --prefix example/gh-pages origin gh-pages

git checkout master
git branch -D deploy-gh-pages

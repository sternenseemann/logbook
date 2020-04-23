#!/bin/sh
set -e

REV=$(git rev-parse HEAD)

cd "$(dirname "$0")"
git stash
dune build @doc
git checkout gh-pages
rm -rf doc
cp -R _build/default/_doc/_html doc
git add doc
git commit -m "Update documentation for $REV"
git checkout master
git stash apply

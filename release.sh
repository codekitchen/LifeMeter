#!/bin/bash

# depends on:
# go get github.com/aktau/github-release

set -e

VERSION=$1
: ${VERSION:?"Need to specify a version e.g. 2.0.1"}

pushd LifeMeterHelperApp
xcodebuild
popd
xcodebuild
pushd build/Release
zip -r ../../LifeMeter.zip "Life Meter.app"
popd

tag="v$VERSION"
git tag $tag
git push origin $tag
git push origin master

github-release release \
  --user codekitchen \
  --repo LifeMeter \
  --tag $tag \
  --name "Release $tag"

github-release upload \
  --user codekitchen \
  --repo LifeMeter \
  --tag $tag \
  --name LifeMeter.zip \
  --file LifeMeter.zip

rm LifeMeter.zip
open https://github.com/codekitchen/LifeMeter/releases/tag/$tag

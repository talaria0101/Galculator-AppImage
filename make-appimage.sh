#!/bin/sh

set -eu

ARCH=$(uname -m)
# pacman -Q is skipped when get-dependencies.sh preset VERSION (galculator is
# installed from a tarball on the powerpc arches, where it is not packaged)
VERSION=${VERSION:-$(pacman -Q galculator | awk '{print $2; exit}')}
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/galculator.svg
export DESKTOP=/usr/share/applications/galculator.desktop
export ALWAYS_SOFTWARE=1

# Deploy dependencies
quick-sharun /usr/bin/galculator /usr/share/galculator

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage

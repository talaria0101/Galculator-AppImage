#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm flex intltool

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano  ! mesa ! vulkan

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

echo "Building galculator..."
echo "---------------------------------------------------------------"
git clone https://github.com/galculator/galculator.git ./galculator && (
	cd ./galculator

	# Build the latest stable tag
	TAG=$(git tag --list 'v*' --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -n 1)
	git checkout "$TAG"
	echo "$TAG" > ~/version

	# Required to build with modern compilers
	export CFLAGS="-std=gnu17 -O2 -fcommon"

	# The tag ships ancient config.guess/config.sub that do not
	# recognize aarch64, remove them so automake installs fresh ones
	rm -f ./config.guess ./config.sub

	./autogen.sh --prefix=/usr --enable-gtk3
	make -j"$(nproc)"
	make install
)


#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"

# galculator is not packaged on the powerpc port, it is built there from the
# upstream 2.1.4 dist tarball plus the build fixes carried by Arch packaging
case "$ARCH" in
	ppc64|ppc64le)
		# no autoconf/automake on this port, the dist tarball ships a pre-generated configure
		pacman -Syu --noconfirm \
			gcc \
			gettext \
			gtk3 \
			hicolor-icon-theme \
			libquadmath \
			make \
			patch \
			perl-xml-parser \
			pkgconf \
			wget

		# intltool is not packaged here either, it is a set of perl scripts
		# and needs the perl-5.26 fix that every distro carries
		wget --quiet -O /tmp/intltool.tar.gz \
			https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz
		wget --quiet -O /tmp/intltool-perl.patch \
			https://gitlab.archlinux.org/archlinux/packaging/packages/intltool/-/raw/main/intltool-0.51.0-perl-5.26.patch
		tar -xzf /tmp/intltool.tar.gz -C /tmp
		cd /tmp/intltool-0.51.0
		patch -Np1 -i /tmp/intltool-perl.patch
		./configure --prefix=/usr
		make
		make install

		wget --quiet -O /tmp/galculator.tar.gz \
			https://deb.debian.org/debian/pool/main/g/galculator/galculator_2.1.4.orig.tar.gz
		wget --quiet -O /tmp/0001.patch \
			https://gitlab.archlinux.org/archlinux/packaging/packages/galculator/-/raw/main/0001-Fix-multiple-definition-of-prefs-compile-error-with-.patch
		wget --quiet -O /tmp/0002.patch \
			https://gitlab.archlinux.org/archlinux/packaging/packages/galculator/-/raw/main/0002-Declare-function-parameters-as-required-by-C23.patch
		tar -xzf /tmp/galculator.tar.gz -C /tmp
		cd /tmp/galculator-2.1.4
		patch -Np1 -i /tmp/0001.patch
		patch -Np1 -i /tmp/0002.patch
		./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var
		make
		make install

		# preset so make-appimage.sh does not rely on pacman -Q galculator here
		VERSION=2.1.4
		export VERSION
		;;
	*)
		pacman -Syu --noconfirm galculator
		;;
esac

# debloated packages only ship for x86_64 and aarch64,
# disabled while the ported arches build from stock pacman packages
#echo "Installing debloated packages..."
#echo "---------------------------------------------------------------"
#get-debloated-pkgs --add-common --prefer-nano glycin-mini ! mesa ! vulkan ! gdk-pixbuf ! librsvg

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi

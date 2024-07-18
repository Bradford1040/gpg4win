#!/bin/sh
# Build an AppImage of GnuPG (VS-)Desktop
# Copyright (C) 2021 g10 Code GmbH
#
# Software engineering by Ingo Klöcker <dev@ingo-kloecker.de>
#
# This file is part of GnuPG.
#
# GnuPG is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# GnuPG is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: GPL-3.0+

set -e

cd /build
./autogen.sh --force
./configure --enable-appimage --enable-maintainer-mode --disable-manuals
make

if [ -f /build/gnupg-vsd/custom.mk ]; then
    if ls /src/packages/gnupg-2.2* >/dev/null 2>&1 ; then
        GNUPG_BUILD_VSD=yes
    else
        GNUPG_BUILD_VSD=desktop
    fi
else
    GNUPG_BUILD_VSD=no
fi
export GNUPG_BUILD_VSD

echo 'rootdir = $APPDIR/usr' >/build/AppDir/usr/bin/gpgconf.ctl
if [ $GNUPG_BUILD_VSD = yes ]; then
    echo 'sysconfdir = /etc/gnupg-vsd' >>/build/AppDir/usr/bin/gpgconf.ctl
else
    echo 'sysconfdir = /etc/gnupg' >>/build/AppDir/usr/bin/gpgconf.ctl
fi

# Copy the start-shell helper for use AppRun
cp /build/src/appimage/start-shell /build/AppDir/
chmod +x /build/AppDir/start-shell

# Copy standard global configuration
if [ $GNUPG_BUILD_VSD = yes ]; then
    mkdir -p /build/AppDir/usr/share/gnupg/conf/gnupg-vsd
    rsync -aLv --delete --omit-dir-times \
          /build/src/gnupg-vsd/Standard/etc/gnupg/ \
          /build/AppDir/usr/share/gnupg/conf/gnupg-vsd/
fi

export PATH=/opt/linuxdeploy/usr/bin:$PATH
export LD_LIBRARY_PATH=/build/install/lib:/build/install/lib64

# tell the linuxdeploy qt-plugin where to find qmake
export QMAKE=/build/install/bin/qmake

# create plugin directories expected by linuxdeploy qt-plugin
# workaround for
# [qt/stdout] Deploy[qt/stderr] terminate called after throwing an instance of 'boost::filesystem::filesystem_error'
# [qt/stderr]   what():  boost::filesystem::directory_iterator::construct: No such file or directory: "/build/AppDir/usr/plugins/sqldrivers"
# ERROR: Failed to run plugin: qt (exit code: 6)
mkdir -p /build/install/plugins/sqldrivers

# copy KDE plugins
for d in iconengines kauth kf6 okular pim6 plasma; do
    mkdir -p /build/AppDir/usr/plugins/${d}/
    rsync -av --delete --omit-dir-times /build/install/lib64/plugins/${d}/ /build/AppDir/usr/plugins/${d}/
done
cp -av /build/install/lib64/plugins/okularpart.so /build/AppDir/usr/plugins/

mkdir -p /build/AppDir/usr/lib
# copy dependencies of the plugins
# okularGenerator_*.so
cp -av /build/install/lib/libfreetype* /build/AppDir/usr/lib
# okularGenerator_poppler.so
cp -av /build/install/lib64/libpoppler* /build/AppDir/usr/lib
# okularGenerator_tiff.so
cp -av /usr/lib64/libtiff.so* /build/AppDir/usr/lib

# copy other libraries that are loaded dynamically
mkdir -p /build/AppDir/usr/lib
cp -av /build/install/lib64/libOkular6Core.so* /build/AppDir/usr/lib

cd /build
# Remove existing AppRun and wrapped AppRun, that may be left over
# from a previous run of linuxdeploy, to ensure that our custom AppRun
# is deployed
rm -f /build/AppDir/AppRun /build/AppDir/AppRun.wrapped 2>/dev/null
# Remove existing translations that may be left over from a previous
# run of linuxdeploy
rm -rf /build/AppDir/usr/translations
# Remove the version files to make sure that only one will be created.
rm -f /build/AppDir/GnuPG-VS-Desktop-VERSION 2>/dev/null
rm -f /build/AppDir/GnuPG-Desktop-VERSION    2>/dev/null
rm -f /build/AppDir/GnuPG-Foo-VERSION        2>/dev/null

# Extract gnupg version or (for VSD builds) gpg4win version for use
# as filename of the AppImage
if [ $GNUPG_BUILD_VSD = yes ]; then
    myversion=$(grep PACKAGE_VERSION /src/config.h|sed -n 's/.*"\(.*\)"$/\1/p')
    OUTPUT=gnupg-vs-desktop-${myversion}-x86_64.AppImage
    echo "Packaging GnuPG VS-Desktop Appimage: $myversion"
    echo $myversion >/build/AppDir/GnuPG-VS-Desktop-VERSION
    cp /build/gnupg-vsd/Standard/VERSION* /build/AppDir/usr/
    echo "Packaging help files"
    mkdir -p /build/AppDir/usr/share/doc/gnupg-vsd
    cp /build/gnupg-vsd/help/*.pdf /build/AppDir/usr/share/doc/gnupg-vsd
    echo "Packaging kleopatrarc"
    mkdir -p /build/AppDir/usr/etc/xdg
    cp /build/gnupg-vsd/Standard/kleopatrarc /build/AppDir/usr/etc/xdg
elif [ $GNUPG_BUILD_VSD = desktop ]; then
    myversion=$(ls /src/packages/gnupg-2.*tar.* \
                    | sed -n 's,.*/gnupg-\(2.*\).tar.bz2,\1,p')
    OUTPUT=gnupg-desktop-${myversion}-x86_64.AppImage
    echo "Packaging GnuPG Desktop Appimage: $myversion"
    echo $myversion >/build/AppDir/GnuPG-Desktop-VERSION
    cp /build/gnupg-vsd/Desktop/VERSION* /build/AppDir/usr/
    if [ -f /build/gnupg-vsd/Desktop/kleopatrarc ]; then
        echo "Packaging kleopatrarc"
        mkdir -p /build/AppDir/usr/etc/xdg
        cp /build/gnupg-vsd/Desktop/kleopatrarc /build/AppDir/usr/etc/xdg
    fi
else
    myversion=$(ls /src/packages/gnupg-2.*tar.bz2 \
                    | sed -n 's,.*/gnupg-\(2.*\).tar.*,\1,p')
    OUTPUT=gnupg-foo-${myversion}-x86_64.AppImage
    echo "Packaging Gpg4win Appimage: $myversion"
    echo $myversion >/build/AppDir/GnuPG-Foo-VERSION
fi
export OUTPUT

# Hack around that linuxdeploy does not know libexec
for f in dirmngr_ldap gpg-check-pattern \
         gpg-preset-passphrase gpg-protect-tool \
         gpg-wks-client scdaemon \
         keyboxd gpg-pair-tool; do
# Ignore errors because some files might not exist depending
# on GnuPG Version
    /opt/linuxdeploy/usr/bin/patchelf \
              --set-rpath '$ORIGIN/../lib' /build/AppDir/usr/libexec/$f || true
done

# linuxdeploy also doesn't know about non-Qt plugins
for d in iconengines kauth kf5 okular pim5 plasma; do
    for f in $(find /build/AppDir/usr/plugins/${d}/ -mindepth 1 -maxdepth 1 -type f); do
        /opt/linuxdeploy/usr/bin/patchelf --set-rpath '$ORIGIN/../../lib' $f
    done
    for f in $(find /build/AppDir/usr/plugins/${d}/ -mindepth 2 -maxdepth 2 -type f); do
        /opt/linuxdeploy/usr/bin/patchelf --set-rpath '$ORIGIN/../../../lib' $f
    done
done
/opt/linuxdeploy/usr/bin/patchelf \
        --set-rpath '$ORIGIN/../lib' /build/AppDir/usr/plugins/okularpart.so

# Fix up everything and build the file system
linuxdeploy --appdir /build/AppDir \
            --desktop-file /build/AppDir/usr/share/applications/org.kde.kleopatra.desktop \
            --icon-file /build/AppDir/usr/share/icons/hicolor/256x256/apps/kleopatra.png \
            --custom-apprun /build/appimage/AppRun \
            --plugin qt \
            --output appimage \
    2>&1 | tee /build/logs/linuxdeploy-gnupg-desktop.log

echo ready

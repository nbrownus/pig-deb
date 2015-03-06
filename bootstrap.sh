#!/bin/sh

VERSION="0.12.1"
BUILD="betable4"

set -e -x

DIRNAME="$(cd "$(dirname "$0")" && pwd)"
OLDESTPWD="$PWD"

cd "$(mktemp -d)"
#trap "rm -rf \"$PWD\"" EXIT INT QUIT TERM

curl -O "http://apache.mirrors.hoobly.com/pig/pig-$VERSION/pig-$VERSION.tar.gz"
tar xf "pig-$VERSION.tar.gz"

PIG_DIRNAME="pig-$VERSION"
cd "$PIG_DIRNAME"
ant -Dhadoopversion=23
cd ..

find "$DIRNAME" -type "d" -printf "%P\n" |
xargs -I"__" mkdir -p "rootfs/__"

find "$DIRNAME" -not -name "bootstrap.sh" -not -name "README.md" -type "f" -printf "%P\n" |
xargs -I"__" cp "$DIRNAME/__" "rootfs/__"

mkdir -p "$PWD/rootfs/var/lib/pig/lib" "$PWD/rootfs/usr/bin" "$PWD/rootfs/etc/pig"
mv "$PIG_DIRNAME/conf/"* "rootfs/etc/pig/"
mv "$PIG_DIRNAME/bin/pig" "rootfs/usr/bin/"
mv "$PIG_DIRNAME/pig-withouthadoop.jar" "rootfs/var/lib/pig/pig-withouthadoop.jar"
mv "$PIG_DIRNAME/pig.jar" "rootfs/var/lib/pig/pig.jar"

fakeroot fpm -C "$PWD/rootfs" \
             -m "Nate Brown <nate@betable.com>" \
             -n "pig" -v "$VERSION-$BUILD" \
             -p "$OLDESTPWD/pig_${VERSION}-${BUILD}_amd64.deb" \
             -s "dir" -t "deb" \
             "usr" "etc" "var"

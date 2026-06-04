#!/usr/bin/env bash

set -e

BUILD_ROOT=$(pwd)

: "${LIBRAW_REVISION:=$(jq -cr '.revision' libraw.json)}"

git clone https://github.com/libraw/libraw.git
cd libraw
git reset --hard "$LIBRAW_REVISION"

echo "Applying libraw patches"
git apply "$BUILD_ROOT/libraw-patches/internal-adobedng.patch"

sed -i -f - configure.ac <<EOF
/^AC_OUTPUT$/i \\
case "$\{host_os}" in \\
    linux*) \\
        AC_DEFINE(qLinux) \\
        ;; \\
    cygwin*|mingw*) \\
        AC_DEFINE(qWinOS) \\
        ;; \\
    darwin*) \\
        AC_DEFINE(qMacOS) \\
        ;; \\
    android*) \\
        AC_DEFINE(qAndroid) \\
        ;; \\
    *) \\
        AC_MSG_ERROR(["$\host_os not supported"]) \\
        ;; \\
esac \\
AC_DEFINE(USE_DNGSDK) \\
AC_DEFINE(USE_JPEG) \\
AC_DEFINE(USE_JPEG8) \\
AC_DEFINE(USE_ZLIB) \\
EOF
ROOT_DIR=$(cd ../libdng; pwd)
EXTRA_INCLUDE="-I$ROOT_DIR/dng_sdk/source -I$ROOT_DIR/xmp/toolkit/public/include"
autoreconf --install
CFLAGS="$CFLAGS $EXTRA_INCLUDE" \
CXXFLAGS="$CXXFLAGS $EXTRA_INCLUDE" \
LDFLAGS="$LDFLAGS \
  -ldng \
  -lstaticXMPCore \
  -lstaticXMPFiles \
  -ljxl \
  -ljxl_cms \
  -ljxl_extras_codec \
  -ljxl_threads \
  -lbrotlidec \
  -lbrotlienc \
  -lbrotlicommon \
  -ljpeg \
  -lhwy \
  -lz \
" ./configure --disable-examples
echo "Building libraw using $(nproc) threads"
make -j"$(nproc)"
make install
cd .. && rm -rf libraw libdng libxmp
ldconfig /usr/local/lib

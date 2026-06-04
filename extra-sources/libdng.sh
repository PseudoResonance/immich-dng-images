#!/usr/bin/env bash

set -e

BUILD_ROOT=$(pwd)

: "${LIBDNG_VERSION:=$(jq -cr '.version' libdng.json)}"
: "${LIBDNG_REVISION:=$(jq -cr '.revision' libdng.json)}"

wget -O "dng_sdk_${LIBDNG_VERSION//./_}.zip" "https://download.adobe.com/pub/adobe/dng/dng_sdk_${LIBDNG_VERSION//./_}_${LIBDNG_REVISION}.zip"
unzip "dng_sdk_${LIBDNG_VERSION//./_}.zip"
rm "dng_sdk_${LIBDNG_VERSION//./_}.zip"
mv "dng_sdk_${LIBDNG_VERSION//./_}" "libdng"

cp "$BUILD_ROOT/libdng-patches/configure.ac" "$BUILD_ROOT/libdng-patches/Makefile.am" "libdng/dng_sdk/source"

: "${LIBXMP_REVISION:=$(jq -cr '.revision' libxmp.json)}"

git clone https://github.com/adobe/XMP-Toolkit-SDK.git libxmp
cd libxmp
git reset --hard "$LIBXMP_REVISION"
cd ..

# Build libxmp

ln -s $BUILD_ROOT/libdng/xmp/toolkit/* $BUILD_ROOT/libdng/xmp
cp -r libxmp/build/shared libdng/xmp/build
cd libdng/xmp/toolkit/build
cat <<EOF >> CMakeLists.txt
install(TARGETS XMPCoreStatic XMPFilesStatic
        ARCHIVE DESTINATION lib)
EOF
sed -i 's|COMMAND  mv ${OUTPUT_DIR}/lib${XMPCORE_LIB}.a  ${OUTPUT_DIR}/${XMPCORE_LIB}.ar|COMMAND  echo "skip mv"|' "$BUILD_ROOT/libdng/xmp/XMPCore/build/CMakeListsCommon.txt"
sed -i 's|COMMAND  mv ${OUTPUT_DIR}/lib${XMPFILES_LIB}.a  ${OUTPUT_DIR}/${XMPFILES_LIB}.ar|COMMAND  echo "skip mv"|' "$BUILD_ROOT/libdng/xmp/XMPFiles/build/CMakeListsCommon.txt"
cmake -DXMP_BUILD_STATIC=True \
  -DCMAKE_BUILD_TYPE=Release \
  "-DXMP_ROOT=$BUILD_ROOT/libdng/xmp/toolkit/" \
  .
echo "Building libxmp using $(nproc) threads"
cmake --build . -- -j"$(nproc)"
cmake --install .
cd "$BUILD_ROOT"

# Build libdng

cd libdng/dng_sdk/source

autoreconf --install
./configure
echo "Building libdng using $(nproc) threads"
make -j"$(nproc)"
make install
cd "$BUILD_ROOT"
ldconfig /usr/local/lib

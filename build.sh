#!/usr/bin/env sh

cd "$(dirname "$0")"

git clone https://github.com/immich-app/base-images.git base

mkdir -p work
cd work

echo "ARG IMMICH_TAG" > ./Dockerfile
cat ../base/server/Dockerfile | sed '/FROM base AS libraw/q' | head -n -1 >> ./Dockerfile
cat ../Dockerfile.append >> ./Dockerfile
cp ../base/server/configure-apt.sh ./
mkdir -p ./sources
cp -r ../base/server/sources/* ./sources/
cp -r ../extra-sources/* ./sources/

docker build -t immich-server-custom:${IMMICH_TAG} --build-arg IMMICH_TAG=${IMMICH_TAG} -f ./Dockerfile .

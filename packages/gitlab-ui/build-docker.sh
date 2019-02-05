#!/usr/bin/env sh

set -e

BASE_IMAGE=dev.gitlab.org:5005/gitlab/gitlab-build-images:gitlab-puppeteer
CURRENT_PUPPETEER_VERSION=$(grep '^puppeteer@' -A 1 yarn.lock | grep 'version' | sed 's#.*"\(.*\)".*#\1#')

echo "puppeteer version: $PUPPETEER_VERSION"

if ! [ "$CURRENT_PUPPETEER_VERSION" = "$PUPPETEER_VERSION" ]; then
    echo "The puppeteer version in .gitlab-ci.yml ($PUPPETEER_VERSION) and yarn.lock ($CURRENT_PUPPETEER_VERSION) do not match"
    echo "Please ensure that they both have the same value!"
    exit 1
fi

TARGET_IMAGE=${PUPPETEER_IMAGE:-puppeteer:$PUPPETEER_VERSION}

if docker manifest inspect "$TARGET_IMAGE" 2> /dev/null > /dev/null; then
    echo "Docker image $TARGET_IMAGE already exists"
    exit 0
else
    echo "Building target image $TARGET_IMAGE"
fi

GLOBAL_DIR=$(docker run --rm $BASE_IMAGE yarn global dir)
CHROMIUM_REVISION=$(docker run --rm $BASE_IMAGE yarn info --silent "puppeteer@$PUPPETEER_VERSION" puppeteer.chromium_revision)

CHROMIUM_DIR="$GLOBAL_DIR/node_modules/puppeteer/.local-chromium/linux-$CHROMIUM_REVISION/chrome-linux/chrome"

echo "chromium revision: $CHROMIUM_REVISION"
echo "executable dir: $CHROMIUM_DIR"

docker build . \
  --build-arg "PUPPETEER_VERSION=$PUPPETEER_VERSION" \
  --build-arg "EXECUTABLE_PATH=$CHROMIUM_DIR" \
  --tag "$TARGET_IMAGE"

echo "Everything is fine, we are pushing"

docker push "$TARGET_IMAGE"

#!/usr/bin/env bash

# Configuration #
DEPLOY="${TRAVIS_BUILD_DIR}/testfile.txt"
FILENAME="testfile.txt"
TARGET="http://continuum.flibio.net/api/"
PROJECT="ContinuumTest"

# Install JQ #

wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x ./jq
sudo cp /usr/bin

# Create a new Continuum build #
echo $(curl -v -X POST -d "project=${PROJECT}&commit=${TRAVIS_COMMIT}&job=${TRAVIS_BUILD_ID}" -u continuum:${CONTINUUM_TOKEN} "${TARGET}newbuild.php") >> response.json
BUILD=$(jq '.build' response.json | tr -d '"')
STATUS=$(jq '.status' response.json | tr -d '"')

echo "New build status: ${STATUS}"
echo "New build number: ${BUILD}"

# Check if the build was created successfully #
if [[ ${BUILD} -gt 0 ]]; then
    echo "Created build ${BUILD}!"

    # Upload the file #
    echo $(curl -v -X POST --form "file=@${DEPLOY};filename=${FILENAME}" --form "project=${PROJECT}" --form "build=${BUILD}" -u continuum:${CONTINUUM_TOKEN} "${TARGET}upload.php")
else
    echo "Failed to create a build!"
fi

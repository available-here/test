#!/bin/bash

set -e

echo "======================================"
echo "        BUILD STARTED"
echo "======================================"

echo "Workspace: $(pwd)"
echo "Git branch: $(git branch --show-current)"
echo "Git commit: $(git rev-parse HEAD)"

# ------------------------------------------------
# Put your actual application build command here
# ------------------------------------------------

# Example for Maven:
# mvn clean package

# Example for Node.js:
# npm install
# npm run build

# Example for Gradle:
# ./gradlew clean build

echo ""
echo "Build completed successfully."

# Create a test artifact if no real build is configured
mkdir -p build
echo "Build successful - Jenkins Build ${BUILD_NUMBER:-TEST}" > build/build-info.txt

echo ""
echo "Build artifact:"
cat build/build-info.txt

echo "======================================"
echo "        BUILD COMPLETED"
echo "======================================"
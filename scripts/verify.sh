#!/bin/bash

set -e

echo "======================================"
echo "       VERIFICATION STARTED"
echo "======================================"

echo "Checking build directory..."

if [ ! -d "build" ]; then
    echo "ERROR: build directory not found."
    exit 1
fi

echo "Checking build artifact..."

if [ ! -f "build/build-info.txt" ]; then
    echo "ERROR: build artifact not found."
    exit 1
fi

echo "Build artifact found."

echo ""
echo "Artifact content:"
cat build/build-info.txt

echo ""
echo "Checking deployment scripts..."

for file in \
    deploy/deploy-dev.sh \
    deploy/deploy-qa.sh \
    deploy/deploy-staging.sh
do
    if [ ! -f "$file" ]; then
        echo "ERROR: $file not found."
        exit 1
    fi

    echo "OK: $file"
done

echo ""
echo "======================================"
echo "    VERIFICATION SUCCESSFUL"
echo "======================================"
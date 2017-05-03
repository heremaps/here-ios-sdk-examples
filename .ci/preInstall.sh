#!/bin/sh

# Download the HERE SDK.
wget "$HERE_SDK_URL" -q -O 'HERE_SDK.tar.gz'
tar -xzf 'HERE_SDK.tar.gz'
rm 'HERE_SDK.tar.gz'

# Find paths that contain an xcodeproj directory.
APP_PROJECTS=$(find "$PWD" -mindepth 2 -maxdepth 2 -type d -name "*.xcodeproj")

for APP_PATH in $APP_PROJECTS; do
    PROJECT_DIR=$(dirname "$APP_PATH")
    cp -r HERESDK-Premium/framework/NMAKit.framework "$PROJECT_DIR"
done

rm -rf 'HERESDK-Premium'

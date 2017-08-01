#!/bin/sh

# Find paths that contain an xcodeproj directory.
APP_PROJECTS=$(find "$PWD" -mindepth 2 -maxdepth 2 -type d -name "*.xcworkspace")
SDK=iphonesimulator10.3
DESTINATION="OS=10.3.1,name=iPhone SE"

for APP_PATH in $APP_PROJECTS; do
    PROJECT_DIR=$(dirname "$APP_PATH")
    cd $PROJECT_DIR
    # Get project name without extension.
    PROJECT_NAME=$(basename "$APP_PATH" .xcworkspace)
    # Build workspace with scheme.
    xcodebuild -workspace "$PROJECT_NAME".xcworkspace -scheme "$PROJECT_NAME" -sdk "$SDK" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO clean build
done

#!/bin/sh

# Find paths that contain an xcodeproj directory.
APP_PROJECTS=$(find "$PWD" -mindepth 2 -maxdepth 2 -type d -name "*.xcodeproj")
SDK=iphonesimulator10.3
DESTINATION="OS=10.3,name=iPhone SE"

for APP_PATH in $APP_PROJECTS; do
    xcodebuild -project "$APP_PATH" -sdk "$SDK" -destination "$DESTINATION" -configuration Debug ONLY_ACTIVE_ARCH=NO clean build
done

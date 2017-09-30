#!/bin/sh

# Install gems defined on Gemfile.
bundle install

# Update local pod repo.
pod repo update

# Find paths that contain a Podfile.
APP_PROJECTS=$(find "$PWD" -mindepth 2 -maxdepth 2 -type f -name Podfile)

for APP_PATH in $APP_PROJECTS; do
    PROJECT_DIR=$(dirname "$APP_PATH")
    cd $PROJECT_DIR
    pod install
done

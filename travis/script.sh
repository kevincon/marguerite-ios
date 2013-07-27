#!/bin/sh
set -e

xctool -workspace marguerite.xcworkspace -scheme marguerite -sdk iphonesimulator build

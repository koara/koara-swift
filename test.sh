#!/bin/bash
set -e
xcodebuild test -scheme Koara-iOS -destination "platform=iOS Simulator,name=iPhone 6"
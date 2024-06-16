#!/bin/bash -e

__DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd $__DIR__
root_dir=macos

# https://github.com/flutter/flutter/issues/41900#issuecomment-601599410
flutter clean
flutter pub get
rm -f pubspec.lock

cd $root_dir
# rm -f ./Podfile # can't delete that because line 34~36 (it will cause error: [!] Unable to find a target named `RunnerTests` in project `Runner.xcodeproj`, did find `Runner`.)
rm -f ./Podfile.lock 
rm -rf ./Pods
# rm -fr $root_dir/Runner.xcworkspace # can't delete this, it won't auto generate
cd  ..
pod setup
flutter run -d macos

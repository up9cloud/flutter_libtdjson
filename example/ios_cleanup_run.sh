#!/bin/bash -e

__DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd $__DIR__
root_dir=ios

# https://github.com/flutter/flutter/issues/41900#issuecomment-601599410
flutter clean
rm -f pubspec.lock
# rm -f $root_dir/Podfile # can't delete that because line 34~36 (it will cause error: [!] Unable to find a target named `RunnerTests` in project `Runner.xcodeproj`, did find `Runner`.)
rm -f $root_dir/Podfile.lock
rm -rf $root_dir/Pods $root_dir/Runner.xcworkspace
flutter run --debug

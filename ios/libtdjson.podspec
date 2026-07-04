#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint libtdjson.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'libtdjson'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'flutter_libtdjson', '1.8.65'
  s.platform = :ios, '12.0'

  s.ios.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '$(inherited) -force_load "${PODS_XCFRAMEWORKS_BUILD_DIR}/flutter_libtdjson/libtdjson.a" -lz -lc++',
    # 'OTHER_LDFLAGS' => '-l"tdjson"',
    # 'LIBRARY_SEARCH_PATHS' => '$(inherited) "${PODS_XCFRAMEWORKS_BUILD_DIR}/flutter_libtdjson"',
    # 'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) "${PODS_XCFRAMEWORKS_BUILD_DIR}/flutter_libtdjson"',
  }
  s.swift_version = '5.0'
end

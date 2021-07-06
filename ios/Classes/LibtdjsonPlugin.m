#import "LibtdjsonPlugin.h"
#if __has_include(<libtdjson/libtdjson-Swift.h>)
#import <libtdjson/libtdjson-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "libtdjson-Swift.h"
#endif

@implementation LibtdjsonPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLibtdjsonPlugin registerWithRegistrar:registrar];
}
@end

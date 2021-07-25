#import "LibtdjsonPlugin.h"

// Must @implementation, otherwise it will cause error: Undefined symbols for architecture ...
@implementation LibtdjsonPlugin
// Must implement registerWithRegistrar, otherwise the app will crash
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//   FlutterMethodChannel* channel = [FlutterMethodChannel
//       methodChannelWithName:@"libtdjson"
//             binaryMessenger:[registrar messenger]];
//   LibtdjsonPlugin* instance = [[LibtdjsonPlugin alloc] init];
//   [registrar addMethodCallDelegate:instance channel:channel];
}

// - (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
//   if ([@"getPlatformVersion" isEqualToString:call.method]) {
//     result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
//   } else {
//     result(FlutterMethodNotImplemented);
//   }
// }

@end

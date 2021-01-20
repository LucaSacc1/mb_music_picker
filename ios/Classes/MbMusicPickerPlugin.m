#import "MbMusicPickerPlugin.h"
#if __has_include(<mb_music_picker/mb_music_picker-Swift.h>)
#import <mb_music_picker/mb_music_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mb_music_picker-Swift.h"
#endif

@implementation MbMusicPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMbMusicPickerPlugin registerWithRegistrar:registrar];
}
@end


import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mb_music_picker/mb_music_item.dart';

class MbMusicPicker {
  static const MethodChannel _channel =
      const MethodChannel('mb_music_picker');

  Future<MBMusicItem> openMusicSelection() async {
    try {
      final Map<dynamic,dynamic> result = await _channel.invokeMethod('openMusicSelection');
      if (result == null) {
        return null;
      }

      return Platform.isIOS ? MBMusicItem.fromCupertinoMap(result) : MBMusicItem.fromAndroidMap(result);
    } on PlatformException catch (e) {
      print("Failed to pick a media item: '${e.message}'.");
      return null;
    }
  }
}

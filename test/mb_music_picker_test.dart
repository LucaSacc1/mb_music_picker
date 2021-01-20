import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mb_music_picker/mb_music_picker.dart';

void main() {
  const MethodChannel channel = MethodChannel('mb_music_picker');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}

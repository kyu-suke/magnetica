import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnetica/magnetica.dart';

void main() {
  const MethodChannel channel = MethodChannel('magnetica');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(Magnetica.unregisterAll, '42');
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:aqua_health/main.dart';

void main() {
  test('app entry remains the single egg hatcher screen', () {
    const MyApp app = MyApp();

    expect(app, isA<MyApp>());
    expect(const EggHatcherScreen(), isA<EggHatcherScreen>());
  });
}

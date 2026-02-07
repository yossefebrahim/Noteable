import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/providers/app_provider.dart';

void main() {
  test('basic smoke: AppProvider defaults to system theme', () {
    final app = AppProvider();
    expect(app.isDarkMode, isFalse);
  });
}

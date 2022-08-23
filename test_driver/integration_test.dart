import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart' as driver;

void main() async {
  try {
    await driver.integrationDriver(
      onScreenshot: (name, bytes) async {
        final file = await File('screenshots/$name.png').create(recursive: true);
        file.writeAsBytesSync(bytes);
        return true;
      },
    );
  } catch (e) {
    print('+++ catch error: ${e.toString()}');
  }
}

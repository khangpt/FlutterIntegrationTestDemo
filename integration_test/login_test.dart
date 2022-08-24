import 'dart:io';

import 'package:demo/simple_app.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/main.dart' as app;

Future<void> takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester, {
  required String name,
}) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(name);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test login flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await takeScreenshot(binding, tester, name: 'pic-1');

    /// phải có chính xác 1 email box
    final emailFinder = find.byKey(const Key('email-box'));
    expect(emailFinder, findsOneWidget);

    /// phải có chính xác 1 password box
    final passwordFinder = find.byKey(const Key('password-box'));
    expect(passwordFinder, findsOneWidget);

    /// string báo lỗi phải không hiển thị nội dung gì (vì ban đầu user chưa tương tác gì)
    /// scenarios (xoá trước khi present):
    /// * sẽ exception chỗ này (vì có quá nhiều widget Text mà có text = "")
    /// * sẽ chuyển thành `find.byKey` và thêm Key vào widget Text tương ứng
    // final errorStringFinder = find.text('');
    final errorStringFinder = find.byKey(const Key('error-label'));
    expect(errorStringFinder, findsOneWidget);

    /// ban đầu button login phải có & bị disable
    final loginButtonFinder = find.byType(ElevatedButton);
    expect(loginButtonFinder, findsOneWidget);
    final loginButtonWidget = tester.widget<ElevatedButton>(loginButtonFinder);
    expect(loginButtonWidget.onPressed, isNull);

    /// ban đầu thì sẽ không có progress indicator xuất hiện
    var progressIndicatorFinder = find.byType(CircularProgressIndicator);
    expect(progressIndicatorFinder, findsNothing);

    await Future.delayed(const Duration(seconds: 2));

    /// nhập dữ liệu và test
    await tester.enterText(emailFinder, 'user_email');
    await tester.enterText(passwordFinder, 'user-password');
    await tester.pumpAndSettle();

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    await takeScreenshot(binding, tester, name: 'pic-2');

    var errorStringWidget = tester.widget<Text>(errorStringFinder);
    expect(errorStringWidget.data, equals('Invalid user input'));

    await Future.delayed(const Duration(seconds: 2));

    await tester.enterText(emailFinder, 'user-email@mail.com');
    await tester.tap(loginButtonFinder);
    await tester.pump();

    /// error label phải mất đi
    errorStringWidget = tester.widget<Text>(errorStringFinder);
    expect(errorStringWidget.data, equals(''));

    /// progress indicator phải hiển thị
    progressIndicatorFinder = find.byType(CircularProgressIndicator);
    expect(progressIndicatorFinder, findsOneWidget);

    await tester.pumpAndSettle();

    final centerFinder = find.descendant(
      of: find.byType(SimpleHomePage),
      matching: find.byKey(const Key('center-label')),
    );
    expect(centerFinder, findsOneWidget);

    var centerLabelFinder = find.descendant(of: centerFinder, matching: find.byType(Text));
    expect(centerLabelFinder, findsOneWidget);
    var centerLabelWidget = tester.widget<Text>(centerLabelFinder);
    expect(centerLabelWidget.data, equals('Waiting'));

    /// chờ request network xong (hiện tại đây là cách chờ một request nào đó từ server sau đó mới thực hiện test tiếp)
    await Future.delayed(const Duration(seconds: 5));

    /// scenarios (xoá trước khi present):
    /// * sẽ exception chỗ này (vì không thể so sánh đúng giá trị của Text trước và sau request giả lập)
    /// * ở đây ta phải pump frame để UI cập nhật giá trị mới sau khi request, nếu không thì case test ở dòng 93 không bao giờ đúng
    await tester.pump();

    centerLabelFinder = find.descendant(of: centerFinder, matching: find.byType(Text));
    expect(centerLabelFinder, findsOneWidget);
    centerLabelWidget = tester.widget<Text>(centerLabelFinder);
    expect(centerLabelWidget.data, equals('Hi there!'));

    await tester.pumpAndSettle();
  });
}

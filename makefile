clean:
	flutter clean

get:
	flutter pub get

run:
	flutter run --debug -t lib/main.dart

do_test:
	flutter test integration_test/login_test.dart -r expanded

do_drive:
	flutter drive --driver=test_driver/integration_test.dart --target=integration_test/login_test.dart
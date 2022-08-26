# run cmd: "flutter build ios --config-only integration_test/login.dart" first

output="../build/ios_integration"
product="build/ios_integration/Build/Products"
dev_target="15.4"

flutter build ios integration_test/login_test.dart --release

pushd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -config Flutter/Release.xcconfig -derivedDataPath $output -sdk iphoneos build-for-testing
popd

pushd $product
zip -r "ios_tests.zip" "Release-iphoneos" "Runner_iphoneos$dev_target-arm64.xctestrun"
popd

# check all available ios device on firebase testlab
# gcloud firebase test ios models list

# test ios
gcloud firebase test ios run --test "$product/ios_tests.zip" \
    --device model=ipadmini4,version=$dev_target,orientation=portrait \
    --timeout 5m \
    --results-bucket=gs://integrationtest-demo2.appspot.com \
    --results-dir=tests/ios
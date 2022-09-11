flutter build ios --config-only integration_test/login_test.dart

repository="/Users/runner/work/FlutterIntegrationTestDemo/FlutterIntegrationTestDemo"
output="$repository/build/ios_integration"
product="$repository/build/ios_integration/Build/Products"

# target on github action
dev_target="15.2"

flutter build ios -t integration_test/login_test.dart --release

pushd ios
xcodebuild -workspace Runner.xcworkspace \
        -scheme Runner \
        -config Flutter/Release.xcconfig \
        -derivedDataPath $output \
        -sdk iphoneos build-for-testing
popd

pushd $product
zip -r "ios_tests.zip" "Release-iphoneos" "Runner_iphoneos$dev_target-arm64.xctestrun"
popd

# check all available ios device on firebase testlab
# gcloud firebase test ios models list

# test ios
gcloud firebase test ios run --test "$product/ios_tests.zip" \
    --device model=iphone13pro,version=$dev_target,orientation=portrait \
    --timeout 5m \
    --results-bucket=gs://integrationtest-demo2.appspot.com \
    --results-dir=tests/ios
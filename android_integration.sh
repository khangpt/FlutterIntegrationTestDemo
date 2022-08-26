# build apk 
pushd android
flutter build apk --debug
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/login_test.dart
popd

# connect to google cloud
gcloud auth activate-service-account --key-file=integrationtest-demo2-0ddd6a5bde75.json

# set project with 'Project ID' get from firebase console
gcloud --quiet config set project integrationtest-demo2

# check all available android device on firebase testlab
# gcloud firebase test android models list

# test anroid
gcloud firebase test android run --type instrumentation \
    --app build/app/outputs/apk/debug/app-debug.apk \
    --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
    --use-orchestrator \
    --device-ids=oriole \
    --os-version-ids=30,31 \
    --orientations=portrait \
    --timeout 5m \
    --results-bucket=gs://integrationtest-demo2.appspot.com \
    --results-dir=tests/android

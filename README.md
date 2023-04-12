# About

Flutter + Android docker image for Gitlab CI.

# Example

```
build_android_apk:
  stage: build_android_apk
  image:
    name: pewx22/android_33_flutter_3.7.10:latest
  allow_failure: false
  before_script:
    - export PUB_CACHE=.pub-cache
    - export PATH="$PATH":"$PUB_CACHE/bin"
    - touch android/key.properties
    - echo "storePassword=${STORE_PASSWORD}" >> android/key.properties
    - echo "keyPassword=${KEY_PASSWORD}" >> android/key.properties
    - echo "keyAlias=upload" >> android/key.properties
    - echo "storeFile=../upload-keystore.jks" >> android/key.properties
    - flutter pub get
    - flutter pub run build_runner build --delete-conflicting-outputs
  script: flutter build apk --build-number=$CI_PIPELINE_ID
  artifacts:
    paths:
      - build/app/outputs/apk/release/*.apk
    expire_in: 30 days
  only:
    - merge_requests
````

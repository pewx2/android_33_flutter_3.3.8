FROM adoptopenjdk/openjdk11:x86_64-ubuntu-jdk-11.0.18_10

RUN java -version \
    && apt update \
    && apt install unzip wget git -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG VERSION_TOOLS=9477386
ENV ANDROID_SDK_ROOT "/sdk"

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip \
    && unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools \
    && rm *tools*linux*.zip

ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator

ADD packages.txt /sdk
RUN sdkmanager --list \
    && yes | sdkmanager --licenses \
    && sdkmanager --package_file=/sdk/packages.txt 

ARG flutter_version=3.7.10

ENV FLUTTER_HOME=${HOME}/sdk/flutter \
    FLUTTER_VERSION=$flutter_version
ENV FLUTTER_ROOT=$FLUTTER_HOME

ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} 

RUN yes | flutter doctor --android-licenses && flutter doctor -v
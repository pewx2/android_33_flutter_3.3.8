FROM --platform=linux/amd64 ubuntu:20.04

USER root

ENV VERSION_TOOLS "8512546"

ENV ANDROID_SDK_ROOT "/sdk"
# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update \
    && apt-get install -qqy --no-install-recommends \
      bzip2 \
      bash \
      curl \
      git-core \
      html2text \
      openjdk-11-jdk \
      libc6-dev \ 
      unzip \
      locales \
      file \
      xz-utils \
      zip \
      libglu1-mesa \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /cmdline-tools.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
 && unzip /cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && rm -v /cmdline-tools.zip \
 && mkdir -p $ANDROID_SDK_ROOT/licenses/ \
 && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
 && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
 && yes | sdkmanager --licenses >/dev/null \
 && mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && sdkmanager --update

ADD packages.txt /sdk
RUN sdkmanager --package_file=/sdk/packages.txt

ARG flutter_version=3.3.8

ENV FLUTTER_HOME=${HOME}/sdks/flutter \
    FLUTTER_VERSION=$flutter_version
ENV FLUTTER_ROOT=$FLUTTER_HOME

ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN yes | flutter doctor --android-licenses \
    && flutter doctor \
    && chown -R root:root ${FLUTTER_HOME}
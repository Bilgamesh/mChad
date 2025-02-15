#https://hub.docker.com/_/openjdk
ARG OPENJDK_VERSION=11
FROM openjdk:${OPENJDK_VERSION}

# Reference default value
ARG OPENJDK_VERSION
#https://github.com/nodesource/distributions/blob/master/README.md
ARG NODEJS_VERSION=20
#https://gradle.org/releases/
ARG GRADLE_VERSION=8.7
#https://www.npmjs.com/package/cordova?activeTab=versions
ARG CORDOVA_VERSION=12.0.0
#https://developer.android.com/studio#command-tools
ARG ANDROID_CMDTOOLS_VERSION=9477386

WORKDIR /opt/src

ENV JAVA_HOME /usr/local/openjdk-${OPENJDK_VERSION}/
ENV ANDROID_SDK_ROOT /usr/local/android-sdk-linux
ENV ANDROID_HOME $ANDROID_SDK_ROOT
ENV GRADLE_USER_HOME /opt/gradle
ENV PATH $PATH:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$GRADLE_USER_HOME/bin

# NodeJS
RUN echo https://deb.nodesource.com/setup_${NODEJS_VERSION}.x
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash -
RUN apt -qq install -y nodejs

# Cordova
RUN npm i -g cordova@${CORDOVA_VERSION}

# Gradle
RUN curl -so /tmp/gradle-${GRADLE_VERSION}-bin.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip -qd /opt /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle

# Android
RUN curl -so /tmp/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip && \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/ && \
    unzip -qd $ANDROID_SDK_ROOT/cmdline-tools/ /tmp/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest

# Update and accept licences
COPY android.packages android.packages
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sdkmanager --package_file=android.packages

# Create a dummy project to cache official and useful plugins
RUN cordova telemetry off
RUN cordova create app
RUN cd app && cordova plugin add cordova-plugin-battery-status
RUN cd app && cordova plugin add cordova-plugin-camera
RUN cd app && cordova plugin add cordova-plugin-device@3.0.0
RUN cd app && cordova plugin add cordova-plugin-dialogs
RUN cd app && cordova plugin add cordova-plugin-file@8.0.1
RUN cd app && cordova plugin add cordova-plugin-geolocation
RUN cd app && cordova plugin add cordova-plugin-inappbrowser@6.0.0
RUN cd app && cordova plugin add cordova-plugin-media
RUN cd app && cordova plugin add cordova-plugin-media-capture
RUN cd app && cordova plugin add cordova-plugin-network-information
RUN cd app && cordova plugin add cordova-plugin-screen-orientation@3.0.4
RUN cd app && cordova plugin add cordova-plugin-splashscreen
RUN cd app && cordova plugin add cordova-plugin-statusbar@4.0.0
RUN cd app && cordova plugin add cordova-plugin-vibration
RUN cd app && cordova plugin add cordova-plugin-velda-devicefeedback@0.0.2
RUN cd app && cordova plugin add cordova-plugin-timer@1.0.1
RUN cd app && cordova plugin add cordova-plugin-theme-detection@1.3.0
RUN cd app && cordova plugin add cordova-plugin-secure-key-store@1.5.5
RUN cd app && cordova plugin add github:fquirin/cordova-plugin-navigationbar#88a00417135ce75092178f0a69688f291c04a06a
RUN cd app && cordova plugin add github:katzer/cordova-plugin-local-notifications#31612410e335da477902e6597d4010adb81ebbab
RUN cd app && cordova plugin add cordova-plugin-badge@0.8.9
RUN cd app && cordova plugin add cordova-plugin-background-fetch@7.2.4
RUN cd app && cordova plugin add cordova-plugin-advanced-http@3.3.1
RUN cd app && cordova plugin add cordova-clipboard@1.3.0
RUN cd app && cordova plugin add cordova-clipboard-api@1.0.1
RUN cd app && cordova platform add android@12.0.1
RUN cd app && cordova platform add browser@7.0.0
RUN cd app && rm -f ./platforms/android/app/src/main/java/com/verso/cordova/clipboard/Clipboard.java
RUN cd app && cordova build android
RUN cd app && cordova build browser
RUN rm -rf app

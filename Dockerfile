# Jenkins image with support for Android builds.
# Base image is the offical docker image for jenkins, with Android support inspired by docker-android-project https://github.com/gfx/docker-android-project/blob/master/Dockerfile

FROM jenkins:latest
MAINTAINER Jeff Kalikstein <jeff@leanmeantech.com>

# the jenkins Dockerfile leaves us as user 'jenkins', so switch to root for our Android install.
# We switch back to Jenkins at the end
USER root

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -yq libc6:i386 libstdc++6:i386 zlib1g:i386 libncurses5:i386 --no-install-recommends && \
    apt-get clean

# Download and untar SDK
ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN curl -L "${ANDROID_SDK_URL}" | tar --no-same-owner -xz -C /usr/local
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_SDK /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

# Install Android SDK components

# License Id: android-sdk-license-ed0d0a5b
ENV ANDROID_COMPONENTS platform-tools,build-tools-23.0.3,android-23, android-24, build-tools-24.0.0, build-tools-24.0.1
# License Id: android-sdk-license-5be876d5
ENV GOOGLE_COMPONENTS extra-android-m2repository,extra-google-m2repository

RUN echo y | android update sdk --no-ui --all --filter "${ANDROID_COMPONENTS}" ; \
    echo y | android update sdk --no-ui --all --filter "${GOOGLE_COMPONENTS}"

# Support Gradle
ENV TERM dumb

USER jenkins

RUN install-plugins.sh git slack 

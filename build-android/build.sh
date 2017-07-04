
# options
develop=
release=
RELEASE_DIR="spidermonkey-android"

usage(){
cat << EOF
usage: $0 [options]

Build SpiderMonkey using Android NDK

OPTIONS:
-d  Build for development
-r  Build for release. specify RELEASE_DIR.
-h  this help

EOF
}

while getopts "drh" OPTION; do
case "$OPTION" in
d)
develop=1
;;
r)
release=1
;;
h)
usage
exit 0
;;
esac
done

set -x

host_os=`uname -s | tr "[:upper:]" "[:lower:]"`
host_arch=`uname -m`

# # remove everything but the static library and this script
ls | grep -v build.sh | xargs rm -rf

export OLD_CONFIGURE=../js/src/old-configure

build_with_arch()
{

#NDK_ROOT=$HOME/bin/android-ndk
if [[ ! $NDK_ROOT ]]; then
    echo "You have to define NDK_ROOT"
    exit 1
fi

rm -rf dist
rm -f ./config.cache

python ../configure.py \
            --enable-project=js \
            --with-android-ndk=$NDK_ROOT \
            --with-android-sdk=$HOME/bin/android-sdk \
            --with-android-version=${ANDROID_VERSION} \
            --with-android-gnu-compiler-version=${GCC_VERSION} \
            --with-arch=${CPU_ARCH} \
            --with-android-cxx-stl=libstdc++ \
            --target=${TARGET_NAME} \
            --disable-shared-js \
            --disable-tests \
            --enable-strip \
            --enable-install-strip \
            --disable-debug \
            --with-system-zlib \
            --without-intl-api \
            ${EXTRA_ARGS}


make -j8

if [[ $develop ]]; then
    rm ../../../include
    rm ../../../lib

    ln -s -f "$PWD"/dist/include ../../..
    ln -s -f "$PWD"/dist/lib ../../..
fi

if [[ $release ]]; then
# copy specific files from dist
    rm -r "$RELEASE_DIR/$RELEASE_ARCH_DIR"
    mkdir -p "$RELEASE_DIR/$RELEASE_ARCH_DIR"
    mkdir -p "$RELEASE_DIR/$RELEASE_ARCH_DIR/spidermonkey"
    cp -RL dist/include/* "$RELEASE_DIR/$RELEASE_ARCH_DIR/spidermonkey/"
    cp -L js/src/libjs_static.a "$RELEASE_DIR/$RELEASE_ARCH_DIR/libjs_static.a"
    cp -L dist/sdk/lib/libmozglue.a "$RELEASE_DIR/$RELEASE_ARCH_DIR/libmozglue.a"

# strip unneeded symbols
    STRIP=$NDK_ROOT/toolchains/${TOOLS_ARCH}-${GCC_VERSION}/prebuilt/${host_os}-${host_arch}/bin/${TOOLNAME_PREFIX}-strip

    $STRIP --strip-unneeded "$RELEASE_DIR/$RELEASE_ARCH_DIR/libjs_static.a"
    $STRIP --strip-unneeded "$RELEASE_DIR/$RELEASE_ARCH_DIR/libmozglue.a"
fi

}

# Build with armv6
TOOLS_ARCH=arm-linux-androideabi
TARGET_NAME=arm-linux-androideabi
CPU_ARCH=armv6
RELEASE_ARCH_DIR=armeabi
GCC_VERSION=4.9
TOOLNAME_PREFIX=arm-linux-androideabi
ANDROID_VERSION=9
EXTRA_ARGS=--disable-jemalloc
build_with_arch

# Build with armv7
TOOLS_ARCH=arm-linux-androideabi
TARGET_NAME=arm-linux-androideabi
CPU_ARCH=armv7-a
RELEASE_ARCH_DIR=armeabi-v7a
GCC_VERSION=4.9
TOOLNAME_PREFIX=arm-linux-androideabi
ANDROID_VERSION=9
EXTRA_ARGS=--disable-jemalloc
build_with_arch

# Build with arm64
TOOLS_ARCH=aarch64-linux-android
TARGET_NAME=aarch64-linux-android
CPU_ARCH=armv8-a
RELEASE_ARCH_DIR=arm64-v8a
GCC_VERSION=4.9
TOOLNAME_PREFIX=aarch64-linux-android
ANDROID_VERSION=21
EXTRA_ARGS=--disable-jemalloc
build_with_arch

# Build with x86
TOOLS_ARCH=x86
TARGET_NAME=i686-linux-android
CPU_ARCH=i686
RELEASE_ARCH_DIR=x86
GCC_VERSION=4.9
TOOLNAME_PREFIX=i686-linux-android
ANDROID_VERSION=9
EXTRA_ARGS=--disable-jemalloc
build_with_arch
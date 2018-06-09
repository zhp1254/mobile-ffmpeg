#!/bin/bash

if [[ -z ${ARCH} ]]; then
    echo "ARCH not defined"
    exit 1
fi

if [[ -z ${IOS_MIN_VERSION} ]]; then
    echo "IOS_MIN_VERSION not defined"
    exit 1
fi

if [[ -z ${TARGET_SDK} ]]; then
    echo "TARGET_SDK not defined"
    exit 1
fi

if [[ -z ${SDK_PATH} ]]; then
    echo "SDK_PATH not defined"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo "BASEDIR not defined"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/ios-common.sh

# PREPARING PATHS & DEFINING ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="freetype"
set_toolchain_clang_paths ${LIB_NAME}

# PREPARING FLAGS
TARGET_HOST=$(get_target_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

./configure \
    --prefix=${BASEDIR}/prebuilt/ios-$(get_target_host)/${LIB_NAME} \
    --with-pic \
    --with-zlib \
    --with-png \
    --with-sysroot=${SDK_PATH} \
    --without-harfbuzz \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-mmap \
    --host=${TARGET_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_freetype_package_config "22.0.16"

make install || exit 1
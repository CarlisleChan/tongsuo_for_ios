#!/bin/bash
#
# Copyright 2016 leenjewel
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# read -n1 -p "Press any key to continue..."

set -u

source ./build-ios-common.sh

if [ -z ${version+x} ]; then 
  version="8.4.0"
fi

TOOLS_ROOT=$(pwd)

SOURCE="$0"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
pwd_path="$(cd -P "$(dirname "$SOURCE")" && pwd)"

echo pwd_path=${pwd_path}
echo TOOLS_ROOT=${TOOLS_ROOT}

LIB_VERSION="Tongsuo_$(echo $version | sed 's/\./_/g')"
LIB_NAME="tongsuo-$version"
LIB_DEST_DIR="${pwd_path}/../output/ios/tongsuo-universal"

init_log_color

echo "https://mirror.ghproxy.com/https://github.com/Tongsuo-Project/Tongsuo.git"

DEVELOPER=$(xcode-select -print-path)
rm -rf "${LIB_DEST_DIR}" "${LIB_NAME}"
git clone --depth=1 https://mirror.ghproxy.com/https://github.com/Tongsuo-Project/Tongsuo.git ${LIB_NAME}

function configure_make() {

    ARCH=$1
    SDK=$2
    PLATFORM=$3
    SDK_PATH=$(xcrun -sdk ${SDK} --show-sdk-path)

    log_info "configure $ARCH start..."

    pushd .
    cd "${LIB_NAME}"

    PREFIX_DIR="${pwd_path}/../output/ios/tongsuo-${ARCH}"
    if [ -d "${PREFIX_DIR}" ]; then
        rm -fr "${PREFIX_DIR}"
    fi
    mkdir -p "${PREFIX_DIR}"

    OUTPUT_ROOT=${TOOLS_ROOT}/../output/ios/tongsuo-${ARCH}
    mkdir -p ${OUTPUT_ROOT}/log

    set_ios_cpu_feature "tongsuo" "${ARCH}" "${IOS_MIN_TARGET}" "${SDK_PATH}"
    
    ios_printf_global_params "$ARCH" "$SDK" "$PLATFORM" "$PREFIX_DIR" "$OUTPUT_ROOT"

    unset IPHONEOS_DEPLOYMENT_TARGET

    if [[ "${ARCH}" == "x86_64" ]]; then
        ./Configure iphoneos-cross "-arch x86_64" no-shared no-dso no-hw no-engine enable-ntls --prefix="${PREFIX_DIR}"

    elif [[ "${ARCH}" == "armv7" ]]; then
        ./Configure iphoneos-cross no-shared no-dso no-hw no-engine enable-ntls --prefix="${PREFIX_DIR}"
        sed -ie "s!-fno-common!-fno-common -fembed-bitcode !" "Makefile"

    elif [[ "${ARCH}" == "arm64" ]]; then
        ./Configure iphoneos-cross no-shared no-dso no-hw no-engine enable-ntls --prefix="${PREFIX_DIR}"
        sed -ie "s!-fno-common!-fno-common -fembed-bitcode !" "Makefile"

    elif [[ "${ARCH}" == "arm64e" ]]; then
        ./Configure iphoneos-cross no-shared no-dso no-hw no-engine enable-ntls --prefix="${PREFIX_DIR}"
        sed -ie "s!-fno-common!-fno-common -fembed-bitcode !" "Makefile"

    else
        log_error "not support" && exit 1
    fi

    log_info "make $ARCH start..."

    make clean >"${OUTPUT_ROOT}/log/${ARCH}.log"
    if make -j8 >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1; then
        make install_sw >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
        make install_ssldirs >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
    fi

    popd
}

log_info "${PLATFORM_TYPE} ${LIB_NAME} start..."

for ((i = 0; i < ${#ARCHS[@]}; i++)); do
    if [[ $# -eq 0 || "$1" == "${ARCHS[i]}" ]]; then
        configure_make "${ARCHS[i]}" "${SDKS[i]}" "${PLATFORMS[i]}"
    fi
done

log_info "lipo start..."

function lipo_library() {
    LIB_SRC=$1
    LIB_DST=$2
    LIB_PATHS=("${ARCHS[@]/#/${pwd_path}/../output/ios/tongsuo-}")
    LIB_PATHS=("${LIB_PATHS[@]/%//lib/${LIB_SRC}}")
    lipo ${LIB_PATHS[@]} -create -output "${LIB_DST}"
}
mkdir -p "${LIB_DEST_DIR}"
lipo_library "libcrypto.a" "${LIB_DEST_DIR}/libcrypto-universal.a"
lipo_library "libssl.a" "${LIB_DEST_DIR}/libssl-universal.a"

log_info "${PLATFORM_TYPE} ${LIB_NAME} end..."

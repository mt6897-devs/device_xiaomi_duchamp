#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=duchamp
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_FIRMWARE=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-firmware)
            ONLY_FIRMWARE=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup {
    case "$1" in
        system_ext/lib64/libsink.so)
            [ "$2" = "" ] && return 0
            grep -q libshim_sink.so "${2}" || "${PATCHELF}" --add-needed "libshim_sink.so" "$2"
            ;;
        system_ext/lib64/libsource.so|\
        odm/bin/hw/vendor.xiaomi.sensor.citsensorservice.aidl)
            [ "$2" = "" ] && return 0
            grep -q "libui_shim.so" "${2}" || "${PATCHELF}" --add-needed "libui_shim.so" "${2}"
            ;;
        vendor/lib64/c2.dolby.client.so)
            [ "$2" = "" ] && return 0
            grep -q "dolbycodec_shim.so" "${2}" || "${PATCHELF}" --add-needed "dolbycodec_shim.so" "${2}"
	    ;;
        odm/etc/init/vendor.xiaomi.hw.touchfeature-service.rc)
            [ "$2" = "" ] && return 0
            sed -i '/seclabel/d' "${2}"
            ;;
        vendor/lib64/hw/mt6897/android.hardware.camera.provider@2.6-impl-mediatek.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v34.so" "${2}"
            ;;
        vendor/lib*/hw/audio.primary.mediatek.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libalsautils.so" "libalsautils-v34.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

if [ -z "${ONLY_FIRMWARE}" ]; then
    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${SECTION}" ] && [ -f "${MY_DIR}/proprietary-firmware.txt" ]; then
    extract_firmware "${MY_DIR}/proprietary-firmware.txt" "${SRC}"
fi

"${MY_DIR}/setup-makefiles.sh"

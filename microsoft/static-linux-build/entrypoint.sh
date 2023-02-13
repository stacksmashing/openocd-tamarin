#!/bin/sh
# Copyright (c) Microsoft Corporation.
# Licensed under the GPL-2.0-only license.

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

fetch_library() {
    local url_base="${1}"
    local filename="${2}"
    local expected_sha="${3}"

    wget "${url_base}${filename}"
    echo "${expected_sha}  ${filename}" | sha256sum -cw
    if [[ "${filename}" == *.tar.bz2 ]]
    then
        tar -xjf "${filename}"
    elif [[ "${filename}" == *.tar.gz ]]
    then
        tar -xzf "${filename}"
    else
        echo "Unknown archive format." >&2
        return 1
    fi
    rm "${filename}"
}

readonly workspace_dir="${PWD}"
readonly downloads_dir=/downloads
readonly install_dir=/install

apk --no-cache add git gcc g++ patch make libtool pkgconf autoconf automake \
    autoconf-archive linux-headers eudev-dev libftdi1-dev libftdi1-static \
    libusb-compat-dev capstone-dev capstone-static

mkdir -p "${downloads_dir}"
cd "${downloads_dir}"

fetch_library "https://github.com/libusb/libusb/releases/download/v1.0.24/" \
    "libusb-1.0.24.tar.bz2" \
    "7efd2685f7b327326dcfb85cee426d9b871fd70e22caa15bb68d595ce2a2b12a"

fetch_library "https://github.com/libusb/hidapi/archive/refs/tags/" \
    "hidapi-0.10.1.tar.gz" \
    "f71dd8a1f46979c17ee521bc2117573872bbf040f8a4750e492271fc141f2644"

fetch_library "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/" \
    "libgpiod-1.6.3.tar.gz" \
    "eb446070be1444fd7d32d32bbca53c2f3bbb0a21193db86198cf6050b7a28441"

cd "${downloads_dir}/libusb-1.0.24"
./configure --enable-static --disable-shared
make
make install-strip

cd "${downloads_dir}/hidapi-hidapi-0.10.1"
./bootstrap
./configure --enable-static --disable-shared
make
make install-strip

cd "${downloads_dir}/libgpiod-1.6.3"
./autogen.sh --enable-static --disable-shared
make
make install-strip

cd "${workspace_dir}"
# Because of CVE-2022-24765, we have to explictly list the repos in the GitHub
# workspace directory.
git config --global --add safe.directory "${workspace_dir}"
git config --global --add safe.directory "${workspace_dir}/jimtcl"
git config --global --add safe.directory "${workspace_dir}/src/jtag/drivers/libjaylink"
git config --global --add safe.directory "${workspace_dir}/tools/git2cl"
openocd_tag="`git tag --points-at HEAD`"
[ -z "${openocd_tag}" ] && openocd_tag="`git rev-parse --short HEAD`"
readonly openocd_name="openocd-${openocd_tag}-linux"
./bootstrap
./configure --build="$(${workspace_dir}/config.guess)" \
    --prefix="${install_dir}/${openocd_name}" \
    --enable-static --enable-all-static --disable-shared
make
make install-strip
tar -C "${install_dir}" -czf "${workspace_dir}/${openocd_name}.tar.gz" "${openocd_name}"
echo "artifact-name=${openocd_name}.tar.gz" >> $GITHUB_OUTPUT
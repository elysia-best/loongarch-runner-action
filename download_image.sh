#!/bin/bash
set -uo pipefail

case $1 in
    "aosc_os:latest")
        url=https://releases.aosc.io/os-loongarch64/installer/aosc-os_installer_20250414_loongarch64.iso
    ;;    
    "deepin_os:23_1")
        url=https://cdimage.deepin.com/releases/23.1/loongarch64/deepin-desktop-community-23.1-loong64.iso
    ;;
    https:/*|http:/*)
        url="$1"
    ;;
    file:///*|file://localhost/*)
        url="$1"
    ;;
    *)
        echo "Unknown image $1"
        exit 1
    ;;
esac

tempdir=${RUNNER_TEMP:-/home/actions/temp}/loongarch-runner
rm -rf ${tempdir}
mkdir -p ${tempdir}
cd ${tempdir}
case ${url} in
    file://localhost/*)
        cp "${url#file://localhost}" .
    ;;
    file:///*)
        cp "${url#file://}" .
    ;;
    https:/*|http:/*)
        wget --trust-server-names --content-disposition -q ${url}
esac
case `echo *` in
    *.iso)
        xorriso -osirrox on -indev * -extract / ./
        unzip -u *
    ;;    
    *.zip)
        unzip -u *
    ;;
    *.7z)
        7zr e *
    ;;
    *.xz)
        xz -d *
    ;;
    *.gz)
        gzip -d *
    ;;
    *.img)
    ;;
    *.zip\?*)
        unzip -u *
    ;;
    *.7z\?*)
        7zr e *
    ;;
    *.xz\?*)
        xz -d *
    ;;
    *.gz\?*)
        gzip -d *
    ;;
    *)
        echo "Don't know how to uncompress image " *
        exit 1
esac

# Find filesystem.squashfs from extracted livecd
mv "$(ls filesystem.squashfs */filesystem.squashfs 2>/dev/null | head -n 1)" loongarch-runner.squashfs
echo "image=${tempdir}/loongarch-runner.squashfs" >> "$GITHUB_OUTPUT"

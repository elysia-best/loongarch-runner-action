#!/bin/bash
set -uo pipefail

image=$1
use_systemd_nspawn=$2

sync

# Mount the rootfs image
root_fsmount=${RUNNER_TEMP:-/home/actions/temp}/loongarch-runner/mnt
overlayfs_mount=${RUNNER_TEMP:-/home/actions/temp}/loongarch-runner/overlay_mnt
merge_dir=${RUNNER_TEMP:-/home/actions/temp}/loongarch-runner/fs_merge
work_dir=${RUNNER_TEMP:-/home/actions/temp}/loongarch-runner/fs_work
mkdir -p ${root_fsmount}
mkdir -p ${overlayfs_mount}
mkdir -p ${merge_dir}
mkdir -p ${work_dir}
echo "mount=${merge_dir}" >> "$GITHUB_OUTPUT"

[ ! -d "${root_fsmount}" ] && mkdir "${root_fsmount}"
mount -t squashfs -o loop "${image}" "${root_fsmount}"
[ ! -d "${overlayfs_mount}" ] && mkdir "${overlayfs_mount}"
[ ! -d "${merge_dir}" ] && mkdir "${merge_dir}"
[ ! -d "${work_dir}" ] && mkdir "${work_dir}"
mount -t overlay -o lowerdir=${root_fsmount},upperdir=${overlayfs_mount},workdir=${work_dir} overlay ${merge_dir}

# Prep the chroot
if [ "${use_systemd_nspawn}x" = "x" -o "${use_systemd_nspawn}x" = "nox" ]; then
    mount --bind /proc "${merge_dir}/proc"
    mount --bind /sys "${merge_dir}/sys"
    mount --bind /dev "${merge_dir}/dev"
    mount --bind /dev/pts "${merge_dir}/dev/pts"
fi

mv "${merge_dir}/etc/resolv.conf" "${merge_dir}/etc/_resolv.conf"
cp /etc/resolv.conf "${merge_dir}/etc/resolv.conf"

echo `realpath ${merge_dir}`
ls "${merge_dir}"

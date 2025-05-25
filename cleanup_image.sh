#!/bin/bash
set -euxo pipefail

mount=$1
image=$2

[ -e "${mount}/etc/_ld.so.preload" ] && mv "${mount}/etc/_ld.so.preload" "${mount}/etc/ld.so.preload"
[ -e "${mount}/etc/_resolv.conf" ] && mv "${mount}/etc/_resolv.conf" "${mount}/etc/resolv.conf"

[[ -f "${mount}/tmp/commands.sh" ]] && rm "${mount}/tmp/commands.sh"
if [[ -d "${mount}" ]]; then
    for mp in "${mount}/dev/pts" "${mount}/dev" "${mount}/proc" "${mount}/sys" "${mount}/boot" "${mount}" ; do
        mountpoint "${mp}" && {
            retries=0
            force=""
            while ! umount ${force} "${mp}" ; do
                retries=$((retries + 1))
                if [ "${retries}" -ge 10 ]; then
                    echo "Could not unmount ${mp} after ${retries} attempts, giving up."
                    exit 1
                fi
                if [ "${retries}" -eq 5 ]; then
                    force="--force"
                fi
                fuser -ckv "${mp}"
                sleep 1
            done
        }
    done
    rmdir "${mount}" || true
fi
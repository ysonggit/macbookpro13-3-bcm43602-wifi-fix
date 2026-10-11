#!/bin/bash
set -e
D=/lib/firmware/brcm
MODEL=$(cat /sys/class/dmi/id/product_name)
sudo rm -f "$D/brcmfmac43602-pcie.Apple Inc.-$MODEL.txt" "$D/brcmfmac43602-pcie.txt" /etc/modprobe.d/brcmfmac.conf
sudo modprobe -r brcmfmac_wcc 2>/dev/null || true
sudo modprobe -r brcmfmac && sudo modprobe brcmfmac

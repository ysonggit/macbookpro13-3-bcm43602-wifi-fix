#!/bin/bash
# Install BCM43602 NVRAM + driver options for MacBookPro13,x on Linux (brcmfmac)
set -e
cd "$(dirname "$0")"
D=/lib/firmware/brcm
MODEL=$(cat /sys/class/dmi/id/product_name)
sudo install -m644 brcmfmac43602-pcie.txt "$D/brcmfmac43602-pcie.Apple Inc.-$MODEL.txt"
sudo install -m644 brcmfmac43602-pcie.txt "$D/brcmfmac43602-pcie.txt"
sudo install -m644 brcmfmac.conf /etc/modprobe.d/brcmfmac.conf
sudo modprobe -r brcmfmac_wcc 2>/dev/null || true
sudo modprobe -r brcmfmac
sleep 1
sudo modprobe brcmfmac
sleep 6
sudo dmesg | grep -i brcmfmac | tail -8
IF=$(ls /sys/bus/pci/drivers/brcmfmac/*/net 2>/dev/null | head -1)
[ -n "$IF" ] && { nmcli dev wifi rescan ifname "$IF" 2>/dev/null || true; sleep 4; nmcli -f SSID,CHAN,SIGNAL,SECURITY dev wifi list ifname "$IF" | head -15; }

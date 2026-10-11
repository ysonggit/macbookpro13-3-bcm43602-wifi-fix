# Wi-Fi fix for MacBook Pro 13,3 (BCM43602) on Linux

Gets the internal Broadcom BCM43602 Wi-Fi (`14e4:43ba`, Apple subsystem `106b:015a`) working with the in-tree `brcmfmac` driver on a **MacBookPro13,3** (15", late 2016).

## Symptoms

- `wlp3s0` shows up and scans, but sees only a few weak networks and can't see or join a router a few meters away
- MAC address is the generic `00:90:4c:0d:f4:3e`
- `dmesg` shows:
  ```
  Direct firmware load for brcm/brcmfmac43602-pcie.txt failed with error -2
  ```

## Cause

There's no board NVRAM (calibration) file for this card in `linux-firmware`. Without one, the card's front end is driven with the wrong settings, so transmit, especially on 2.4 GHz, barely works.

## Fix

1. Install an NVRAM file, `brcmfmac43602-pcie.txt`. It's based on [attachment 290569](https://bugzilla.kernel.org/attachment.cgi?id=290569) (Andy Holst) from [kernel bug 193121](https://bugzilla.kernel.org/show_bug.cgi?id=193121), plus the one-line `swctrlmap_2g` fix from [comment 97](https://bugzilla.kernel.org/show_bug.cgi?id=193121#c97) (Vincent Tremblay). That comment explains that the 2.4 GHz switch map had been a copy of the 5 GHz one, which set the 5 GHz band-select pin while transmitting on 2.4 GHz:
   ```
   swctrlmap_2g=0x02020202,0x01010101,0x02020202,0x00000000,0x000000ff
   ```
2. Set `options brcmfmac feature_disable=0x82000`, which [Arch forum users](https://bbs.archlinux.org/viewtopic.php?id=302526) reported made the connection more stable.

## Install

```bash
git clone https://github.com/ysonggit/macbookpro13-3-bcm43602-wifi-fix
cd macbookpro13-3-bcm43602-wifi-fix
./install.sh
```

`install.sh` copies the NVRAM file to `/lib/firmware/brcm/` (under both the generic name and the model-specific `brcmfmac43602-pcie.Apple Inc.-<model>.txt` name), installs the modprobe option, reloads the driver and scans. `./uninstall.sh` reverts all of this.

## Tested

| | |
|---|---|
| Machine | MacBookPro13,3 |
| OS | Ubuntu 22.04.5, kernel 6.8.0-138-generic |
| Firmware | BCM43602/2 7.35.177.61 (stock `brcmfmac43602-pcie.bin`) |
| Result | Both bands visible. Connected on 5 GHz (ch 56, WPA2/WPA3 router) at 270 Mbit/s link rate; ping ~4 ms, 0% loss |

The file should also work on the 13,1, 13,2 and 14,x models with the same chip, but the front-end wiring may differ between models. This has only been tested on the 13,3 above.

## If the connection is still flaky

- Cap the transmit power: `sudo iw dev wlp3s0 set txpower fixed 1000`
- Try `boardflags3=0x00000003` in the NVRAM file (see comment 96 on the bug), then reload with `sudo modprobe -r brcmfmac && sudo modprobe brcmfmac`

## Credits

The NVRAM work comes from the people on [kernel bug 193121](https://bugzilla.kernel.org/show_bug.cgi?id=193121): Andy Holst, sonal.santan (NVRAM capture from Windows) and Vincent Tremblay (`swctrlmap_2g` fix).

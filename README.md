# OpenCore EFI — Infinix XBOOK 15 BL51A5

**English** | [Bahasa Indonesia](README_ID.md)

OpenCore EFI for the **Infinix XBOOK 15 BL51A5**, powered by an AMD Ryzen 7 5825U and Radeon Vega 8 integrated graphics.

This snapshot was exported from the daily-use EFI on **August 14, 2026**. It is stable for everyday use on macOS Tahoe 26.5; the main remaining limitation is occasional visual artifacting in Electron/Chromium applications. All SMBIOS identifiers in this public repository have been replaced with placeholders.

![macOS Tahoe 26.5 running on the Infinix XBOOK 15 BL51A5](docs/images/tahoe-26.5-about.png)

## macOS support

| Version | Status | Notes |
|---|---|---|
| macOS Tahoe 26.5 | ✅ Directly tested | Primary system when this snapshot was created |
| macOS Sequoia 15.7 | ✅ Previously tested | Uses the same ACPI, kernel patches, and kext order; make a backup before switching versions |
| Sonoma and older | ⚠️ Not a snapshot target | May boot, but has not been tested with this configuration |

This OpenCore configuration is not locked specifically to Tahoe. Its AMD kernel patches, ACPI tables, and primary kexts can be used on both **Tahoe and Sequoia**. However, macOS and kext updates may still affect compatibility.

## Hardware

| Component | Details |
|---|---|
| Model | Infinix XBOOK 15 / BL51A5 |
| Motherboard | `EM_AB336_MB_CY_V1.0` |
| Tested BIOS | `BL51A5_AB336_XBOOK15_V1.10` |
| CPU | AMD Ryzen 7 5825U, 8 cores / 16 threads |
| iGPU | AMD Radeon Vega 8 / Barcelo, `1002:15e7` |
| Tested memory | 16 GB DDR4-3200 |
| Storage | NVMe SSD |
| Wi-Fi | Realtek RTL8821CE PCIe, `10ec:c821` |
| Bluetooth | Realtek RTL8821C USB, `0bda:c821` |
| Ethernet | Realtek RTL8111/8168 |
| Audio | Realtek ALC269VC, layout-id 55 |
| Trackpad | I2C HID through VoodooI2C/VoodooI2CHID |
| SMBIOS | MacBookPro16,2 |

## Feature status

| Feature | Status | Notes |
|---|---|---|
| OpenCore picker and macOS boot | ✅ Working | Tahoe 26.5 tested as the primary system |
| CPU 8C/16T | ✅ Working | AMD kernel patches + ForgedInvariant |
| CPU power management | ✅ Working | AMDRyzenCPUPowerManagement, SMCAMDProcessor, and SSDT-CPUR |
| Vega 8 iGPU + Metal | ✅ Stable for daily use | NootedRed provides acceleration; occasional artifacts may still appear in Electron/Chromium applications |
| Internal display | ✅ Working | Includes backlight control |
| Keyboard | ✅ Working | VoodooPS2Controller |
| I2C trackpad | ✅ Working | VoodooI2C + VoodooI2CHID; individual gestures may vary |
| Brightness keys | ✅ Working | BrightnessKeys |
| Battery status | ✅ Working | SMCBatteryManager |
| NVMe | ✅ Working | NVMeFix enabled |
| Ethernet | ✅ Driver active | RealtekRTL8111 |
| RTL8821CE Wi-Fi | ✅ Working through Starskiff | Does not appear as native AirPort/CoreWLAN Wi-Fi |
| Wi-Fi in System Settings | ❌ Not working | `rtw88` publishes an Ethernet-type interface; use Starskiff |
| Realtek Bluetooth | ✅ Working on the tested unit | RealtekBluetoothFirmware + BlueToolFixup |
| Full AirDrop / AWDL / Continuity | ❌ Not working | RTL8821CE is not an AirPort card and its driver does not provide AWDL |
| Audio | ✅ Working | AppleALC after NootedRed, layout-id 55 |
| Sleep/wake | ✅ Working on the tested unit | Retest after changing the USB map, Bluetooth stack, or macOS version |
| DRM / protected streaming content | ⚠️ Not guaranteed | `unfairgva=1` was intentionally removed because it did not prevent GPU resets |

## NootedRed graphics limitations

This EFI uses a **NootedRed 0.9.0 RELEASE artifact** built on August 1, 2026 with the macOS 26.5 SDK. The binary is identical to the one used by the stable August 14 snapshot and performs better than 0.8.10 on the tested unit, but it does not eliminate every graphics issue.

Symptoms previously confirmed on older builds through `.gpuRestart` reports:

- Safari/WebKit could stutter or reset during video playback.
- App Store and `mediaanalysisd` could trigger resets in the `VTMTSComputeFunction` shader.
- Increasing UMA from 512 MB to 1 GB provided more graphics memory but did not solve the driver bug.

With the current snapshot, Safari, App Store, and other daily-use features are stable on the tested unit. The remaining observed issue is occasional artifacting in Chromium/Electron applications such as Discord, Spotify, Termius, and Brave while hardware acceleration is enabled.

Daily-use workarounds:

- Launch affected Electron applications with `--disable-gpu`.
- Disable graphics acceleration in browsers when stability matters more than performance.
- Use a solid-color wallpaper if dynamic wallpapers trigger resets.
- Run `Extras/fix-nootedred.sh` after a fresh installation if the desktop or login screen hangs.
- With 16 GB of RAM, a 2 GB UMA allocation can be used. Choose 1 GB if you prefer to leave more memory available to macOS.

Snapshot boot arguments:

```text
revcpu=1 -NRedDPDelay
```

`unfairgva=1` was removed after testing because it did not resolve video issues or GPU resets.

## Wi-Fi and Bluetooth

RTL8821CE is not recognized as native Wi-Fi by CoreWLAN. The `rtw88.kext` driver creates an Ethernet-type `en0` interface, while **Starskiff** communicates directly with the driver's user client.

Components:

| Role | Component |
|---|---|
| Wi-Fi driver | `rtw88.kext` |
| Wi-Fi UI | Starskiff |
| Bluetooth firmware | `RealtekBluetoothFirmware.kext` |
| Bluetooth patch for Monterey and newer | `BlueToolFixup.kext` |

After installation:

1. Install Starskiff from `Extras/Starskiff-v1.0.0.dmg`, or use a newer release.
2. Add Starskiff to **System Settings → General → Login Items**.
3. Connect to Wi-Fi through the Starskiff menu-bar icon instead of Apple's Wi-Fi menu.

AirDrop cannot be enabled through configuration changes alone. It requires hardware and a driver with AWDL support.

## BIOS

Use the following settings:

| Setting | Value |
|---|---|
| Secure Boot | Disabled |
| Fast Boot | Disabled |
| CSM | Disabled |
| IOMMU | Disabled |
| Above 4G Decoding | Enabled |
| UMA Frame Buffer | 1 GB or 2 GB with 16 GB RAM; this snapshot was tested with 2 GB |

Do not change unfamiliar engineering or advanced BIOS options. Back up the BIOS settings and EFI before experimenting.

## Before use: generate your own SMBIOS

This public repository **does not contain the machine's real identity**. The following values are placeholders:

| Field | Placeholder |
|---|---|
| SystemSerialNumber | `XXXXXXXXXXXX` |
| MLB | `M0000000000000001` |
| SystemUUID | `00000000-0000-0000-0000-000000000000` |
| ROM | `11:22:33:44:55:66` |

Generate unique values with GenSMBIOS/macserial before signing in to iCloud. Never reuse a serial number from someone else's repository, and never commit your machine's real identifiers.

## Quick installation

1. Download or clone this repository.
2. Generate unique SMBIOS values and enter them in `EFI/OC/config.plist`.
3. Copy the `EFI` directory to a USB drive's EFI partition for testing.
4. Boot from the USB drive first.
5. After verifying that all essential devices work, back up the old EFI and copy this EFI to the internal EFI partition.
6. Reset NVRAM only when required after significant configuration changes.

For a fresh installation that hangs or displays a gray screen, run:

```bash
bash Extras/fix-nootedred.sh "Macintosh HD"
```

Adjust the target volume name as needed. The script should be run from Recovery.

## Main snapshot components

| Component | Version |
|---|---|
| NootedRed | 0.9.0 RELEASE artifact, August 1, 2026 build (macOS 26.5 SDK) |
| Lilu | 1.7.2 |
| VirtualSMC | 1.3.7 |
| AppleALC | 1.9.7 |
| RestrictEvents | 1.1.6 |
| RealtekRTL8111 | 3.0.4 |
| rtw88 | 1.0.1 |
| VoodooI2C | 2.9.1 |
| VoodooPS2Controller | 2.3.7 |
| AMDRyzenCPUPowerManagement | 0.7.2 |

NootedRed must load **before AppleALC**. One VoodooInput instance from VoodooI2C is used; the VoodooInput, Mouse, and Trackpad plugins bundled with VoodooPS2 are disabled to avoid conflicts.

## Repository structure

```text
.
├── EFI
│   ├── BOOT
│   └── OC
│       ├── ACPI
│       ├── Drivers
│       ├── Kexts
│       ├── Resources
│       ├── config.plist
│       └── OpenCore.efi
├── Extras
├── README.md
├── README_ID.md
├── SMBIOS.txt
└── SOURCES.txt
```

Backup and debug files from the daily EFI are intentionally excluded.

## Sources and credits

- [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg)
- [NootedRed](https://github.com/ChefKissInc/NootedRed)
- [AMD Vanilla](https://github.com/AMD-OSX/AMD_Vanilla)
- [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C)
- FeiXiao/rtw88, Starskiff, and RealtekBluetoothFirmware
- Acidanthera, ChefKissInc, AMD-OSX, Mieze, and the Hackintosh community

## Disclaimer

Hackintosh systems are not supported by Apple. Updating macOS, the BIOS, OpenCore, or any kext may cause boot failures, kernel panics, loss of graphics acceleration, or data loss. Always keep a bootable EFI backup and a current data backup before making changes.

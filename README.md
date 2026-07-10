# OpenCore EFI — Infinix XBOOK 15 (BL51A5)

OpenCore config for **Infinix BL51A5** (`BL51A5_NS15AB`), based on:

| Referensi | Dipakai untuk |
|-----------|----------------|
| [kodeaqua/opencore-infinix-xbook-b15](https://github.com/kodeaqua/opencore-infinix-xbook-b15) | **Base config** (OpenCore 1.0.6, drivers, kexts, ACPI, touchpad, USB, audio, boot-args recovery) |
| [kodeaqua/opencore-axioo-hype7-amd-x7-2](https://github.com/kodeaqua/opencore-axioo-hype7-amd-x7-2) | Hanya **CPU 5825U**: kernel patch 8-core, **`rtw88`**, **RealtekBluetoothFirmware** |
| [thegwchr/Feixiao](https://github.com/thegwchr/Feixiao) + [Starskiff](https://github.com/thegwchr/Starskiff) | Wi-Fi RTL8821CE |
| [thegwchr/RealtekBluetoothFirmware](https://github.com/thegwchr/RealtekBluetoothFirmware) | Bluetooth RTL8821C (`0bda:c821`) |

> **Bukan** EFI copy-paste full dari satu repo. Hybrid: **chassis = B15**, **CPU/wireless = Axioo**.  
> **Tested on BL51A5:** Sequoia **15.7** — recovery boot, UnPlugged offline install, desktop, Wi-Fi (Starskiff), Ethernet, NootedRed post-install fix.  
> Recovery default: **Sequoia** (`OC-ESP` + `com.apple.recovery.boot`). Backup Sonoma: tag `sonoma-recovery-working`.

---

## Hardware target (dari dump Linux)

| Komponen | Detail |
|----------|--------|
| Model | Infinix **BL51A5** (XBOOK15) |
| Board | `EM_AB336_MB_CY_V1.0` |
| BIOS | `BL51A5_AB336_XBOOK15_V1.10` |
| CPU | AMD **Ryzen 7 5825U** (8C/16T, Zen 3 / Cezanne) |
| iGPU | AMD Radeon **Barcelo** (`1002:15e7`) |
| Wi-Fi | Realtek **RTL8821CE** PCIe (`10ec:c821`) |
| Bluetooth | Realtek USB **`0bda:c821`** (HCI 4.2 / RTL8821C) |
| Ethernet | Realtek **RTL8111/8168** (`10ec:8168`) |
| Audio | Realtek **ALC269VC** (`10ec:0269`) |
| Trackpad | I2C HID `36B6:C001` (`PNP0C50`) |
| Storage | NVMe (MAXIO MAP1202 di unit ini) |
| SMBIOS | **MacBookPro16,2** (placeholder) |

---

## Apa yang diubah dari referensi

1. **Base B15** — Config.plist, OpenCore 1.0.6, drivers (`OpenHfsPlus` …), kext stack, ACPI (kecuali PLUG 8-core).
2. **Dari Axioo** — kernel patch **8-core**, `rtw88.kext`, `RealtekBluetoothFirmware` (ganti Brcm B15).
3. **boot-args (tested Sequoia)**: `unfairgva=1` saja. Recovery verbose: tambah `-v` sementara. **Jangan** sekaligus pasang `npci=0x3000 alcid=55 revpatch=auto,sbvmm` — bikin **boot hang** di BL51A5 (sama seperti recovery dulu).
4. **Touchpad & USB = pola B15 (Infinix)**, bukan Axioo:
   - **Touchpad**: `VoodooI2C` + `VoodooInput` (dari I2C) + `VoodooI2CHID` + `VoodooSMBus`; PS2 keyboard/mouse/trackpad plugins seperti B15; `VoodooInput` di PS2 **dimatikan** (hindari double-load).
   - **USB**: **tanpa** `USBToolBox` / `UTBMap` (map Axioo salah mesin). Pakai **SSDT-USBX + SSDT-USB-Reset + SSDT-EC + SSDT-XOSI dari B15** — sama pendekatan Infinix XBOOK.
5. **RealtekRTL8111.kext v3.0.0** ([Mieze](https://github.com/Mieze/RTL8111_driver_for_OS_X/releases)) — `enableEEE=false`, `fallbackMAC` dari LAN.
6. **Audio ALC269VC**: layout-id **55** via DeviceProperties (B15).
7. **RealtekBluetoothFirmware**: personality **`0bda:c821`** ditambahkan.
8. SMBIOS **MacBookPro16,2** sudah di-generate (macserial) + ROM dari MAC Wi‑Fi laptop ini. Lihat `SMBIOS.txt`.

---

## Isi folder

```
opencore-infinix-bl51a5/
├── EFI/OC/                 # bootloader
│   ├── ACPI/
│   ├── Drivers/
│   ├── Kexts/
│   ├── Resources/
│   ├── Config.plist
│   └── OpenCore.efi
├── Extras/
│   ├── Starskiff-v1.0.0.dmg   # UI Wi-Fi (post-install)
│   └── fix-nootedred.sh       # mandatory NootedRed fix (Recovery / post-install)
└── README.md
```

### Stack wireless (penting)

| Role | Kext / app |
|------|------------|
| Wi-Fi driver | `rtw88.kext` (Feixiao) |
| Wi-Fi UI | **Starskiff.app** (bukan System Settings native) |
| BT firmware | `RealtekBluetoothFirmware.kext` |
| BT Monterey+ | `BlueToolFixup.kext` |
| Dependency | `Lilu.kext` |

---

## BIOS (wajib)

Seperti referensi Infinix/AMD laptop. **Jangan main engineer-level BIOS** (risiko brick di XBOOK).

- Secure Boot → **Disabled**
- Fast Boot → **Disabled**
- CSM → **Disabled**
- IOMMU → **Disabled** (kalau ada)
- Above 4G Decoding → **Enabled** (kalau ada)
- UMA / iGPU memory → **Game Optimized / 1G** (sesuaikan opsi BIOS)
- VT-d / SVM: biarkan default yang stabil; dual boot Linux/Windows sering butuh SVM on

---

## Install singkat

### 1) SMBIOS (sudah diisi)

`Config.plist` → `PlatformInfo` → `Generic` sudah di-set:

| Field | Value |
|-------|--------|
| Model | `MacBookPro16,2` |
| Serial / MLB / UUID | lihat `SMBIOS.txt` (juga di Config) |
| ROM | MAC Wi‑Fi laptop ini (`8c:ea:12:c1:43:20`) |

**Jangan** pakai serial ini di mesin lain. Kalau repo publik di-clone orang lain dan mereka pakai serial yang sama, iMessage/iCloud bisa bermasalah — regenerate:

```bash
macserial -m MacBookPro16,2
# isi ulang SystemSerialNumber + MLB di Config.plist; UUID pakai uuidgen
```

### 2) Install macOS Sequoia

**Opsi A — USB installer**

1. Buat USB install macOS Sequoia.
2. Mount EFI USB, copy folder `EFI/` ke root EFI partition.
3. Boot USB lewat OpenCore picker.
4. Install ke internal disk (dual-boot: jangan timpa Linux tanpa backup).

**Opsi B — UnPlugged offline (tested BL51A5)**

1. Siapkan partisi exFAT ~20GB (`InstallPayload`) berisi `InstallAssistant.pkg`, `UnPlugged.command`, `BaseSystem.dmg`, `fix-nootedred.sh`.
2. Boot OpenCore → Sequoia Recovery.
3. Erase APFS partition → `Macintosh HD`.
4. Mount exFAT manual (`mount_exfat`) — Sequoia recovery **tidak** auto-mount exFAT.
5. `bash UnPlugged.command` → install offline ke `Macintosh HD`.
6. **Sebelum boot desktop:** jalankan `fix-nootedred.sh` (lihat post-install §A).

### 3) Copy EFI ke internal

Setelah install, mount EFI internal, copy `EFI/` yang sama (dengan SMBIOS yang sudah diganti).

### 4) Post-install (mandatory — tested Sequoia 15.7)

#### Disk layout (dual-boot BL51A5)

| Partisi | Size | Isi |
|---------|------|-----|
| p1 `OC-ESP` | 1.5G | OpenCore + `com.apple.recovery.boot` (Sequoia recovery) |
| p2 `macOS` | ~248G | APFS — target install (`Macintosh HD`) |
| p3 `InstallPayload` | 20G | exFAT — offline installer + `fix-nootedred.sh` + Starskiff (opsional) |
| p4 | 4.9G | Linux `/boot` |
| p5 | ~201G | CachyOS root |

Copy `Extras/fix-nootedred.sh` dan `Extras/Starskiff-v1.0.0.dmg` ke partisi **InstallPayload** supaya bisa diakses dari macOS Recovery / desktop.

---

#### A. NootedRed — gray screen, About, wallpaper (WAJIB tiap fresh install)

Bug NootedRed di Sonoma/Sequoia: GPU compute hang (wallpaper decode, login, System Settings → About).

**Workaround resmi:** [NootedRed #235](https://github.com/ChefKissInc/NootedRed/issues/235#issuecomment-4567109847) · [discussion #430](https://github.com/ChefKissInc/NootedRed/discussions/430)

**Dari Recovery** (setelah install / reinstall, sebelum boot desktop):

```bash
# Mount InstallPayload (Sequoia+ tidak auto-mount exFAT)
diskutil list physical
mkdir -p /Volumes/UnPlugged
/sbin/mount_exfat /dev/disk0s3 /Volumes/UnPlugged   # sesuaikan disk0s3

bash /Volumes/UnPlugged/fix-nootedred.sh "Macintosh HD"
reboot
```

Atau manual:

```bash
defaults write "/Volumes/Macintosh HD/Library/Preferences/com.apple.coremedia" allowMetalTransferSession -bool NO
chmod 644 "/Volumes/Macintosh HD/Library/Preferences/com.apple.coremedia.plist"
```

**Dari Linux (CachyOS)** — kalau sudah boot Linux, bisa apply tanpa Recovery:

```bash
sudo modprobe apfs
sudo mount -t apfs -o vol=0 /dev/nvme0n1p2 /mnt/macos-p2
sudo tee /mnt/macos-p2/Library/Preferences/com.apple.coremedia.plist > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>allowMetalTransferSession</key><false/></dict></plist>
EOF
sudo chmod 644 /mnt/macos-p2/Library/Preferences/com.apple.coremedia.plist
sudo umount /mnt/macos-p2
```

**Wallpaper (penting — tested):**

| Wallpaper | Hasil di NootedRed + Sequoia |
|-----------|------------------------------|
| **Color** (solid) | ✅ Aman — About tampil, boot normal |
| **Pictures** / dynamic (`.mov`, Sequoia Sunrise, dll.) | ❌ `gpuRestart`, About hilang/crash setelah reboot |
| Memoji avatar | ❌ Hindari |

`fix-nootedred.sh` juga reset wallpaper user ke **Color**. Setelah fix, **jangan** ganti ke Pictures/dynamic.

---

#### B. Wi-Fi — install Starskiff

RTL8821CE bukan chip Apple — menu Wi-Fi native **tidak jalan**. Driver `rtw88.kext` sudah di EFI.

```text
Extras/Starskiff-v1.0.0.dmg  (atau dari /Volumes/UnPlugged/)
→ drag Starskiff.app ke Applications
→ System Settings → General → Login Items → Open at Login
→ connect SSID lewat app Starskiff (bukan menu Wi-Fi Apple)
```

Mount InstallPayload dari macOS desktop:

```bash
sudo mkdir -p /Volumes/UnPlugged
sudo /sbin/mount_exfat /dev/disk0s3 /Volumes/UnPlugged
open /Volumes/UnPlugged/Starskiff-v1.0.0.dmg
```

Verifikasi driver:

```bash
kextstat | grep -i rtw
```

---

#### C. Ethernet

`RealtekRTL8111.kext` **v3.0.0** sudah di EFI. Port biasanya **en1** (Wi-Fi Starskiff = en0).

```bash
kextstat | grep -i realtek
networksetup -listallhardwareports
sudo networksetup -setdhcp Ethernet
```

---

#### D. Bluetooth

```bash
log show --last boot --predicate 'eventMessage CONTAINS "RealtekFirmware"'
```

Harus kelihatan match chip + `firmware download complete`.

---

#### E. Audio layout

Default: `layout-id` **55** di DeviceProperties. Kalau speaker/mic salah, coba `alcid=` satu per satu (jangan batch dengan npci/revpatch):

`11`, `13`, `28`, `33`, `55`, `66`, `99` — samakan dengan `DeviceProperties` → `layout-id`, reboot tiap percobaan.

---

#### F. Boot-args lanjutan (hati-hati)

Config default: `unfairgva=1` — **tested boot OK** di Sequoia.

Referensi Axioo memakai `npci=0x3000 alcid=55 revpatch=auto,sbvmm` — di **BL51A5 ini menyebabkan boot hang** kalau dipasang sekaligus. Kalau mau eksperimen, tambah **satu argumen per reboot**, bukan sekaligus.

---

#### G. USB

Default mengikuti **B15**: SSDT power/reset saja, semua port native (tidak ada UTBMap Axioo).

Kalau setelah stabil ingin map ketat: [USBToolBox](https://github.com/USBToolBox/tool) → map **khusus BL51A5**. BT (`0bda:c821`) & webcam (`1bcf:2864`) harus enabled.

---

#### H. Lain

```bash
sudo systemsetup -settimezone Asia/Jakarta
```

---

## Yang diharapkan jalan / tidak

| Fitur | Ekspektasi |
|-------|------------|
| Boot + install | Ya (uji USB dulu) |
| iGPU (NootedRed) | Ya, dengan post-install fix |
| Keyboard / trackpad I2C | Ya (VoodooPS2 + VoodooI2C/HID) |
| Ethernet | Ya (RTL8111) |
| Wi-Fi 8821CE | Ya lewat Feixiao + Starskiff (non-Airport) |
| Bluetooth 8821C | Ya lewat RealtekBluetoothFirmware (+ map USB) |
| Audio ALC269VC | Ya dengan layout tuning |
| Battery / sleep | Biasanya ok; perlu fine-tune |
| Continuity / AirDrop native | **Jangan harap penuh** (Realtek non-native) |
| Touchpad perfect | Bisa flaky (sama referensi Axioo) |

---

## Kext order (sudah di-set)

```
Lilu
VirtualSMC → AMDRyzenCPUPowerManagement → SMCAMDProcessor → sensors/battery
NootedRed
AppleALC
RealtekRTL8111
rtw88
BlueToolFixup → RealtekBluetoothFirmware
VoodooPS2Controller (+ Keyboard, Mouse, Trackpad; Input OFF)
VoodooI2C (+ GPIO, Services, Input) → VoodooI2CHID → VoodooSMBus   # B15 style
NVMeFix, RestrictEvents, ECEnabler, BrightnessKeys, ...
```

---

## Troubleshooting cepat

| Gejala | Fix (tested Sequoia) |
|--------|----------------------|
| Gray screen + beachball (first boot) | Jalankan `Extras/fix-nootedred.sh` dari Recovery — **wajib tiap reinstall** |
| About This Mac / System Settings → About hilang | Sama: NootedRed fix + wallpaper **Color** saja (bukan Pictures/dynamic) |
| About hilang setelah ganti wallpaper + reboot | Reset ke Color: `fix-nootedred.sh` atau hapus `SystemWallpaperURL` di `com.apple.wallpaper.plist` |
| Boot hang setelah ubah boot-args | Revert ke `unfairgva=1` saja → **Reset NVRAM** di OpenCore picker → boot lagi |
| Wi-Fi kosong di Starskiff | `kextstat \| grep rtw`; boot lewat OpenCore (bukan direct) |
| Ethernet no IP | Cek **en1** (bukan en0); `networksetup -setdhcp Ethernet` |
| BT hilang | Log `RealtekFirmware`; personality `0bda:c821` |
| No audio | Ganti `layout-id` / `alcid` satu per satu |
| KP sleep | Disable SMCLightSensor sementara; cek USB map |

Verbose boot: OpenCore picker → `Space` → verbose, atau tambah `-v` di boot-args sementara (recovery only).

---

## Dual-boot (Linux sudah ada)

- OpenCore di EFI **terpisah** atau rantai-boot hati-hati.
- Backup partisi EFI sekarang (`efibootmgr` / copy full EFI) sebelum timpa.
- Jangan `rm -rf` EFI Windows/Linux.

---

## Disclaimer

- Risiko brick BIOS / data loss ada di pihak user.
- Jangan jadikan macOS OS utama di laptop ini (saran author B15 tetap valid).
- Kext experimental (Feixiao, RealtekBT, NootedRed CI builds).
- SMBIOS di config **sudah di-generate untuk laptop ini**; jangan share/reuse di PC lain.

---

## Credits

- Acidanthera (OpenCore, Lilu, VirtualSMC, AppleALC, …)
- ChefKissInc / NootedRed
- AMD-OSX / algrey patches
- kodeaqua (Axioo Hype 7 + Infinix B15 EFI)
- thegwchr (Feixiao, Starskiff, RealtekBluetoothFirmware)
- Mieze (RealtekRTL8111)
- VoodooI2C team
- Dortania OpenCore Install Guide

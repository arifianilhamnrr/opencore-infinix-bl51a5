# OpenCore EFI — Infinix XBOOK 15 (BL51A5)

OpenCore config for **Infinix BL51A5** (`BL51A5_NS15AB`), based on:

| Referensi | Dipakai untuk |
|-----------|----------------|
| [kodeaqua/opencore-infinix-xbook-b15](https://github.com/kodeaqua/opencore-infinix-xbook-b15) | **Base config** (OpenCore 1.0.6, drivers, kexts, ACPI, touchpad, USB, audio, boot-args recovery) |
| [kodeaqua/opencore-axioo-hype7-amd-x7-2](https://github.com/kodeaqua/opencore-axioo-hype7-amd-x7-2) | Hanya **CPU 5825U**: kernel patch 8-core, **`rtw88`**, **RealtekBluetoothFirmware** |
| [thegwchr/Feixiao](https://github.com/thegwchr/Feixiao) + [Starskiff](https://github.com/thegwchr/Starskiff) | Wi-Fi RTL8821CE |
| [thegwchr/RealtekBluetoothFirmware](https://github.com/thegwchr/RealtekBluetoothFirmware) | Bluetooth RTL8821C (`0bda:c821`) |

> **Bukan** EFI copy-paste full dari satu repo. Hybrid: **chassis = B15**, **CPU/wireless = Axioo**.  
> **Recovery boot** ditest di BL51A5 (partisi `OC-ESP` + `com.apple.recovery.boot`). Default: **Sequoia**. Backup Sonoma: tag `sonoma-recovery-working`.

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
3. **boot-args recovery**: `unfairgva=1 -v` (B15). Setelah install tambah `npci=0x3000 alcid=55 revpatch=auto,sbvmm`.
4. **Touchpad & USB = pola B15 (Infinix)**, bukan Axioo:
   - **Touchpad**: `VoodooI2C` + `VoodooInput` (dari I2C) + `VoodooI2CHID` + `VoodooSMBus`; PS2 keyboard/mouse/trackpad plugins seperti B15; `VoodooInput` di PS2 **dimatikan** (hindari double-load).
   - **USB**: **tanpa** `USBToolBox` / `UTBMap` (map Axioo salah mesin). Pakai **SSDT-USBX + SSDT-USB-Reset + SSDT-EC + SSDT-XOSI dari B15** — sama pendekatan Infinix XBOOK.
5. **+ RealtekRTL8111.kext** dari B15 (LAN).
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
│   └── Starskiff-v1.0.0.dmg   # UI Wi-Fi (post-install)
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

### 2) USB installer

1. Buat USB install macOS (Sequoia disarankan — target referensi Axioo).
2. Mount EFI partition USB, copy folder `EFI/` ke root EFI partition.
3. Boot USB lewat OpenCore picker.
4. Install ke internal disk (dual-boot: jangan timpa Windows/Linux tanpa backup).

### 3) Copy EFI ke internal

Setelah install, mount EFI internal, copy `EFI/` yang sama (dengan SMBIOS yang sudah diganti).

### 4) Post-install (mandatory)

**A. NootedRed gray screen / beachball**  
Ikuti workaround dari Axioo README:

- [NootedRed discussion #430](https://github.com/ChefKissInc/NootedRed/discussions/430)
- atau [issue comment](https://github.com/ChefKissInc/NootedRed/issues/235#issuecomment-4567109847)

**B. Wi-Fi — install Starskiff**

```text
Extras/Starskiff-v1.0.0.dmg
→ install Starskiff.app
→ Settings → General → Login Items → Open at Login
```

Connect SSID lewat **Starskiff**, bukan cuma Wi-Fi menu Apple (driver non-native).

**C. Bluetooth**

Cek log firmware:

```bash
log show --last boot --predicate 'eventMessage CONTAINS "RealtekFirmware"'
```

Harus kelihatan match chip + `firmware download complete`.

**D. Audio layout**

Kalau speaker/mic salah:

1. Ganti `alcid=` di boot-args: coba `11`, `13`, `28`, `33`, `55`, `66`, `99` (umum ALC269).
2. Samakan `DeviceProperties` → `layout-id` dengan angka yang sama.
3. Reboot tiap percobaan.

**E. USB**

Default mengikuti **B15**: SSDT power/reset saja, semua port native (tidak ada UTBMap Axioo).

Kalau setelah stabil ingin map ketat (power/sleep lebih rapi):

1. Pakai [USBToolBox](https://github.com/USBToolBox/tool) di Windows/macOS → buat map **khusus BL51A5**.
2. Jangan pakai `UTBMap` dari Axioo/B15 orang lain.
3. BT (`0bda:c821`) & webcam (`1bcf:2864`) harus tetap enabled di map.

**F. Lain**

```bash
sudo systemsetup -settimezone Asia/Jakarta
# Hackintool → Power → icon screwdriver (fix power defaults) — opsional
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

| Gejala | Coba |
|--------|------|
| Stuck gray + beachball | NootedRed workaround (atas) |
| Wi-Fi kosong di Starskiff | Cek `rtw88.kext` loaded; `dmesg` / log `rtw88` |
| BT hilang | USB map; log `RealtekFirmware`; pastikan personality `c821` |
| No audio | Ganti `alcid` / layout-id |
| KP sleep | Disable SMCLightSensor sementara; cek USB map |
| Ethernet down | Pastikan `RealtekRTL8111` enabled |

Verbose boot: di OpenCore picker, tekan `Space` → pilih verbose, atau tambah `-v` di boot-args sementara.

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

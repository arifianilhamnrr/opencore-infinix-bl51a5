# OpenCore EFI — Infinix XBOOK 15 BL51A5

[English](README.md) | **Bahasa Indonesia**

OpenCore EFI untuk **Infinix XBOOK 15 BL51A5** dengan AMD Ryzen 7 5825U dan iGPU Radeon Vega 8.

Snapshot ini diekspor dari EFI aktif pada **4 Oktober 2026** dan ditujukan untuk **macOS Sonoma 14.8.9 (23J631)**.

![macOS Sonoma 14.8.9 Wi-Fi dan throughput jaringan pada Infinix XBOOK 15 BL51A5](docs/images/sonoma-14.8-wifi-speedtest.png)

![Instalasi macOS Tahoe sebelumnya pada Infinix XBOOK 15 BL51A5](docs/images/tahoe-26.5-about.png)

## Dukungan macOS

| Versi | Status | Catatan |
|---|---|---|
| macOS Sonoma 14.8.9 | ✅ Diuji langsung | Target utama snapshot ini |
| macOS Tahoe 26.5 | ✅ Pernah diuji | Snapshot repo sebelumnya memakai FeiXiao `rtw88` + Starskiff |
| macOS Sequoia 15.7 | ✅ Pernah diuji | Backup EFI sebelum berpindah versi |

Snapshot ini menyertakan Legacy IO80211 stack Sonoma untuk AirPortRTW. Jangan menganggap konfigurasi Wi-Fi yang sama cocok untuk macOS lebih baru tanpa mengujinya dari USB EFI terlebih dahulu.

## Hardware

| Komponen | Detail |
|---|---|
| Model | Infinix XBOOK 15 / BL51A5 |
| Motherboard | `EM_AB336_MB_CY_V1.0` |
| BIOS teruji | `BL51A5_AB336_XBOOK15_V1.10` |
| CPU | AMD Ryzen 7 5825U, 8 core / 16 thread |
| iGPU | AMD Radeon Vega 8 / Barcelo, `1002:15e7` |
| RAM saat pengujian | 16 GB DDR4-3200 |
| Storage | NVMe SSD |
| Wi-Fi | Realtek RTL8821CE PCIe, `10ec:c821` |
| Bluetooth | Realtek RTL8821C USB, `0bda:c821` |
| Ethernet | Realtek RTL8111/8168 |
| Audio | Realtek ALC269VC, layout-id 55 |
| Trackpad | I2C HID melalui VoodooI2C/VoodooI2CHID |
| SMBIOS | MacBookPro16,2 |

## Status fitur

| Fitur | Status | Catatan |
|---|---|---|
| OpenCore picker dan boot macOS | ✅ Bekerja | Sonoma 14.8.9 diuji sebagai sistem utama |
| CPU 8C/16T | ✅ Bekerja | Kernel patch AMD + ForgedInvariant |
| CPU power management | ✅ Bekerja | AMDRyzenCPUPowerManagement, SMCAMDProcessor, dan SSDT-CPUR |
| iGPU Vega 8 + Metal | ⚠️ Bekerja dengan keterbatasan | NootedRed memberi akselerasi; GPU reset atau artifact dapat terjadi pada aplikasi tertentu |
| Internal display | ✅ Bekerja | Termasuk backlight |
| Keyboard | ✅ Bekerja | VoodooPS2Controller |
| Trackpad I2C | ✅ Bekerja | VoodooI2C + VoodooI2CHID; gesture tertentu dapat berbeda |
| Brightness keys | ✅ Bekerja | BrightnessKeys |
| Battery status | ✅ Bekerja | SMCBatteryManager |
| NVMe | ✅ Bekerja | NVMeFix aktif |
| Ethernet | ✅ Driver aktif | RealtekRTL8111 |
| Wi-Fi RTL8821CE | ✅ Bekerja | UI Wi-Fi native melalui AirPortRTW 1.0.1 (JoMei9019-real); throughput 40–50+ Mbps terverifikasi di Sonoma 14.8.9 |
| Recovery Wi-Fi | ✅ Ditingkatkan | AirPortRTW 1.0.1 dilengkapi output queue gating (STA_R10/R11) dan sinkronisasi NAPI saat sleep |
| Bluetooth Realtek | ✅ Bekerja pada unit pengujian | RealtekBluetoothFirmware + BlueToolFixup |
| AirDrop / AWDL / Continuity penuh | ❌ Tidak andal | AirPortRTW belum menyediakan dukungan AWDL/Continuity yang siap dipakai harian |
| Audio | ✅ Bekerja | AppleALC setelah NootedRed, layout-id 55 |
| Sleep/wake | ✅ Bekerja pada unit pengujian | Tetap uji setelah mengubah USB mapping, Bluetooth, atau versi macOS |
| DRM / streaming protected content | ⚠️ Tidak dijamin | `unfairgva=1` sengaja dihapus karena tidak memperbaiki reset GPU |

## Batasan grafis NootedRed

EFI ini sekarang memakai **NootedRed 0.8.10**, sesuai EFI Sonoma aktif. Akselerasi grafis bekerja pada unit pengujian, tetapi keterbatasan NootedRed tetap dapat berbeda tergantung versi macOS dan beban kerja.

Gejala pada build sebelumnya yang pernah terkonfirmasi melalui laporan `.gpuRestart`:

- Safari/WebKit dapat tersendat atau reset saat memutar video.
- App Store dan `mediaanalysisd` juga dapat memicu reset pada shader `VTMTSComputeFunction`.
- Menambah UMA dari 512 MB ke 1 GB membantu ruang grafis, tetapi tidak menyelesaikan bug driver.

Akselerasi grafis tersedia, tetapi stabilitas bergantung pada aplikasi dan build macOS. GPU reset pernah tercatat, dan aplikasi Chromium/Electron seperti Discord, Spotify, Termius, dan Brave dapat menampilkan artifact ketika hardware acceleration aktif.

Workaround harian:

- Jalankan aplikasi Electron bermasalah dengan `--disable-gpu`.
- Matikan graphics acceleration pada browser jika stabilitas lebih penting.
- Gunakan wallpaper solid bila wallpaper dinamis memicu reset.
- Jalankan `Extras/fix-nootedred.sh` setelah fresh install jika desktop/login mengalami hang.
- Dengan RAM 16 GB, UMA 2 GB dapat dicoba. Gunakan 1 GB bila ingin menyisakan lebih banyak RAM untuk sistem.

Boot arguments snapshot ini:

```text
revcpu=1 -NRedDPDelay
```

`unfairgva=1` sudah dihapus setelah pengujian karena tidak memperbaiki masalah video dan GPU reset.

## Wi-Fi dan Bluetooth

Pada Sonoma, snapshot ini memakai AirPortRTW (JoMei9019-real) bersama Legacy IO80211 stack sehingga RTL8821CE tampil di UI Wi-Fi native Apple. `AirPort_RTW88.kext` dan `rtw88.kext` FeiXiao lama tetap disimpan sebagai fallback dalam keadaan disabled dan tidak boleh diaktifkan bersamaan.

Komponen:

| Peran | Komponen |
|---|---|
| Driver Wi-Fi | `AirPortRTW.kext` 1.0.1 (JoMei9019-real) |
| Compatibility stack | `AMFIPass.kext`, `IOSkywalkFamily.kext`, `IO80211FamilyLegacy.kext` |
| Fallback disabled | `AirPort_RTW88.kext` 2.0.0, FeiXiao `rtw88.kext` 1.0.1 + Starskiff |
| Firmware Bluetooth | `RealtekBluetoothFirmware.kext` |
| Patch Bluetooth Monterey+ | `BlueToolFixup.kext` |

AirDrop tidak dapat dibuat andal hanya dengan mengubah config. Dibutuhkan dukungan AWDL yang bekerja pada hardware dan driver.

## BIOS

Gunakan pengaturan berikut:

| Setting | Nilai |
|---|---|
| Secure Boot | Disabled |
| Fast Boot | Disabled |
| CSM | Disabled |
| IOMMU | Disabled |
| Above 4G Decoding | Enabled |
| UMA Frame Buffer | 1 GB atau 2 GB untuk RAM 16 GB; snapshot diuji dengan 2 GB |

Jangan mengubah menu engineer/advanced yang tidak dipahami. Backup setting BIOS dan EFI sebelum eksperimen.

## SMBIOS

Generate nilai SMBIOS sendiri (model `MacBookPro16,2`) menggunakan GenSMBIOS atau macserial sebelum login ke layanan Apple (iCloud, iMessage, FaceTime). Detail panduan ada di `SMBIOS.txt`.

## Instalasi singkat

1. Download atau clone repo ini.
2. Generate SMBIOS unik dan isi `EFI/OC/config.plist`.
3. Copy folder `EFI` ke partisi EFI USB untuk pengujian.
4. Boot dari USB terlebih dahulu.
5. Jika seluruh perangkat utama bekerja, backup EFI lama lalu copy EFI ini ke partisi internal.
6. Reset NVRAM hanya ketika memang diperlukan setelah perubahan config besar.

Untuk fresh install yang mengalami gray screen/hang, jalankan:

```bash
bash Extras/fix-nootedred.sh "Macintosh HD"
```

Sesuaikan nama volume target. Script sebaiknya dijalankan dari Recovery.

## Komponen utama snapshot

| Komponen | Versi |
|---|---|
| NootedRed | 0.8.10 |
| Lilu | 1.7.2 |
| VirtualSMC | 1.3.7 |
| AppleALC | 1.9.7 |
| RestrictEvents | 1.1.6 |
| RealtekRTL8111 | 3.0.0 |
| AirPortRTW | 1.0.1 |
| AirPort_RTW88 | 2.0.0 (fallback disabled) |
| AMFIPass | 1.4.1 |
| IO80211FamilyLegacy | 12.0 |
| IOSkywalkFamily | 1.0 |
| rtw88 fallback | 1.0.1 (disabled) |
| VoodooI2C | 2.9.1 |
| VoodooPS2Controller | 2.3.7 |
| AMDRyzenCPUPowerManagement | 0.7.2 |

NootedRed harus dimuat **sebelum AppleALC**. Satu instance VoodooInput dari VoodooI2C digunakan; plugin VoodooInput, Mouse, dan Trackpad milik VoodooPS2 dinonaktifkan untuk menghindari konflik.

## Struktur repo

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

File backup/debug dari EFI harian sengaja tidak ikut dimasukkan.

## Sumber dan kredit

- [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg)
- [NootedRed](https://github.com/ChefKissInc/NootedRed)
- [AMD Vanilla](https://github.com/AMD-OSX/AMD_Vanilla)
- [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C)
- Airport_RTW88, FeiXiao/rtw88, Starskiff, dan RealtekBluetoothFirmware
- Acidanthera, ChefKissInc, AMD-OSX, Mieze, dan komunitas Hackintosh

## Disclaimer

Hackintosh tidak didukung Apple. Update macOS, BIOS, OpenCore, atau kext dapat menyebabkan gagal boot, kernel panic, kehilangan akselerasi, atau kehilangan data. Selalu simpan EFI bootable cadangan dan backup data sebelum melakukan perubahan.

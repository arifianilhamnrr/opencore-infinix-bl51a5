# Notice

AirPort-RTW is distributed under the GNU General Public License, version 2
(`LICENSE`). This file records the license notices that the GPL requires to
travel with the source.

## Derived source

AirPort-RTW is a derived work of GPL-2.0 licensed source:

- the AirPort_RTW88 / RTL88WiFi native IO80211 work used as the macOS frontend reference (GPLv2);
- Feixiao and the rtw88 macOS port it was built on;
- the Linux kernel `rtw88` driver, dual licensed GPL-2.0 OR BSD-3-Clause
  (`driver/rtw88-stable/COPYING`).

Individual source files keep their SPDX license identifiers and copyright
notices. Files changed for AirPort-RTW carry a "Modified by X1REN41L" line with
the date; the full change history is in the Git log and `CHANGELOG.md`.

## Separately licensed parts

- The WPA3 backend in `experimental/wpa3/` is imported from
  souissiak1-maker/AirportRTW at revision
  `450fa64d8e758f7180018e5da2f05cab59982fc9`. Its SAE adapter, hostap and Mbed TLS
  sources retain the notices and licenses in `rtw80211/sae/NOTICE.txt` and
  `third_party/`. Source hashes and revisions are recorded in `IMPORT.json`
  and `rtw80211/sae/UPSTREAM.json`. This backend is linked into AirPort-RTW 1.2.0.
  Release bundles keep these license texts in `Contents/Resources/Notices/`.
- Kernel SDK headers in `driver/AirPort-RTW/MacKernelSDK/` keep their own
  notices and `LICENSE.txt`.
- Realtek firmware in `driver/AirPort-RTW/firmware/` keeps its original notices
  (`driver/AirPort-RTW/firmware/README`).
- `Kexts/AMFIPass.kext`, `Kexts/IOSkywalkFamily.kext` and
  `Kexts/IO80211FamilyLegacy.kext` are separate third-party or Apple binaries
  shipped for convenience. They are not AirPort-RTW code and are not relicensed
  by this repository.

The combined AirPort-RTW driver is distributed under GPLv2. This does not
relicense the SDK, the firmware or the bundled dependency kexts.

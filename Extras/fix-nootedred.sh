#!/bin/bash
# NootedRed post-install fix — tested Sequoia 15.7 on Infinix BL51A5
# https://github.com/ChefKissInc/NootedRed/issues/235#issuecomment-4567109847
#
# Run from macOS Recovery → Utilities → Terminal
#   bash /Volumes/UnPlugged/fix-nootedred.sh "Macintosh HD"
#
# Or one-liner (Recovery):
#   defaults write "/Volumes/Macintosh HD/Library/Preferences/com.apple.coremedia" allowMetalTransferSession -bool NO
#   chmod 644 "/Volumes/Macintosh HD/Library/Preferences/com.apple.coremedia.plist"

set -euo pipefail

VOL="${1:-Macintosh HD}"
VOL_PATH="/Volumes/$VOL"

if [[ ! -d "$VOL_PATH/Library" ]]; then
  echo "Volume not found: $VOL_PATH"
  echo "Usage: $0 [volume-name]"
  echo "Run 'diskutil list' to find the macOS volume name."
  exit 1
fi

echo "==> NootedRed VideoToolbox fix on $VOL"
defaults write "$VOL_PATH/Library/Preferences/com.apple.coremedia" allowMetalTransferSession -bool NO
chmod 644 "$VOL_PATH/Library/Preferences/com.apple.coremedia.plist"

echo "==> Reset wallpaper to solid Color (avoid dynamic .mov / Pictures)"
for userdir in "$VOL_PATH/Users/"*; do
  [[ -d "$userdir/Library/Preferences" ]] || continue
  defaults delete "$userdir/Library/Preferences/com.apple.wallpaper" SystemWallpaperURL 2>/dev/null || true
  defaults write "$userdir/Library/Preferences/com.apple.wallpaper" LastSetStyle -string Color
  defaults write "$userdir/Library/Preferences/com.apple.wallpaper" LastSetFlatColor -dict Red 0.15 Green 0.18 Blue 0.22 Alpha 1.0
done

echo ""
echo "Done. Reboot to $VOL."
echo "Keep wallpaper on Color tab — do not use Pictures/dynamic wallpapers on NootedRed."
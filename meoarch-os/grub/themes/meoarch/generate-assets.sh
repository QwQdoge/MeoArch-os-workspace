#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
asset_tmp="$(mktemp -d)"
trap 'rm -rf -- "$asset_tmp"' EXIT

magick -size 760x152 xc:none \
    -font /usr/share/fonts/noto/NotoSans-Bold.ttf \
    -fill '#211A2B' -pointsize 64 -gravity northwest \
    -annotate +0+0 'MeoArch' \
    -font /usr/share/fonts/noto/NotoSans-Regular.ttf \
    -fill '#49454F' -pointsize 25 \
    -annotate +2+82 'Install  ·  Repair  ·  Recover' \
    -depth 8 "PNG32:$script_dir/brand.png"

magick -size 96x96 xc:none \
    -fill 'rgba(33,26,43,0.88)' \
    -stroke 'rgba(255,255,255,0.24)' -strokewidth 2 \
    -draw 'roundrectangle 1,1 94,94 22,22' \
    -depth 8 "PNG32:$asset_tmp/panel.png"

magick -size 96x96 xc:none \
    -fill 'rgba(103,80,164,0.96)' \
    -stroke 'rgba(255,255,255,0.46)' -strokewidth 2 \
    -draw 'roundrectangle 1,1 94,94 18,18' \
    -depth 8 "PNG32:$asset_tmp/select.png"

slice_box() {
    local source="$1"
    local stem="$2"
    magick "$source" -crop 32x32+0+0 +repage -depth 8 "PNG32:$script_dir/${stem}_nw.png"
    magick "$source" -crop 32x32+32+0 +repage -depth 8 "PNG32:$script_dir/${stem}_n.png"
    magick "$source" -crop 32x32+64+0 +repage -depth 8 "PNG32:$script_dir/${stem}_ne.png"
    magick "$source" -crop 32x32+0+32 +repage -depth 8 "PNG32:$script_dir/${stem}_w.png"
    magick "$source" -crop 32x32+32+32 +repage -depth 8 "PNG32:$script_dir/${stem}_c.png"
    magick "$source" -crop 32x32+64+32 +repage -depth 8 "PNG32:$script_dir/${stem}_e.png"
    magick "$source" -crop 32x32+0+64 +repage -depth 8 "PNG32:$script_dir/${stem}_sw.png"
    magick "$source" -crop 32x32+32+64 +repage -depth 8 "PNG32:$script_dir/${stem}_s.png"
    magick "$source" -crop 32x32+64+64 +repage -depth 8 "PNG32:$script_dir/${stem}_se.png"
}

slice_box "$asset_tmp/panel.png" panel
slice_box "$asset_tmp/select.png" select

grub_mkfont="${GRUB_MKFONT:-$(command -v grub-mkfont || true)}"
if [ -n "$grub_mkfont" ]; then
    "$grub_mkfont" --name='MeoArch Sans' --size=24 --range=0x20-0x7e \
        --output="$script_dir/meoarch-sans-regular-24.pf2" \
        /usr/share/fonts/noto/NotoSans-Regular.ttf
    "$grub_mkfont" --name='MeoArch Sans' --bold --size=24 --range=0x20-0x7e \
        --output="$script_dir/meoarch-sans-bold-24.pf2" \
        /usr/share/fonts/noto/NotoSans-Bold.ttf
    "$grub_mkfont" --name='MeoArch Sans' --size=18 --range=0x20-0x7e \
        --output="$script_dir/meoarch-sans-regular-18.pf2" \
        /usr/share/fonts/noto/NotoSans-Regular.ttf
else
    echo "grub-mkfont not found; keeping the checked-in PF2 font assets." >&2
fi

echo "Generated MeoArch GRUB theme assets in $script_dir"

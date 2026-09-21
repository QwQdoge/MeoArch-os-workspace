#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
asset_tmp="$(mktemp -d)"
trap 'rm -rf -- "$asset_tmp"' EXIT

repo_root="$(cd -- "$script_dir/../../../.." && pwd)"
logo_svg="$repo_root/assets/icons/Logo.svg"
splash_png="$script_dir/../../splash.png"

[ -f "$logo_svg" ] || {
    echo "Canonical MeoArch logo is missing: $logo_svg" >&2
    exit 1
}

# Keep the boot brand exact: rasterize the canonical repository SVG instead of
# redrawing or typesetting a second logo.
magick -background none "$logo_svg" \
    -resize 260x117 \
    -gravity center -extent 260x117 \
    -strip -depth 8 "PNG32:$script_dir/brand.png"

# Abstract Pixel/Material-style background only. Menu text, logo, and selection
# states are rendered by GRUB so the bitmap never bakes in fake UI.
magick -size 1920x1080 xc:'#FAF9FC' \
    -fill 'rgba(194,207,255,0.48)' -draw 'ellipse 80,40 650,420 0,360' \
    -fill 'rgba(227,211,255,0.34)' -draw 'ellipse 120,480 470,840 0,360' \
    -fill 'rgba(217,193,255,0.38)' -draw 'ellipse 1650,420 2110,820 0,360' \
    -fill 'rgba(248,198,228,0.30)' -draw 'ellipse 1750,760 2100,1110 0,360' \
    -fill 'rgba(194,207,255,0.28)' -draw 'ellipse 1450,930 1810,1290 0,360' \
    -strip -depth 8 "$splash_png"

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

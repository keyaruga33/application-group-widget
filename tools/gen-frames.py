#!/usr/bin/env python3
"""Generate FrameSvg files used as the popup's blur/contrast mask.

KWin's blur/contrast region for a Plasma popup follows the alpha mask of the
popup's FrameSvg. The rounded files match a rounded popup, but that region
covers the whole window, so background contrast paints a solid panel. The
applet installs noblur.svg instead (a few corner pixels). The rounded files
stay here so the mask radius assets are still reproducible.
"""
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "src", "contents", "frames")
MARGIN = 8  # content padding inside the popup window (logical px)


def svg(r):
    c = max(r, 1)
    X = Y = c + 1
    hx = 2 * c + 10
    f = 'fill="#000000"'
    if r == 0:
        tl = f'<rect id="topleft" x="0" y="0" width="1" height="1" {f}/>'
        tr = f'<rect id="topright" x="{X}" y="0" width="1" height="1" {f}/>'
        br = f'<rect id="bottomright" x="{X}" y="{Y}" width="1" height="1" {f}/>'
        bl = f'<rect id="bottomleft" x="0" y="{Y}" width="1" height="1" {f}/>'
    else:
        tl = f'<path id="topleft" d="M {c},{c} L 0,{c} A {c},{c} 0 0 1 {c},0 Z" {f}/>'
        tr = f'<path id="topright" d="M {X},{c} L {X},0 A {c},{c} 0 0 1 {X + c},{c} Z" {f}/>'
        br = f'<path id="bottomright" d="M {X},{Y} L {X + c},{Y} A {c},{c} 0 0 1 {X},{Y + c} Z" {f}/>'
        bl = f'<path id="bottomleft" d="M {c},{Y} L {c},{Y + c} A {c},{c} 0 0 1 0,{Y} Z" {f}/>'
    w = hx + MARGIN + 2
    h = max(2 * c + 1, MARGIN + 2)
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  {tl}
  <rect id="top" x="{c}" y="0" width="1" height="{c}" {f}/>
  {tr}
  <rect id="left" x="0" y="{c}" width="{c}" height="1" {f}/>
  <rect id="center" x="{c}" y="{c}" width="1" height="1" {f}/>
  <rect id="right" x="{X}" y="{c}" width="{c}" height="1" {f}/>
  {bl}
  <rect id="bottom" x="{c}" y="{Y}" width="1" height="{c}" {f}/>
  {br}
  <rect id="hint-top-margin" x="{hx}" y="0" width="1" height="{MARGIN}" fill="none"/>
  <rect id="hint-bottom-margin" x="{hx + 1}" y="0" width="1" height="{MARGIN}" fill="none"/>
  <rect id="hint-left-margin" x="{hx}" y="{MARGIN + 1 if h > MARGIN + 1 else 0}" width="{MARGIN}" height="1" fill="none"/>
  <rect id="hint-right-margin" x="{hx}" y="0" width="{MARGIN}" height="1" fill="none"/>
  <rect id="hint-stretch-borders" x="{hx}" y="0" width="1" height="1" fill="none"/>
</svg>
'''


os.makedirs(OUT, exist_ok=True)
for r in range(0, 33, 2):
    with open(os.path.join(OUT, f"rounded-{r}.svg"), "w") as fh:
        fh.write(svg(r))


# No-blur mask: every frame piece is transparent except one pixel in each
# corner piece. KWin treats an empty region as "whole window", so a tiny
# non-empty region is how we effectively switch blur/contrast off.
# noblur-b.svg is a twin with the same hint margins. FullRepresentation swaps
# to it to force KSvg maskChanged after the popup is mapped.
NOBLUR = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="10" viewBox="0 0 22 10">
  <rect id="topleft" x="0" y="0" width="1" height="1" fill="#000000"/>
  <rect id="top" x="1" y="0" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="topright" x="2" y="0" width="1" height="1" fill="#000000"/>
  <rect id="left" x="0" y="1" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="center" x="1" y="1" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="right" x="2" y="1" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="bottomleft" x="0" y="2" width="1" height="1" fill="#000000"/>
  <rect id="bottom" x="1" y="2" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="bottomright" x="2" y="2" width="1" height="1" fill="#000000"/>
  <rect id="hint-top-margin" x="12" y="0" width="1" height="8" fill="none"/>
  <rect id="hint-bottom-margin" x="13" y="0" width="1" height="8" fill="none"/>
  <rect id="hint-left-margin" x="12" y="9" width="8" height="1" fill="none"/>
  <rect id="hint-right-margin" x="12" y="0" width="8" height="1" fill="none"/>
  <rect id="hint-stretch-borders" x="12" y="0" width="1" height="1" fill="none"/>
</svg>
'''
NOBLUR_B = '''<?xml version="1.0" encoding="UTF-8"?>
<!-- Twin mask with identical hint margins. FullRepresentation swaps to this file to force KSvg maskChanged after the popup is mapped. -->
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="10" viewBox="0 0 22 10">
  <rect id="topleft" x="0" y="0" width="1" height="1" fill="#000000"/>
  <rect id="top" x="1" y="0" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="topright" x="2" y="0" width="1" height="1" fill="#000000"/>
  <rect id="left" x="0" y="1" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="center" x="1" y="1" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="right" x="2" y="1" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="bottomleft" x="0" y="2" width="1" height="1" fill="#000000"/>
  <rect id="bottom" x="1" y="2" width="1" height="1" fill="#000000" fill-opacity="0"/>
  <rect id="bottomright" x="2" y="2" width="1" height="1" fill="#000000"/>
  <rect id="hint-top-margin" x="12" y="0" width="1" height="8" fill="none"/>
  <rect id="hint-bottom-margin" x="13" y="0" width="1" height="8" fill="none"/>
  <rect id="hint-left-margin" x="12" y="9" width="8" height="1" fill="none"/>
  <rect id="hint-right-margin" x="12" y="0" width="8" height="1" fill="none"/>
  <rect id="hint-stretch-borders" x="12" y="0" width="1" height="1" fill="none"/>
</svg>
'''
with open(os.path.join(OUT, "noblur.svg"), "w") as fh:
    fh.write(NOBLUR)
with open(os.path.join(OUT, "noblur-b.svg"), "w") as fh:
    fh.write(NOBLUR_B)

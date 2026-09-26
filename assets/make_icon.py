# Vygeneruje ikonu Clover (štvorlístok) → assets/clover.icns + clover.png
import math, os, subprocess, tempfile
from PIL import Image, ImageDraw

S = 1024 * 4  # supersampling
img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
m = int(S * 0.1)  # okraj podľa macOS icon gridu
d.rounded_rectangle([m, m, S - m, S - m], radius=int(S * 0.18), fill=(17, 17, 17, 255))

cx, cy = S / 2, S / 2
r = S * 0.085        # polomer „laloku“ srdiečka
dist = S * 0.17      # vzdialenosť lístka od stredu
for k in range(4):
    a = math.radians(45 + 90 * k)
    # srdiečko = 2 kruhy + trojuholník smerom do stredu
    ux, uy = math.cos(a), math.sin(a)
    px, py = -uy, ux
    bx, by = cx + ux * dist, cy + uy * dist
    for s in (-1, 1):
        ox, oy = bx + px * r * 0.8 * s, by + py * r * 0.8 * s
        d.ellipse([ox - r, oy - r, ox + r, oy + r], fill='white')
    wide = r * 1.75
    l = (bx + px * wide - ux * r * 0.35, by + py * wide - uy * r * 0.35)
    rr = (bx - px * wide - ux * r * 0.35, by - py * wide - uy * r * 0.35)
    d.polygon([(cx, cy), l, rr], fill='white')
# medzera v tvare „+“ = 2×2 mriežka panelov
g = S * 0.028
d.rectangle([cx - g / 2, m, cx + g / 2, S - m], fill=(17, 17, 17, 255))
d.rectangle([m, cy - g / 2, S - m, cy + g / 2], fill=(17, 17, 17, 255))

here = os.path.dirname(os.path.abspath(__file__))
big = img.resize((1024, 1024), Image.LANCZOS)
big.save(os.path.join(here, 'clover.png'))
with tempfile.TemporaryDirectory() as t:
    ic = os.path.join(t, 'clover.iconset'); os.mkdir(ic)
    for n in (16, 32, 128, 256, 512):
        big.resize((n, n), Image.LANCZOS).save(f'{ic}/icon_{n}x{n}.png')
        big.resize((n * 2, n * 2), Image.LANCZOS).save(f'{ic}/icon_{n}x{n}@2x.png')
    subprocess.run(['iconutil', '-c', 'icns', ic, '-o', os.path.join(here, 'clover.icns')], check=True)
big.resize((256, 256), Image.LANCZOS).save(os.path.join(here, 'clover.ico'))
print('ok')

import sys
from PIL import Image
for p in sys.argv[1:]:
    im = Image.open(p)
    if im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info):
        a = im.convert("RGBA").getchannel("A")
        px = list(a.getdata())
        n = len(px)
        z = sum(1 for v in px if v == 0) / n * 100
        lt = sum(1 for v in px if v < 10) / n * 100
        print(f"{p}: {im.size[0]}x{im.size[1]} mode={im.mode} alpha_min={min(px)} alpha=0 {z:.2f}% alpha<10 {lt:.2f}%")
    else:
        print(f"{p}: {im.size[0]}x{im.size[1]} mode={im.mode} (no alpha)")

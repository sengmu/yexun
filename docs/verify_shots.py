from pathlib import Path
from collections import Counter
from PIL import Image
root = Path(__file__).parent / 'shots'
for kind in ('spirit', 'reality', 'ending'):
    path = root / (kind + '_r1.png')
    image = Image.open(path).convert('RGB')
    counts = Counter(image.getdata())
    pixels = image.width * image.height
    nonuniform = 1 - counts.most_common(1)[0][1] / pixels
    nonblack = sum(count for color, count in counts.items() if max(color) > 24) / pixels
    ok = image.size == (1280, 720) and path.stat().st_size > 5000 and nonuniform > .01 and nonblack > .01
    print(f'{"PASS" if ok else "FAIL"} {path.name}: {path.stat().st_size} bytes; nonuniform={nonuniform:.4%}; nonblack={nonblack:.4%}')
    if not ok:
        raise SystemExit(1)

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT_DIR = ROOT / "app" / "assets" / "fonts"
OUT_DIR = ROOT / "app" / "assets" / "images"

W, H = 1200, 800
BG_TOP = (12, 15, 23)
BG_BOTTOM = (27, 32, 44)
LIME = (172, 239, 52)
SURFACE = (38, 44, 60)
SURFACE_2 = (27, 32, 44)
TEXT = (248, 250, 252)
MUTED = (148, 163, 184)


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_DIR / name), size)


def gradient() -> Image.Image:
    image = Image.new("RGB", (W, H), BG_TOP)
    pixels = image.load()
    for y in range(H):
        t = y / max(1, H - 1)
        r = int(BG_TOP[0] + (BG_BOTTOM[0] - BG_TOP[0]) * t)
        g = int(BG_TOP[1] + (BG_BOTTOM[1] - BG_TOP[1]) * t)
        b = int(BG_TOP[2] + (BG_BOTTOM[2] - BG_TOP[2]) * t)
        for x in range(W):
            pixels[x, y] = (r, g, b)
    return image


def rounded(draw: ImageDraw.ImageDraw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def base_card() -> Image.Image:
    image = gradient()
    draw = ImageDraw.Draw(image)
    rounded(draw, (72, 72, W - 72, H - 72), 42, SURFACE_2, (255, 255, 255, 18), 2)
    draw.line((72, 150, W - 72, 150), fill=(255, 255, 255, 20), width=2)
    draw.text((112, 92), "WORTHBANG", font=font("PlusJakartaSans-Bold.ttf", 24), fill=LIME)
    return image


def finish(image: Image.Image, title: str, subtitle: str) -> None:
    draw = ImageDraw.Draw(image)
    draw.text((112, H - 160), title, font=font("PlusJakartaSans-ExtraBold.ttf", 58), fill=TEXT)
    draw.text((114, H - 92), subtitle, font=font("PlusJakartaSans-Regular.ttf", 24), fill=MUTED)
    draw.ellipse((W - 132, 86, W - 108, 110), fill=LIME)


def gpu() -> Image.Image:
    image = base_card()
    d = ImageDraw.Draw(image)
    # GPU body
    rounded(d, (210, 245, 990, 545), 30, SURFACE, LIME, 3)
    # two fans
    for cx in (395, 805):
        d.ellipse((cx - 115, 300, cx + 115, 530), outline=(172, 239, 52, 120), width=4)
        d.ellipse((cx - 28, 387, cx + 28, 443), fill=LIME)
        for angle in (0, 60, 120):
            import math
            rad = math.radians(angle)
            dx, dy = math.cos(rad) * 75, math.sin(rad) * 75
            d.line((cx - dx, 415 - dy, cx + dx, 415 + dy), fill=(172, 239, 52, 90), width=4)
    # PCIe connector
    rounded(d, (260, 545, 760, 575), 8, (15, 23, 42), LIME, 2)
    # power connector
    rounded(d, (830, 245, 930, 285), 8, (15, 23, 42), MUTED, 2)
    finish(image, "GPU", "Kartu grafis · satu seri, banyak varian")
    return image


def cpu() -> Image.Image:
    image = base_card()
    d = ImageDraw.Draw(image)
    # pins
    for i in range(12):
        x = 330 + i * 48
        d.line((x, 220, x, 270), fill=MUTED, width=4)
        d.line((x, 530, x, 580), fill=MUTED, width=4)
    for i in range(8):
        y = 300 + i * 40
        d.line((260, y, 310, y), fill=MUTED, width=4)
        d.line((890, y, 940, y), fill=MUTED, width=4)
    # chip
    rounded(d, (310, 270, 890, 530), 34, SURFACE, LIME, 4)
    rounded(d, (390, 330, 810, 470), 18, (15, 23, 42), (255, 255, 255, 30), 2)
    d.text((430, 372), "CPU", font=font("PlusJakartaSans-ExtraBold.ttf", 64), fill=LIME)
    finish(image, "CPU", "Prosesor · socket, core, thread")
    return image


def motherboard() -> Image.Image:
    image = base_card()
    d = ImageDraw.Draw(image)
    rounded(d, (185, 220, 1015, 590), 24, (20, 32, 44), LIME, 3)
    # socket
    rounded(d, (280, 290, 500, 450), 12, SURFACE, MUTED, 2)
    # RAM slots
    for i in range(4):
        x = 570 + i * 38
        rounded(d, (x, 270, x + 18, 520), 6, (15, 23, 42), LIME, 1)
    # PCIe slots
    rounded(d, (280, 500, 680, 530), 8, (15, 23, 42), LIME, 1)
    rounded(d, (280, 550, 680, 580), 8, (15, 23, 42), MUTED, 1)
    # chipset
    rounded(d, (760, 430, 900, 540), 12, SURFACE, LIME, 2)
    # traces
    for i in range(6):
        d.line((500, 320 + i * 18, 550, 320 + i * 18), fill=(172, 239, 52, 90), width=2)
    finish(image, "MOTHERBOARD", "Socket & chipset · fondasi rakitan")
    return image


def ram() -> Image.Image:
    image = base_card()
    d = ImageDraw.Draw(image)
    for i in range(3):
        x = 270 + i * 230
        rounded(d, (x, 250, x + 150, 560), 18, SURFACE, LIME, 2)
        for j in range(5):
            rounded(d, (x + 20, 290 + j * 42, x + 130, 320 + j * 42), 6, (15, 23, 42), (255, 255, 255, 18), 1)
        d.rectangle((x + 24, 530, x + 126, 544), fill=LIME)
    finish(image, "RAM", "Memori · kapasitas, tipe, kecepatan")
    return image


def storage() -> Image.Image:
    image = base_card()
    d = ImageDraw.Draw(image)
    rounded(d, (220, 300, 980, 500), 24, SURFACE, LIME, 3)
    # M.2 connector
    rounded(d, (250, 360, 330, 440), 8, (15, 23, 42), MUTED, 2)
    # chips
    for i in range(3):
        rounded(d, (380 + i * 180, 345, 520 + i * 180, 455), 10, (15, 23, 42), (255, 255, 255, 18), 1)
        d.text((400 + i * 180, 378), "NAND", font=font("PlusJakartaSans-Bold.ttf", 20), fill=LIME)
    # label
    d.text((700, 470), "NVMe / SATA", font=font("PlusJakartaSans-Regular.ttf", 20), fill=MUTED)
    finish(image, "STORAGE", "SSD / HDD · kapasitas & interface")
    return image


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, factory in (
        ("gpu", gpu),
        ("cpu", cpu),
        ("motherboard", motherboard),
        ("ram", ram),
        ("storage", storage),
    ):
        path = OUT_DIR / f"{name}.png"
        factory().save(path, "PNG")
        print(path)


if __name__ == "__main__":
    main()

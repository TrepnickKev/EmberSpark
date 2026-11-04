"""Builds the framed store screenshots from the raw app screenshots.

Picked raw screenshots from raw/<locale>/<n>.png are put into a phone frame on
an ember-glow background with a headline and a subline, and written to
fastlane/metadata/android/<locale>/images/phoneScreenshots/EN_1.png, EN_2.png,
... (DE_1.png, ... for de-DE).
F-Droid reads them from there, and the same files are uploaded to Google Play.

Usage: python tools/store_screenshots/make.py
Needs Pillow and the Segoe UI fonts that ship with Windows.
"""

import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageStat

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
FONTS = Path("C:/Windows/Fonts")

W, H = 1080, 1920  # 9:16, the size Google Play recommends
BG_TOP = (28, 18, 20)
BG_BOTTOM = (10, 10, 14)
EMBER = (255, 138, 31)
GLOW = (255, 98, 0)
TEXT = (250, 246, 242)
SUBTEXT = (214, 190, 172)

# Per output slide: (raw screenshot number, headline, subline). A "*part*" of
# the headline is drawn in the ember colour. No em-dashes in copy.
SLIDES = {
    "en-US": [
        (1, "Your LNbits, *in your pocket*", "Balance in sats and your currency at a glance"),
        (3, "Pay in *seconds*", "Scan, paste, tap NFC or pick a QR code image"),
        (4, "Get paid *your way*", "Lightning address, invoice or NFC"),
        (5, "Pay friends *by name*", "Contacts with Lightning addresses and LNURLs"),
        (6, "Share *your address*", "Lightning address, LNURL or BOLT12 as a QR code"),
        (8, "*Bolt Cards* built in", "Program, verify, disable or wipe NFC payment cards"),
    ],
    "de-DE": [
        (1, "Dein LNbits *für unterwegs*", "Guthaben in Sats und deiner Währung auf einen Blick"),
        (3, "Bezahlen in *Sekunden*", "Scannen, einfügen, NFC oder ein QR-Code-Bild"),
        (4, "Geld empfangen, *wie du willst*", "Lightning-Adresse, Rechnung oder NFC"),
        (5, "Freunde *per Name* bezahlen", "Kontakte mit Lightning-Adressen und LNURLs"),
        (6, "Teile *deine Adresse*", "Lightning-Adresse, LNURL oder BOLT12 als QR-Code"),
        (8, "*Bolt Cards* inklusive", "NFC-Bezahlkarten einrichten und verwalten"),
    ],
}


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), size)


def background(seed):
    img = Image.new("RGB", (W, H))
    px = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        px.line(
            [(0, y), (W, y)],
            fill=tuple(round(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)),
        )

    # Soft ember glow behind the phone, moving a little from slide to slide.
    rnd = random.Random(seed)
    glow = Image.new("L", (W, H), 0)
    g = ImageDraw.Draw(glow)
    cx = W // 2 + rnd.randint(-160, 160)
    cy = 1150 + rnd.randint(-120, 120)
    g.ellipse([cx - 520, cy - 620, cx + 520, cy + 620], fill=120)
    glow = glow.filter(ImageFilter.GaussianBlur(220))
    img = Image.composite(Image.new("RGB", (W, H), GLOW), img, glow)

    # Rising sparks.
    sparks = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    s = ImageDraw.Draw(sparks)
    for _ in range(70):
        x, y = rnd.randint(0, W), rnd.randint(320, H)
        r = rnd.choice([2, 2, 3, 3, 4, 6])
        a = rnd.randint(60, 200)
        s.ellipse([x - r, y - r, x + r, y + r], fill=EMBER + (a,))
    sparks = Image.alpha_composite(
        sparks.filter(ImageFilter.GaussianBlur(6)), sparks.filter(ImageFilter.GaussianBlur(1))
    )
    return Image.alpha_composite(img.convert("RGBA"), sparks)


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius, fill=255)
    return m


def phone(shot, screen_h):
    """The screenshot in a slim dark phone body with a punch-hole camera."""
    shot = shot.convert("RGB")
    # Drop the near-black navigation bar strip (gesture handle included) at
    # the bottom.
    gray = shot.convert("L")
    bottom = shot.height - 4  # some captures end in a few lighter edge rows
    while bottom > shot.height // 2:
        row = gray.crop((0, bottom - 1, shot.width, bottom))
        if ImageStat.Stat(row).median[0] >= 9:
            break
        bottom -= 1
    shot = shot.crop((0, 0, shot.width, bottom))
    screen_w = round(shot.width * screen_h / shot.height)
    screen = shot.resize((screen_w, screen_h), Image.LANCZOS)
    bezel, radius = 18, 70
    pw, ph = screen_w + 2 * bezel, screen_h + 2 * bezel

    body = Image.new("RGBA", (pw + 8, ph), (0, 0, 0, 0))
    d = ImageDraw.Draw(body)
    # Side buttons on the right edge.
    d.rounded_rectangle([pw - 4, 260, pw + 6, 380], 4, fill=(52, 52, 58))
    d.rounded_rectangle([pw - 4, 430, pw + 6, 500], 4, fill=(52, 52, 58))
    d.rounded_rectangle([0, 0, pw - 1, ph - 1], radius, fill=(22, 22, 26))
    d.rounded_rectangle([2, 2, pw - 3, ph - 3], radius - 2, outline=(70, 70, 78), width=3)

    body.paste(screen, (bezel, bezel), rounded_mask(screen.size, radius - bezel))
    cam = pw // 2
    d.ellipse([cam - 13, bezel + 18, cam + 13, bezel + 44], fill=(8, 8, 10))
    d.ellipse([cam - 5, bezel + 26, cam + 1, bezel + 32], fill=(40, 44, 60))
    return body


def draw_headline(canvas, text, y):
    d = ImageDraw.Draw(canvas)
    # Shrink a long headline to keep it on one line, so every phone sits at
    # the same height; only wrap when even the smallest size doesn't fit.
    for size in range(74, 55, -2):
        f = font("seguibl.ttf", size)
        if d.textlength(text.replace("*", ""), font=f) <= W - 120:
            break
    words = []  # (word, colour)
    for i, chunk in enumerate(text.split("*")):
        words += [(w, EMBER if i % 2 else TEXT) for w in chunk.split(" ") if w]

    # Wrap onto more lines when it doesn't fit.
    lines, line = [], []
    for w in words:
        trial = line + [w]
        if line and d.textlength(" ".join(x for x, _ in trial), font=f) > W - 120:
            lines.append(line)
            line = [w]
        else:
            line = trial
    lines.append(line)

    for ln in lines:
        total = d.textlength(" ".join(x for x, _ in ln), font=f)
        x = (W - total) / 2
        for i, (w, c) in enumerate(ln):
            word = w + (" " if i < len(ln) - 1 else "")
            d.text((x, y), word, font=f, fill=c)
            x += d.textlength(word, font=f)
        y += 92
    return y


def make(locale, slide, raw, headline, subline):
    canvas = background(seed=slide * 7 + 3)
    d = ImageDraw.Draw(canvas)

    icon = Image.open(ROOT / "fastlane/metadata/android/en-US/images/icon.png").convert("RGBA")
    icon = icon.resize((64, 64), Image.LANCZOS)
    brand = font("seguisb.ttf", 34)
    label = "EmberSpark"
    bw = 64 + 14 + d.textlength(label, font=brand)
    bx = round((W - bw) / 2)
    canvas.alpha_composite(icon, (bx, 72))
    d.text((bx + 78, 84), label, font=brand, fill=SUBTEXT)

    y = draw_headline(canvas, headline, 176)
    sub = font("segoeui.ttf", 38)
    d.text((W / 2, y + 16), subline, font=sub, fill=SUBTEXT, anchor="ma")

    top = y + 110
    body = phone(Image.open(HERE / "raw" / locale / f"{raw}.png"), H - top - 70 - 36)
    px = (W - body.width) // 2

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [px + 10, top + 34, px + body.width - 2, top + body.height + 30], 80, fill=(0, 0, 0, 190)
    )
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(34)))
    canvas.alpha_composite(body, (px, top))

    lang = locale.split("-")[0].upper()
    out = ROOT / f"fastlane/metadata/android/{locale}/images/phoneScreenshots/{lang}_{slide}.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(out, optimize=True)
    return out


if __name__ == "__main__":
    for locale, slides in SLIDES.items():
        for slide, (raw, headline, subline) in enumerate(slides, start=1):
            print(make(locale, slide, raw, headline, subline).relative_to(ROOT))

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"

robot = Image.open(ASSETS / "operiva-robot-v2.png").convert("RGBA")
wordmark = Image.open(ASSETS / "operiva-wordmark.png").convert("RGBA")
mark = Image.open(ASSETS / "operiva-mark.png").convert("RGBA")

# The wordmark is printed directly into the clean chest shell.
wordmark_width = 270
wordmark_height = round(wordmark.height * wordmark_width / wordmark.width)
wordmark = wordmark.resize((wordmark_width, wordmark_height), Image.Resampling.LANCZOS)
wordmark_alpha = wordmark.getchannel("A").point(lambda value: round(value * 0.88))
wordmark.putalpha(wordmark_alpha)
robot.alpha_composite(wordmark, (430, 630))

# The exact supplied mark becomes one restrained hologram above the open palm.
mark_width = 146
mark_height = round(mark.height * mark_width / mark.width)
mark = mark.resize((mark_width, mark_height), Image.Resampling.LANCZOS)
mark_x = 187
mark_y = 792

glow = Image.new("RGBA", robot.size, (0, 0, 0, 0))
glow_draw = ImageDraw.Draw(glow)
glow_draw.ellipse((162, 764, 360, 978), fill=(90, 254, 247, 78))
glow = glow.filter(ImageFilter.GaussianBlur(38))
robot.alpha_composite(glow)

beam = Image.new("RGBA", robot.size, (0, 0, 0, 0))
beam_draw = ImageDraw.Draw(beam)
beam_draw.polygon(((210, 900), (310, 900), (344, 970), (176, 970)), fill=(90, 254, 247, 20))
beam = beam.filter(ImageFilter.GaussianBlur(11))
robot.alpha_composite(beam)

base = Image.new("RGBA", robot.size, (0, 0, 0, 0))
base_draw = ImageDraw.Draw(base)
base_draw.ellipse((172, 947, 348, 985), outline=(90, 254, 247, 156), width=3)
base_glow = base.filter(ImageFilter.GaussianBlur(10))
robot.alpha_composite(base_glow)
robot.alpha_composite(base)
robot.alpha_composite(mark, (mark_x, mark_y))

robot.save(ASSETS / "operiva-robot-integrated.png", optimize=True)

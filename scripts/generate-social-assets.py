"""Render Porta's existing geometric mark and sharing card. Requires Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'website'
S = 2
PAPER, INK, LIME, MUTED = '#f6f3ea', '#25271f', '#deff7a', '#64665b'
FONTS = Path('/System/Library/Fonts/Supplemental')

def font(size, name='Arial.ttf'):
    return ImageFont.truetype(str(FONTS / name), size * S)

def rect(draw, box, fill, radius=0, outline=None, width=1):
    draw.rounded_rectangle(tuple(round(v*S) for v in box), radius=round(radius*S), fill=fill, outline=outline, width=round(width*S))

def text(draw, xy, value, size, color=INK, name='Arial.ttf'):
    draw.text(tuple(round(v*S) for v in xy), value, font=font(size,name), fill=color, anchor='lt')

def mark(draw, x, y, size):
    k=size/64
    def box(coords): return [x+coords[0]*k,y+coords[1]*k,x+coords[2]*k,y+coords[3]*k]
    rect(draw,box([0,0,64,64]),LIME,15*k)
    rect(draw,box([22,20,49,52]),LIME,5*k,INK,4*k)
    rect(draw,box([14,12,41,44]),LIME,5*k,INK,4*k)
    for yy in (24,32):
        draw.line(tuple(round(v*S) for v in box([22,yy,33,yy])),fill=INK,width=round(4*k*S))

im=Image.new('RGB',(1200*S,630*S),PAPER);d=ImageDraw.Draw(im)
mark(d,64,52,58)
text(d,(137,58),'porta',48,name='Arial Bold.ttf')
text(d,(66,171),'Lo copias.',91)
text(d,(62,277),'Lo tienes.',91,name='Georgia Italic.ttf')
text(d,(68,407),'Tu portapapeles, con memoria.',28,color=MUTED)
rect(d,(68,514,347,564),INK,25)
text(d,(91,529),'Gratis para Mac · Beta',21,color=PAPER)
rect(d,(784,134,1134,484),'#e7eadb',74)
mark(d,847,197,224)
text(d,(796,527),'martinzg16.github.io/porta',21,color=MUTED)
im.resize((1200,630),Image.Resampling.LANCZOS).save(OUT/'social-card.png',optimize=True)
icon=Image.new('RGB',(512*S,512*S),LIME);mark(ImageDraw.Draw(icon),0,0,512)
for filename,size in [('apple-touch-icon.png',180),('favicon-32.png',32),('logo.png',512)]:
    icon.resize((size,size),Image.Resampling.LANCZOS).save(OUT/filename,optimize=True)

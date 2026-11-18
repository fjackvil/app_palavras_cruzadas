"""Gera o ícone 512x512 e o gráfico de recursos 1024x500 da Play Store.

Uso: python3 tool/imagens_loja.py   (saída em docs/loja/)
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

RAIZ = Path(__file__).resolve().parent.parent
RES = RAIZ / 'app/android/app/src/main/res'
SAIDA = RAIZ / 'docs/loja'
VERDE = (0x32, 0x99, 0x32)
VERDE_CLARO = (0x6C, 0xD0, 0x3C)
FONTE = '/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf'
FONTE_N = '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf'

SAIDA.mkdir(parents=True, exist_ok=True)
frente = Image.open(RES / 'mipmap-xxxhdpi/ic_launcher_foreground.png').convert('RGBA')

# Ícone: fundo verde do ícone do app + desenho da frente, sem transparência.
icone = Image.new('RGBA', (512, 512), VERDE + (255,))
# O launcher mostra só o miolo do ícone adaptativo (72 de 108 dp): corta igual.
lado = frente.width * 72 // 108
m = (frente.width - lado) // 2
icone.alpha_composite(frente.crop((m, m, m + lado, m + lado)).resize((512, 512), Image.LANCZOS))
icone.convert('RGB').save(SAIDA / 'icone-512.png')


def degrade(l, a, c1, c2):
    img = Image.new('RGB', (l, a))
    d = ImageDraw.Draw(img)
    for x in range(l):
        t = x / (l - 1)
        d.line([(x, 0), (x, a)], fill=tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3)))
    return img


# Gráfico de recursos: degradê verde, ícone grande e o nome.
dest = degrade(1024, 500, VERDE, VERDE_CLARO).convert('RGBA')
mascara = Image.new('L', (330, 330), 0)
ImageDraw.Draw(mascara).rounded_rectangle([0, 0, 329, 329], 64, fill=255)
ic = icone.resize((330, 330), Image.LANCZOS)
sombra = Image.new('RGBA', (1024, 500), (0, 0, 0, 0))
ImageDraw.Draw(sombra).rounded_rectangle([70, 95, 400, 425], 64, fill=(0, 0, 0, 60))
dest.alpha_composite(sombra)
dest.paste(ic, (60, 85), mascara)
d = ImageDraw.Draw(dest)
branco = (255, 255, 255)
d.text((440, 125), 'Palavras Cruzadas', font=ImageFont.truetype(FONTE, 56), fill=branco)
d.text((440, 195), 'e Caça-palavras', font=ImageFont.truetype(FONTE, 56), fill=branco)
d.text((443, 300), 'Dos 4 anos ao adulto · 64 temas', font=ImageFont.truetype(FONTE_N, 32), fill=branco)
d.text((443, 345), 'Desafio do dia · Sem anúncios', font=ImageFont.truetype(FONTE_N, 32), fill=branco)
dest.convert('RGB').save(SAIDA / 'destaque-1024x500.png')
print('ok: docs/loja/icone-512.png e docs/loja/destaque-1024x500.png')

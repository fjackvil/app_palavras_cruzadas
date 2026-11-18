"""Monta as capturas de tela da loja (1080x1920) com uma frase em cima.

Entrada: docs/loja/telas/originais/<nome>.png (prints do emulador, 1080x2400)
Saída:   docs/loja/telas/<n>-<nome>.png
Uso: python3 tool/telas_loja.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAIZ = Path(__file__).resolve().parent.parent
PASTA = RAIZ / 'docs/loja/telas'
FONTE = '/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf'
VERDE, VERDE_CLARO = (0x32, 0x99, 0x32), (0x6C, 0xD0, 0x3C)

TELAS = [
    ('inicio', 'Cruzadas e caça-palavras\nem português'),
    ('cruzadas', 'Toque, leia a dica\ne escreva'),
    ('caca', 'Ache as palavras em\ntodas as direções'),
    ('pequenos', 'A partir de 4 anos:\na dica é um desenho'),
    ('diario', 'Um desafio novo\ntodo dia'),
    ('fim', 'Pontos, recordes\ne conquistas'),
]
L, A = 1080, 1920


def fundo():
    img = Image.new('RGB', (L, A))
    d = ImageDraw.Draw(img)
    for y in range(A):
        t = y / (A - 1)
        d.line([(0, y), (L, y)], fill=tuple(int(VERDE[i] + (VERDE_CLARO[i] - VERDE[i]) * t) for i in range(3)))
    return img.convert('RGBA')


for n, (nome, frase) in enumerate(TELAS, 1):
    img = fundo()
    d = ImageDraw.Draw(img)
    fonte = ImageFont.truetype(FONTE, 72)
    d.multiline_text((L // 2, 70), frase, font=fonte, fill='white', anchor='ma', align='center', spacing=14)
    tela = Image.open(PASTA / 'originais' / f'{nome}.png').convert('RGBA')
    alt = 1600
    larg = tela.width * alt // tela.height
    tela = tela.resize((larg, alt), Image.LANCZOS)
    x, y = (L - larg) // 2, A - alt - 20 + 120
    # Moldura de celular simples: borda escura arredondada e sombra.
    borda = 18
    sombra = Image.new('RGBA', (L, A), (0, 0, 0, 0))
    ImageDraw.Draw(sombra).rounded_rectangle([x - borda + 8, y - borda + 16, x + larg + borda + 8, y + alt + borda + 16], 70, fill=(0, 0, 0, 90))
    img.alpha_composite(sombra.filter(ImageFilter.GaussianBlur(18)))
    ImageDraw.Draw(img).rounded_rectangle([x - borda, y - borda, x + larg + borda, y + alt + borda], 70, fill=(25, 30, 25, 255))
    mascara = Image.new('L', (larg, alt), 0)
    ImageDraw.Draw(mascara).rounded_rectangle([0, 0, larg - 1, alt - 1], 54, fill=255)
    img.paste(tela, (x, y), mascara)
    img.convert('RGB').save(PASTA / f'{n}-{nome}.png')
    print(f'ok: docs/loja/telas/{n}-{nome}.png')

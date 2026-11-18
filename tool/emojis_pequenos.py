"""Põe o campo "emoji" nas palavras usadas no nível Pequenos (4 a 5 anos).

O desenho é a dica desse nível. Rodar de novo não estraga nada.
Uso: python3 tool/emojis_pequenos.py
"""
import json
import unicodedata
from pathlib import Path

PASTA = Path(__file__).resolve().parent.parent / 'app/assets/palavras'

EMOJIS = {
    'animais': {
        'GATO': '🐱', 'PATO': '🦆', 'VACA': '🐄', 'LEÃO': '🦁', 'SAPO': '🐸',
        'URSO': '🐻', 'RATO': '🐭', 'LOBO': '🐺', 'ONÇA': '🐆', 'ZEBRA': '🦓',
        'PEIXE': '🐟', 'COBRA': '🐍', 'POLVO': '🐙', 'PORCO': '🐷',
        'ARARA': '🦜', 'TIGRE': '🐯', 'MACACO': '🐒', 'COELHO': '🐰',
        'GIRAFA': '🦒', 'CAVALO': '🐴', 'ABELHA': '🐝', 'CORUJA': '🦉',
        'OVELHA': '🐑', 'JACARÉ': '🐊', 'BALEIA': '🐳',
    },
    'frutas': {
        'UVA': '🍇', 'MAÇÃ': '🍎', 'PERA': '🍐', 'KIWI': '🥝', 'COCO': '🥥',
        'MANGA': '🥭', 'LIMÃO': '🍋', 'MELÃO': '🍈', 'BANANA': '🍌',
        'CEREJA': '🍒',
    },
    'alimentos': {
        'ARROZ': '🍚', 'PÃO': '🍞', 'OVO': '🥚', 'LEITE': '🥛', 'CARNE': '🥩',
        'MEL': '🍯', 'SOPA': '🍲', 'MILHO': '🌽', 'PEIXE': '🐟', 'PIZZA': '🍕',
        'QUEIJO': '🧀', 'BATATA': '🥔', 'FRANGO': '🍗', 'TOMATE': '🍅',
        'ALFACE': '🥬', 'PIPOCA': '🍿', 'SALADA': '🥗', 'BANANA': '🍌',
    },
    'corpo_humano': {
        'MÃO': '✋', 'OLHO': '👁️', 'BOCA': '👄', 'DEDO': '☝️', 'OSSO': '🦴',
        'UNHA': '💅', 'NARIZ': '👃', 'DENTE': '🦷', 'BRAÇO': '💪',
        'PERNA': '🦵', 'ORELHA': '👂', 'CABELO': '💇', 'LÍNGUA': '👅',
    },
    'meios_de_transporte': {
        'VAN': '🚐', 'TREM': '🚆', 'MOTO': '🏍️', 'TÁXI': '🚕', 'PNEU': '🛞',
        'CARRO': '🚗', 'AVIÃO': '✈️', 'BARCO': '⛵', 'NAVIO': '🚢',
        'METRÔ': '🚇', 'CANOA': '🛶', 'SKATE': '🛹', 'BALÃO': '🎈',
        'ÔNIBUS': '🚌', 'TRATOR': '🚜', 'LANCHA': '🚤',
    },
    'clima': {
        'SOL': '☀️', 'CHUVA': '🌧️', 'VENTO': '🌬️', 'NEVE': '❄️',
        'NUVEM': '☁️', 'RAIO': '⚡', 'GELO': '🧊', 'FRIO': '🥶',
        'CALOR': '🥵', 'TROVÃO': '⛈️',
    },
    'roupas': {
        'MEIA': '🧦', 'BLUSA': '👚', 'CALÇA': '👖', 'BONÉ': '🧢', 'LUVA': '🧤',
        'BOTA': '👢', 'TÊNIS': '👟', 'CAMISA': '👕', 'CHAPÉU': '👒',
        'CASACO': '🧥', 'SAPATO': '👞',
    },
    'animais_marinhos': {
        'POLVO': '🐙', 'LULA': '🦑', 'FOCA': '🦭', 'ORCA': '🐋', 'SIRI': '🦀',
        'PEIXE': '🐟', 'OSTRA': '🦪', 'CORAL': '🪸', 'BALEIA': '🐳',
    },
    'objetos_da_casa': {
        'CAMA': '🛏️', 'SOFÁ': '🛋️', 'PORTA': '🚪', 'GARFO': '🍴',
        'FACA': '🔪', 'CHAVE': '🔑', 'JANELA': '🪟', 'COLHER': '🥄',
        'PANELA': '🍳',
    },
}


def grade(w):
    return ''.join(c for c in unicodedata.normalize('NFD', w)
                   if unicodedata.category(c) != 'Mn')


faltando = []
for tema, mapa in EMOJIS.items():
    caminho = PASTA / f'{tema}.json'
    dados = json.loads(caminho.read_text(encoding='utf-8'))
    achadas = set()
    for p in dados['palavras']:
        e = mapa.get(p['palavra'])
        if e and p['dificuldade'] == 1 and 3 <= len(grade(p['palavra'])) <= 6:
            p['emoji'] = e
            achadas.add(p['palavra'])
    faltando += [f'{tema}:{w}' for w in mapa if w not in achadas]
    caminho.write_text(json.dumps(dados, ensure_ascii=False, indent=2) + '\n',
                       encoding='utf-8')
    print(f'{tema}: {len(achadas)} palavras com desenho')
if faltando:
    print('Não achei (ou não servem):', ', '.join(faltando))

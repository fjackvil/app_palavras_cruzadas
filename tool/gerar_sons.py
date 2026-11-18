"""Gera os sons do app (sintetizados aqui, sem direito autoral de terceiros).

Uso: python3 tool/gerar_sons.py
Saída: app/android/app/src/main/res/raw/som_*.wav
"""
import math
import struct
import wave
from pathlib import Path

TAXA = 22050
SAIDA = Path(__file__).resolve().parent.parent / 'app/android/app/src/main/res/raw'


def nota(freq, dur, vol=0.5):
    """Tom de sino: fundamental + harmônicos, ataque curto e queda suave."""
    n = int(TAXA * dur)
    amostras = []
    for i in range(n):
        t = i / TAXA
        env = min(1.0, t / 0.008) * math.exp(-3.2 * t / dur)
        v = (math.sin(2 * math.pi * freq * t)
             + 0.35 * math.sin(2 * math.pi * freq * 2 * t)
             + 0.12 * math.sin(2 * math.pi * freq * 3 * t))
        amostras.append(vol * env * v / 1.47)
    return amostras


def misturar(partes, total):
    """partes: lista de (inicio_seg, amostras)."""
    buf = [0.0] * int(TAXA * total)
    for ini, a in partes:
        k = int(TAXA * ini)
        for i, v in enumerate(a):
            if k + i < len(buf):
                buf[k + i] += v
    pico = max(abs(v) for v in buf) or 1
    return [v / pico * 0.8 for v in buf]


def salvar(nome, buf):
    SAIDA.mkdir(parents=True, exist_ok=True)
    with wave.open(str(SAIDA / f'{nome}.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(TAXA)
        w.writeframes(b''.join(struct.pack('<h', int(v * 32767)) for v in buf))


DO, MI, SOL, DO2, MI2, SOL2, DO3 = 523.25, 659.25, 783.99, 1046.5, 1318.5, 1568.0, 2093.0

# Vitória: arpejo alegre subindo.
salvar('som_vitoria', misturar(
    [(0.00, nota(DO, 0.5)), (0.10, nota(MI, 0.5)), (0.20, nota(SOL, 0.5)),
     (0.30, nota(DO2, 0.8))], 1.1))

# Recorde: fanfarra mais longa, com acorde no fim.
salvar('som_recorde', misturar(
    [(0.00, nota(SOL, 0.3)), (0.12, nota(SOL, 0.3)), (0.24, nota(SOL, 0.3)),
     (0.38, nota(DO2, 1.0)), (0.38, nota(MI2, 1.0, 0.35)),
     (0.38, nota(SOL2, 1.0, 0.3)), (0.62, nota(DO3, 0.8, 0.3))], 1.5))

# Conquista: brilho rápido, notas agudas.
salvar('som_conquista', misturar(
    [(0.00, nota(MI2, 0.35, 0.4)), (0.07, nota(SOL2, 0.35, 0.4)),
     (0.14, nota(DO3, 0.6, 0.4))], 0.8))

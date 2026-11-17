"""Gera a página web da política de privacidade a partir do mesmo texto
que o app mostra (app/assets/textos/politica-de-privacidade.md).

Uso (na raiz do repositório):
    python3 tool/gerar_politica_html.py

Saída: docs/privacidade/index.html — publique esse arquivo num endereço
público (GitHub Pages, Google Sites, site próprio) e use o link na Play
Console. Rode de novo sempre que mudar o texto.
"""
import html
import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ORIGEM = RAIZ / "app/assets/textos/politica-de-privacidade.md"
DESTINO = RAIZ / "docs/privacidade/index.html"


def inline(texto: str) -> str:
    t = html.escape(texto)
    return re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)


def converter(md: str) -> str:
    partes, paragrafo, lista = [], [], []

    def fechar():
        if paragrafo:
            partes.append("<p>" + "<br>".join(inline(l) for l in paragrafo) + "</p>")
            paragrafo.clear()
        if lista:
            partes.append("<ul>" + "".join(f"<li>{inline(i)}</li>" for i in lista) + "</ul>")
            lista.clear()

    for linha in md.splitlines():
        linha = linha.rstrip()
        if not linha:
            fechar()
        elif linha.startswith("## "):
            fechar()
            partes.append(f"<h2>{inline(linha[3:])}</h2>")
        elif linha.startswith("# "):
            fechar()
            partes.append(f"<h1>{inline(linha[2:])}</h1>")
        elif linha.startswith("- "):
            if paragrafo:
                fechar()
            lista.append(linha[2:])
        else:
            if lista:
                fechar()
            paragrafo.append(linha)
    fechar()
    return "\n".join(partes)


PAGINA = """<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Palavras Cruzadas · Política de privacidade</title>
<style>
  :root {{ color-scheme: light dark; }}
  body {{ font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
         max-width: 760px; margin: 0 auto; padding: 24px 16px 48px;
         line-height: 1.6; background: #f7faf4; color: #1b2a1b; }}
  h1 {{ color: #329932; }}
  h2 {{ margin-top: 2em; color: #2a7a2a; }}
  @media (prefers-color-scheme: dark) {{
    body {{ background: #121812; color: #e6efe4; }}
    h1, h2 {{ color: #66cc39; }}
  }}
</style>
</head>
<body>
{conteudo}
</body>
</html>
"""


def main() -> None:
    DESTINO.parent.mkdir(parents=True, exist_ok=True)
    DESTINO.write_text(
        PAGINA.format(conteudo=converter(ORIGEM.read_text(encoding="utf-8"))),
        encoding="utf-8",
    )
    print(f"ok: {DESTINO.relative_to(RAIZ)}")


if __name__ == "__main__":
    main()

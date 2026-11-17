"""Gera as páginas web da política de privacidade e dos termos de uso a
partir dos mesmos textos que o app mostra (app/assets/textos/*.md).

Uso (na raiz do repositório):
    python3 tool/gerar_politica_html.py

Saída:
    docs/privacidade/index.html         (política de privacidade)
    docs/privacidade/termos/index.html  (termos de uso)

Publique copiando a pasta docs/privacidade para o repositório público
palavras-cruzadas-privacidade (ver docs/play-console-privacidade.md).
Rode de novo sempre que mudar um dos textos.
"""
import html
import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PAGINAS = [
    ("politica-de-privacidade.md", "docs/privacidade/index.html",
     "Política de privacidade"),
    ("termos-de-uso.md", "docs/privacidade/termos/index.html",
     "Termos de uso"),
]


def inline(texto: str) -> str:
    t = html.escape(texto)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    return re.sub(r"(https://[^\s<]+[^\s<.,;:)])", r'<a href="\1">\1</a>', t)


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
<title>Palavras Cruzadas · {titulo}</title>
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
    for origem, destino, titulo in PAGINAS:
        md = (RAIZ / "app/assets/textos" / origem).read_text(encoding="utf-8")
        saida = RAIZ / destino
        saida.parent.mkdir(parents=True, exist_ok=True)
        saida.write_text(
            PAGINA.format(titulo=titulo, conteudo=converter(md)),
            encoding="utf-8",
        )
        print(f"ok: {destino}")


if __name__ == "__main__":
    main()

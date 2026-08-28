# 渣男骗子罪犯孙宇晨

单书仓库：改 Markdown 和 `book.yaml`，用 Docker 里的 Typst 出 PDF。文章作者是 Sally Jing。

## 需要什么

本机要有 Docker，并能拉取 `ghcr.io/typst/typst:0.15.1`。没有本机 Typst 回退。

中文字体放在 `fonts/`。不要改 `templates/`，除非要改版式。

`reference/` 是原 XeLaTeX 仓库，只作对照，不参与编译。

## 怎么出 PDF

1. 编辑 `content/rebuttal.md` 和 `book.yaml`。
2. 运行 `make pdf`。
3. 打开 `dist/<slug>.pdf`。当前样例是 `dist/scumbag-liar-criminal-justin-sun.pdf`。

Markdown 约定：`#` 是章，`##` 是节，空行分段，单独一行的 `---` 是分隔线。图片路径相对 `content/`。

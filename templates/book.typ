#import "@preview/cmarker:0.1.10": render

#let as-length(value) = {
  if type(value) == length { value } else { eval(str(value), mode: "code") }
}

#let as-float(value) = {
  if type(value) == float { value }
  else if type(value) == int { float(value) }
  else { float(eval(str(value), mode: "code")) }
}

#let as-bool(value, default) = {
  if value == none { default }
  else if type(value) == bool { value }
  else { default }
}

#let non-empty-str(value) = {
  type(value) == str and value != ""
}

#let require-str(cfg, key) = {
  if key not in cfg or not non-empty-str(cfg.at(key)) {
    panic("book.yaml 缺少 " + key)
  }
  cfg.at(key)
}

#let current-chapter() = context {
  let page-num = here().page()
  let headings = query(heading.where(level: 1))
  let on-page = headings.filter(h => h.location().page() == page-num)
  if on-page.len() > 0 {
    on-page.first().body
  } else {
    let before = headings.filter(h => h.location().page() < page-num)
    if before.len() > 0 { before.last().body } else { [] }
  }
}

#let book(cfg) = {
  let title = require-str(cfg, "title")
  let author = require-str(cfg, "author")
  let _slug = require-str(cfg, "slug")

  let lang = cfg.at("lang", default: "zh")
  let paper = cfg.at("paper", default: "a5")
  let fontsize = as-length(cfg.at("fontsize", default: "11pt"))
  let linespread = as-float(cfg.at("linespread", default: 1.4))
  let toc = as-bool(cfg.at("toc", default: true), true)
  let twoside = as-bool(cfg.at("twoside", default: true), true)
  let chapter-pagebreak = as-bool(cfg.at("chapter-pagebreak", default: true), true)
  let description = cfg.at("description", default: "")
  let cover = cfg.at("cover", default: none)
  let source = cfg.at("source", default: "content/book.md")
  if not non-empty-str(source) { source = "content/book.md" }
  let subtitle = cfg.at("subtitle", default: "")
  if subtitle == none { subtitle = "" }
  let accent-raw = cfg.at("accent", default: "#E31C23")
  let accent = if non-empty-str(accent-raw) { rgb(accent-raw) } else { rgb("#E31C23") }
  let disclaimer = cfg.at("disclaimer", default: ())
  if type(disclaimer) == str and non-empty-str(disclaimer) {
    disclaimer = (disclaimer,)
  } else if type(disclaimer) != array {
    disclaimer = ()
  }

  let margin-cfg = cfg.at("margins", default: (:))
  if type(margin-cfg) != dictionary { margin-cfg = (:) }
  let margins = (
    top: as-length(margin-cfg.at("top", default: "20mm")),
    bottom: as-length(margin-cfg.at("bottom", default: "22mm")),
    inside: as-length(margin-cfg.at("inside", default: "18mm")),
    outside: as-length(margin-cfg.at("outside", default: "16mm")),
  )

  let fonts = cfg.at("fonts", default: (:))
  if type(fonts) != dictionary { fonts = (:) }
  let serif = fonts.at("serif", default: none)
  let sans = fonts.at("sans", default: none)
  let latin = fonts.at("latin", default: "Libertinus Serif")
  if not non-empty-str(serif) { panic("book.yaml 缺少 fonts.serif") }
  if not non-empty-str(sans) { panic("book.yaml 缺少 fonts.sans") }
  if not non-empty-str(latin) { latin = "Libertinus Serif" }

  let page-size = if paper == "a5" or paper == "a4" {
    (paper: paper)
  } else if paper == "5x8" {
    (width: 5in, height: 8in)
  } else {
    panic("book.yaml paper 只支持 a5、a4、5x8")
  }

  let running-header = context {
    set text(font: sans, size: 8pt)
    let n = counter(page).get().first()
    if twoside {
      if calc.odd(n) {
        align(right, current-chapter())
      } else {
        align(left, title)
      }
    } else {
      title + h(1fr) + counter(page).display()
    }
  }

  let running-footer = context {
    set text(font: sans, size: 8pt)
    let n = counter(page).get().first()
    let shown = counter(page).display()
    if twoside {
      if calc.odd(n) { align(right, shown) } else { align(left, shown) }
    } else {
      []
    }
  }

  set document(
    title: title,
    author: author,
    description: if non-empty-str(description) { description } else { none },
  )
  set text(
    lang: lang,
    size: fontsize,
    font: (
      (name: latin, covers: "latin-in-cjk"),
      serif,
    ),
  )
  set par(justify: true, first-line-indent: 0pt, leading: fontsize * linespread)
  set heading(numbering: none)

  if chapter-pagebreak {
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }
  }

  set page(
    ..page-size,
    margin: margins,
    numbering: "1",
    header: running-header,
    footer: running-footer,
  )

  let source-path = if source.starts-with("/") { source } else { "/" + source }

  if non-empty-str(cover) {
    let cover-path = if cover.starts-with("/") { cover } else { "/" + cover }
    page(
      header: none,
      footer: none,
      numbering: none,
      margin: 0pt,
    )[
      #align(center + horizon)[
        #image(cover-path, width: 100%, height: 100%, fit: "contain")
      ]
    ]
    counter(page).update(1)
  } else {
    page(
      header: none,
      footer: none,
      numbering: none,
    )[
      #set text(font: sans, fill: rgb("#161618"))
      #block(width: 100%, height: 100%)[
        #v(22%)
        #rect(width: 16mm, height: 2.2pt, fill: accent, stroke: none)
        #v(12mm)
        #text(size: 32pt)[#title]
        #if non-empty-str(subtitle) {
          v(4mm)
          text(size: 40pt, fill: accent)[#subtitle]
        }
        #v(14mm)
        #text(size: 11pt)[作者#h(2em)#author]
        #v(1fr)
        #if disclaimer.len() > 0 {
          text(size: 9pt, fill: rgb("#5C5C62"))[#disclaimer.at(0)]
          if disclaimer.len() > 1 {
            v(3.2mm)
            text(size: 9pt, fill: accent)[#disclaimer.at(1)]
          }
        }
      ]
    ]
    counter(page).update(1)
  }

  if toc {
    set page(header: none, footer: running-footer)
    outline(title: [目录])
    pagebreak()
    set page(header: running-header, footer: running-footer)
  }

  render(
    read(source-path),
    h1-level: 1,
    set-document-title: false,
  )
}

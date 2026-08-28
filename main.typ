#import "templates/book.typ": book

#let yaml-file = sys.inputs.at("yaml", default: "book.yaml")
#let cfg = yaml(yaml-file)
#book(cfg)

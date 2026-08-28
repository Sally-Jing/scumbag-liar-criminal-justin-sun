IMAGE := ghcr.io/typst/typst:0.15.1
YAML ?= book.yaml
SLUG := $(shell awk '/^slug:/{print $$2; exit}' $(YAML))

.PHONY: pdf
pdf:
	@command -v docker >/dev/null 2>&1 || { echo "需要 Docker 才能编译 PDF。"; exit 1; }
	@test -n "$(SLUG)" || { echo "$(YAML) 缺少 slug。"; exit 1; }
	mkdir -p dist
	docker run --rm \
		-v "$(CURDIR)":/work \
		-w /work \
		$(IMAGE) \
		compile \
			--root /work \
			--font-path /work/fonts \
			--package-path /work/vendor/typst \
			--input yaml=$(YAML) \
			main.typ \
			/work/dist/$(SLUG).pdf

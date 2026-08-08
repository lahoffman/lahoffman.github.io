# =============================================================================
# CV + site build
# =============================================================================
#   make cv      regenerate everything from _data/cv_source.yml (site + PDF)
#   make site    regenerate only the website files (no LaTeX needed)
#   make pdf     regenerate only files/cv.pdf
#   make check   fail if generated files are stale (used by CI)
#   make serve   build the CV, then run the Jekyll dev server
#   make clean   remove LaTeX build litter
#
# `make pdf` needs a LaTeX toolchain. On macOS the small option is TinyTeX:
#   curl -sL https://yihui.org/tinytex/install-bin-unix.sh | sh
#   tlmgr install moderncv fontawesome5 xurl enumitem latexmk
# =============================================================================

PYTHON  ?= python3
LATEXMK ?= latexmk

.PHONY: cv generate site pdf check serve clean deps

cv: generate pdf

# One invocation generates cv.md, the collections AND cv/cv.tex, then prunes
# any files a previous build left behind. Always run it as a unit.
generate:
	@$(PYTHON) scripts/build_cv.py

site: generate

pdf: generate
	@command -v $(LATEXMK) >/dev/null 2>&1 || { \
	  echo "ERROR: latexmk not found. Install TinyTeX or MacTeX (see Makefile header),"; \
	  echo "       or just push -- the GitHub Action builds the PDF for you."; exit 1; }
	@cd cv && $(LATEXMK) -pdf -interaction=nonstopmode -halt-on-error cv.tex >/dev/null
	@mkdir -p files && cp cv/cv.pdf files/cv.pdf
	@echo "Wrote files/cv.pdf"

check:
	@$(PYTHON) scripts/build_cv.py --check

serve: cv
	bundle exec jekyll serve --livereload

deps:
	$(PYTHON) -m pip install --upgrade pyyaml

clean:
	@cd cv && rm -f cv.aux cv.log cv.out cv.fls cv.fdb_latexmk cv.synctex.gz
	@echo "Cleaned LaTeX build files"

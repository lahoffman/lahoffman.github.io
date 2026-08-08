# =============================================================================
# CV + site build
# =============================================================================
#   make cv      regenerate everything from _data/cv_source.yml (site + PDF)
#   make site    regenerate only the website files (no LaTeX needed)
#   make pdf     regenerate only files/cv.pdf
#   make texdeps check the LaTeX toolchain and print how to fix it
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

.PHONY: cv generate site pdf texdeps check serve clean deps

cv: generate pdf

# One invocation generates cv.md, the collections AND cv/cv.tex, then prunes
# any files a previous build left behind. Always run it as a unit.
generate:
	@$(PYTHON) scripts/build_cv.py

site: generate

pdf: generate
	@if ! command -v $(LATEXMK) >/dev/null 2>&1; then \
	  echo "SKIPPED: files/cv.pdf not rebuilt -- latexmk is not installed."; \
	  echo "         Site files are up to date. Run 'make texdeps' for setup help,"; \
	  echo "         or push and let the Build CV Action compile the PDF."; \
	elif ! kpsewhich moderncv.cls >/dev/null 2>&1; then \
	  echo "SKIPPED: files/cv.pdf not rebuilt -- moderncv.cls is missing from your"; \
	  echo "         LaTeX installation. Site files are up to date."; \
	  echo "         Run 'make texdeps' for the fix."; \
	elif ! kpsewhich fontawesome5.sty >/dev/null 2>&1; then \
	  echo "SKIPPED: files/cv.pdf not rebuilt -- fontawesome5.sty is missing from"; \
	  echo "         your LaTeX installation (moderncv needs it for its icons)."; \
	  echo "         Site files are up to date. Run 'make texdeps' for the fix."; \
	elif ! (cd cv && $(LATEXMK) -pdf -interaction=nonstopmode -halt-on-error cv.tex >/dev/null 2>&1); then \
	  echo "SKIPPED: files/cv.pdf not rebuilt -- LaTeX failed. Site files are up"; \
	  echo "         to date. Most likely another package is missing; the missing"; \
	  echo "         file is named in cv/cv.log:"; \
	  grep -m1 "not found" cv/cv.log 2>/dev/null | sed 's/^/           /' || true; \
	  echo "         Install it with: sudo tlmgr install <name-without-extension>"; \
	  echo "         Or push and let the Build CV Action compile the PDF."; \
	else \
	  mkdir -p files && cp cv/cv.pdf files/cv.pdf && echo "Wrote files/cv.pdf"; \
	fi

# Diagnose the LaTeX toolchain and print the exact command to fix it.
texdeps:
	@echo "Checking the LaTeX toolchain..."
	@command -v $(LATEXMK) >/dev/null 2>&1 \
	  && echo "  latexmk      OK  ($$(command -v $(LATEXMK)))" \
	  || echo "  latexmk      MISSING"
	@kpsewhich moderncv.cls >/dev/null 2>&1 \
	  && echo "  moderncv.cls OK  ($$(kpsewhich moderncv.cls))" \
	  || echo "  moderncv.cls MISSING"
	@kpsewhich fontawesome5.sty >/dev/null 2>&1 \
	  && echo "  fontawesome5 OK" || echo "  fontawesome5 MISSING"
	@echo ""
	@echo "To install what is missing (BasicTeX/MacTeX needs sudo):"
	@echo "  sudo tlmgr install moderncv fontawesome5 xurl enumitem"
	@echo ""
	@echo "If tlmgr refuses with 'Local TeX Live is older than remote repository',"
	@echo "your distribution is a release behind CTAN. Cross-release upgrade:"
	@echo "  curl -L https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh -o /tmp/upd.sh"
	@echo "  sudo sh /tmp/upd.sh --update"
	@echo "  sudo tlmgr update --self --all"
	@echo "  sudo tlmgr install moderncv fontawesome5 xurl enumitem"
	@echo ""
	@echo "Or skip local LaTeX entirely: push, and the Build CV Action makes the PDF."

check:
	@$(PYTHON) scripts/build_cv.py --check

serve: cv
	bundle exec jekyll serve --livereload

deps:
	$(PYTHON) -m pip install --upgrade pyyaml

clean:
	@cd cv && rm -f cv.aux cv.log cv.out cv.fls cv.fdb_latexmk cv.synctex.gz
	@echo "Cleaned LaTeX build files"

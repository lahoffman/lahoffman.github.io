# How the CV works

There is **one file to edit**: `_data/cv_source.yml`.

Everything else is generated from it and is overwritten on every build. Files
carrying a `DO NOT EDIT` banner are generated — changes to them will be lost.

```
                        _data/cv_source.yml
                                 |
                     scripts/build_cv.py
                                 |
      +--------------+-----------+-----------+---------------+
      |              |           |           |               |
  _pages/cv.md  _publications/  _talks/  _teaching/     cv/cv.tex
   (CV page)     (/publications) (/talks) (/teaching)        |
                                                        files/cv.pdf
                                                     (download link)
```

## Updating the CV

1. Edit `_data/cv_source.yml`.
2. Either run `make cv` locally, or just commit and push — the **Build CV**
   GitHub Action regenerates everything and commits the result back.

Adding a paper means adding one block to the `publications:` list. That single
block produces the CV entry, the `/publications/` page entry, and the line in
the PDF. There is nowhere else to update.

## Commands

| Command | What it does |
| --- | --- |
| `make cv` | Regenerate everything, including `files/cv.pdf` |
| `make site` | Regenerate website files only (no LaTeX needed) |
| `make texdeps` | Check the LaTeX toolchain and print how to fix it |
| `make check` | Fail if generated files are stale — used by CI |
| `make serve` | Rebuild, then run the Jekyll dev server |
| `make clean` | Remove LaTeX build litter |

`make site` works with only Python + PyYAML (`make deps` installs it).
`make pdf` additionally needs LaTeX. On macOS the lightweight option is TinyTeX:

```sh
curl -sL https://yihui.org/tinytex/install-bin-unix.sh | sh
tlmgr install moderncv fontawesome5 xurl enumitem latexmk
```

If LaTeX is missing or incomplete, `make cv` no longer fails: it regenerates
all the site files, prints a `SKIPPED:` line explaining what is absent, and
exits cleanly. `make texdeps` then diagnoses the toolchain and prints the exact
command to fix it.

A common macOS wrinkle: BasicTeX installs to a root-owned tree, so `tlmgr`
needs `sudo`. And if `tlmgr` reports *"Local TeX Live (N) is older than remote
repository (N+1)"*, your distribution is a full release behind CTAN and cannot
install anything until it crosses releases:

```sh
curl -L https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh -o /tmp/upd.sh
sudo sh /tmp/upd.sh --update
sudo tlmgr update --self --all
sudo tlmgr install moderncv fontawesome5 xurl enumitem
```

If you would rather not install LaTeX at all, skip it — push and let the Action
build the PDF. `make site` still works fine without it.

## The YAML in brief

**Sections and their order** come from `section_order:` at the top. Reorder or
delete entries there and both the website and the PDF follow. No code changes.

**Publications** — each entry takes:

```yaml
  - slug: short-name-for-the-url
    date: 2025-02-01        # required by Jekyll; controls ordering
    year: 2025              # shown in the CV
    authorship: first       # first | co  -> which CV subsection
    authors: Hoffman, L., F. Massonnet, and A. Sticker.
    title: Full title of the paper.
    venue: Journal Name
    details: 2, e2025JH000669
    doi: 10.1029/2025JH000669
    excerpt: One or two sentences shown on the publication page.
```

Optional: `status: in_progress` (renders as "In progress" and, with
`site: false`, is kept off the website until it is published).

**Talks** — two distinct fields:

```yaml
  - slug: 2025-esip-machine-learning-cluster
    date: 2025-01-01
    year: 2025
    group: invited                # invited | contributed -> which CV section
    format: Oral presentation     # Oral presentation | Poster | Seminar
    title: Explainable AI for Arctic sea ice prediction   # the TALK's title
    meeting: Earth Science Information Partners (ESIP) Machine Learning Cluster Meeting
    venue: Earth Science Information Partners             # host organisation
    location: Virtual
```

`title:` is the talk's own title and `meeting:` is the event it was given at.
The CV line renders as:

> 2025: "Explainable AI for Arctic sea ice prediction." Earth Science
> Information Partners (ESIP) Machine Learning Cluster Meeting. Virtual. Oral
> presentation.

Entries still carrying `title: TODO` fall back to the meeting name alone, so the
site and PDF stay correct while you fill them in — and each build reports how
many are left. If a talk genuinely had no distinct title, delete its `title:`
line entirely and it renders from `meeting:` permanently, with no warning.

**Teaching** — `teaching:` holds courses, `guest_lectures:` holds one-off
lectures. Both feed the `/teaching/` collection.

**Talks split across sections** by their `group:` value, mapped near the top of
the YAML:

```yaml
talk_sections:
  invited_talks: invited
  presentations: presentation
  meetings_workshops: meeting
```

Change a talk's `group:` to move it between sections; add a line here (and to
`section_order:`) to create a new one.

## Compact sections

Mentorship, leadership, service and teaching use a one-line-per-entry style:

```yaml
mentorship:
  compact: true
  entries:
    - dates: Fall 2024–Spring 2025
      who: Antonio Martinez Soares
      role: Master's Student
      org: Université catholique de Louvain
```

renders as `Fall 2024–Spring 2025 | Antonio Martinez Soares, Master's Student |
Université catholique de Louvain`. The line is assembled from whichever of
`who`, `role`, `org`, `note` and `text` are present, so you can use as few as
you like. Set `compact: false` on a section to go back to bulleted entries.

Teaching entries additionally take a `summary:` — the one-line version shown on
the CV — while keeping their `bullets:` for the fuller `/teaching/` page.

## Bold position titles

In compact sections the `role:` field is rendered in bold — that is the only
part that bolds, so keep the position title there and put everything else in
`text:`:

```yaml
    - dates: 2025–Present
      role: Co-Lead                       # <- bold
      text: OAISIS Working Group; ...     # <- plain
```

Teaching entries carry both: `role:` is the bolded position on the CV, while
`title:` (e.g. "Instructor, Climate Change and the Ocean") still names the
`/teaching/` collection page. Guest lectures default to `Guest Lecturer` unless
you set `role:` yourself.

Turn it off globally with `bold_roles: false`.

## Bold author name

Your name is emboldened automatically in every publication author list. The
default matches `Hoffman, L.` and `L. Hoffman`; override with:

```yaml
basics:
  bold_name:
    - Hoffman, L.
    - L. Hoffman
```

## Adding a brand-new section

Two steps, both in `_data/cv_source.yml`:

1. Add the content under a new top-level key.
2. **Add that key to `section_order:`** — this is the step that makes it appear.
   A section not listed there is not rendered anywhere. The build prints a
   warning if you forget.

No Python changes are needed. An unrecognised key is rendered generically, in
any of these shapes:

```yaml
personal_interests:                       # list with optional hint labels
  - text: Bouldering, backpacking, guitar, violin, yoga, and cats.

personal_interests:                       # or plain bullets
  - Bouldering and backpacking
  - Guitar and violin

personal_interests: A sentence of prose.  # or a single paragraph
```

The hint column (the left-hand label in the PDF) is picked up from any of
`date`, `dates`, `label`, `term`, or `year` on an entry — the same shape the
`honors:` and `activities:` sections use.

The heading is derived from the key: `personal_interests` becomes
"Personal interests" on the site and "Personal Interests" in the PDF. To choose
your own wording, add an override:

```yaml
section_titles:
  personal_interests: Outside the Lab
```

## Why pipes are written as `&#124;`

Your `_config.yml` runs kramdown with `input: GFM`. That parser treats *any*
line containing a `|` as a table — it does not require a header separator row.
A literal pipe in the CV therefore renders as a stray bordered table on the
website.

The generator writes `&#124;` in markdown instead. Table detection scans raw
text and sees no pipe, while `entity_output: as_char` turns the entity back
into a real `|` in the final HTML — so the page shows the pipe you want with no
table. The PDF is unaffected and uses `\textbar{}`.

This happens automatically for every field, so you can type ordinary pipes in
`cv_source.yml`. A build-time guard warns if a raw pipe ever reaches
`_pages/cv.md`.

## Emoji and symbols

The website renders any Unicode you like. `pdflatex` cannot typeset most
symbols and emoji, so the build silently drops them from the PDF and prints a
note telling you which characters it removed. Accented Latin characters
(é, è, ç, ü …) are fine in both.

If you want a symbol in the PDF badly enough, switch the engine to XeLaTeX by
adding `$pdflatex = 'xelatex %O %S';` to a `cv/.latexmkrc` and using a font with
the glyph — but dropping it is usually the easier answer.

## Styling the PDF

`cv/preamble.tex` holds the LaTeX preamble — document class, moderncv style and
colour, margins, packages. It is created once and then belongs to you: the
generator never overwrites it. Change `\moderncvstyle{classic}` to `banking`,
`casual`, or `oldstyle`, or `\moderncvcolor{blue}` to another colour, and
rebuild.

`cv/cv.tex` is the generated body. Do not edit it.

## Caveat: talk and publication dates

Your source CV recorded years only, but Jekyll requires a full `YYYY-MM-DD` for
every collection entry. Where the real month was unknown, dates are placeholders
in January, with the day used to preserve your CV's ordering within each year.
They are correct in ordering but not in month. Replace them with real dates in
`cv_source.yml` as convenient — the day-level ordering trick stays valid either
way, since sorting is newest-date-first.

## If a generated file goes missing

`.cv-generated.json` records what the last build produced. Anything in that list
that a later build no longer produces gets deleted automatically — that is how
renaming a `slug` cleans up its old file. Delete the manifest if it ever gets
out of sync; the next build recreates it.

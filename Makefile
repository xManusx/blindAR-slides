.PHONY: all testcode presentation notes

all: presentation notes

CXX = clang++

CXXOPTS= -Weverything -Wno-missing-prototypes -Wno-ignored-qualifiers -Wno-unused-variable -Wno-c++11-extensions -Wno-global-constructors -Wno-padded -stdlib=libc++ -Werror -std=c++11 -Wno-non-virtual-dtor -Wno-c++98-compat -Wno-missing-variable-declarations

SNIPPETS := $(wildcard listings/*.c++)

OBJS := $(notdir $(SNIPPETS))
OBJS := $(addprefix /var/tmp/, $(OBJS))
OBJS := $(OBJS:.c++=.o)

DOTS := $(wildcard dot/*.dot)

DOTPDF := $(notdir $(DOTS))
DOTPDF := $(addprefix out/, $(DOTPDF))
DOTPDF := $(DOTPDF:.dot=.dot.pdf)

testcode: $(OBJS)

/var/tmp/%.o: listings/%.c++
	$(CXX) -c $< $(CPPOPTS) $(CXXOPTS) $(CPPFLAGS) $(CXXFLAGS) -o $@

out/%.dot.pdf: dot/%.dot
	dot -Tpdf -o $@ $<

TEX := $(wildcard content/*.tex)
STY := $(wildcard *.sty)

LTX=$(shell which pdflatex)
ifeq ($(LTX),"")
    UNAME_S=$(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        LTX=/usr/local/texlive/2012/bin/x86_64-darwin/pdflatex
    endif
endif

OPTS=--synctex=1 --output-directory=out

presentation: out/presentation.pdf

notes: out/notes.pdf

# This is necessary as pdftex and xetex require the output directory to have the subdirectory as the directory where the tex files reside
out/content:
	mkdir out/content

out/%.pdf: %.tex talk.tex $(TEX) $(SNIPPETS) $(STY) $(DOTPDF) out/content
	$(LTX) $(OPTS) $<
#	$(LTX) $(OPTS) $<

out/notes.pdf: out/presentation.pdf

clean:
	rm -rf out/*
	rm -f $(OBJS)

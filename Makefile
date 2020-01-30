all: main.pdf

main.pdf: main.tex
	tectonic $<

.PHONY:
clean:
	rm -f main.pdf

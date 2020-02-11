# Chalmers MSc Thesis Template

This is a template for master's theses at Chalmers University of Technology,
based on [the template provided by the CSE department][0]. To use it, clone
this repository into a directory named `template`:

```
git clone git@github.com:ayberkt/chalmers-msc-thesis-template.git template
```

Then create your, say `file.tex`, which should look like this:

```
\input{template/template}

\title{The Title}
\author{John Doe}

\supervisor{Joe Bloggs}
\departmentofsupervisor{Computer Science and Engineering}

\examiner{Richard Roe}
\departmentofexaminer{Computer Science and Engineering}

\division{The division name}

\begin{document}

\maketitlepage{}

\begin{abstract}
  Write an abstract here.
\end{abstract}

\begin{acknowledgements}
  Thank some people here...
\end{acknowledgements}

\makelists{}

\chapter{Introduction}

\end{document}
```

This template assumes that you will be using `xelatex/lualatex` (which you
probably should) with the `fontspace` package. It is assumed that you have
system-wide installation of certain fonts: [XITS][1] and XITS Math. You can
override the fonts with `\setmainfont{font-name}` and
`\setmathfont{math-font-name}` although [the official guidelines][2] state that
you should use Times New Roman

[0]: https://www.overleaf.com/project/58d3eb5d6b629a1f6a7c7538
[1]: https://en.wikipedia.org/wiki/XITS_font_project
[2]: https://student.portal.chalmers.se/en/chalmersstudies/masters-thesis/Pages/design-and-publish-masters-thesis.aspx

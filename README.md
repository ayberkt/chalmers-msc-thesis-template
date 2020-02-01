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

[0]: https://www.overleaf.com/project/58d3eb5d6b629a1f6a7c7538

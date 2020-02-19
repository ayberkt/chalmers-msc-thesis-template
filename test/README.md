# Testing chalmers-msc-thesis-template

In order to make sure that our changes only introduce the intended visual changes we have these golden tests.

## How to run the tests

There is a testing script called `run-tests.sh` which should be used to run the tests.

### Required packages

In order to typeset the documents and produce PDFs you need to have
the XITS fonts and `tectonic` installed.

For installation instructions for `tectonic`, please go
[here](https://tectonic-typesetting.github.io/en-US/install.html).
The XITS fonts are usually included in the TeXLive distributions, see
your distribution for the available choices.

Apart from building the PDFs the testing script also compares the PDFs
by converting them to PostScript and therefore depends on `pdftops`,
which may be available from `poppler-utils` (Ubuntu/Debian) or from
`xpdf`.

### Using Docker

An alternative way to run the tests is to use Docker image that is
used in the GitHub CI. The Dockerfile for this image is located in the
`$PROJECTROOT/.github/actions/tester/Dockerfile`, where $PROJECTROOT is the location of the template directory.

1.  Build the docker image: `$ docker build -t template-tester $PROJECTROOT/.github/actions/tester`
1.  Run the tests: `$ docker run -v $PROJECTROOT/:/template template-tester /bin/sh /templat/test/run-tests.sh`
1.  Success

You can provide command line arguments to the script on the second
line if you want.

### Script usage

```
Usage: $0 [action] [test1, test2..]

If no action is specified the script will run the all tests in this directory.
If an action is specified the script will only perform that action for the specified tests that follows the action.

Actions:
 --generate    Generates a golden file for the specified test
 --test        Run the specified test (useful for debugging specific tests)

Examples:
$ sh run-tests.sh --generate sample1            Generates a golden file for sample1
$ sh run-tests.sh --test sample1 sample2        Run sample1 and sample2 tests
$ sh run-tests.sh                               Run all tests
```

The script returns the number of failed tests as its exit code. This
means that if all tests pass the exit code would be 0, which
coincidentally is the Unix standard exit code for signalling success.

## Golden testing

Golden testing uses so called "golden files" as the expected output of
the system under test. In our case the system under test is our LaTeX
template and the expected output is a PDF file. The tests then run and
produces new PDF files, which are compared to the golden files (i.e. the
corresponding `main.golden.pdf`)

If the comparison fails, then something has changed in the template that
caused the new PDF to be different to the golden file and manual
inspection is needed to choose whether the differences are expected or
not.

Because certain metadata is stored in the files, we cannot compare PDF
files directly (two identical PDF's compiled on different days will
have different metadata), therefore we convert them to PostScript
files with `pdftops`.

## How to add or update tests

First, let's talk about some conventions. The test script assumes that
the source file for the test will reside in their own directory in the
test/ directory (i.e. this directory). The source file is expected to be
named `main.tex` and the corresponding golden file should be named
`main.golden.pdf`.

The template and all necessary files will be copied to `template/` so
`main.tex` should start with `\include{template/template}` as described
in the root README.

If there are no `main.tex` or no `main.golden.pdf` then that test will fail.

### Adding a test

1.  Create a new directory in the test/ directory
1.  Create a `main.tex` inside that directory with some LaTeX inside
1.  Generate a golden file for it, for instance with `sh run-tests.sh
    --generate YOURDIR`, where YOURDIR is the name of your new
    directory.
1.  Add and commit your new directory and its content (make sure you
    actually add the golden file, as it might be ignored since it is a
    PDF).
1.  Success!

No extra configuration is then needed, the script will pick up the new test automagically.

### Updating a test

When the template is updated we might also have to update the tests. In
some cases we need to edit the source file (i.e. if we add mandatory
macros or other major changes), in some cases only the golden file
(i.e. if the style is changed).

When updating the test it is worth keeping in mind that the test will
probably test, but that is okay.

Failing tests copies the produced (non-matching) PDF into the source
directory and names it `main.mismatch.pdf`. This makes it easy for us to
inspect the file and visually review the differences bewteen the golden
file and the mismatched one. Once we're certain that the mismatched
version is what we want we can simply replace the golden file with the
mismatched file and commit the changes.

1.  (Optional) Edit `main.tex`.
1.  Run the test, e.g `run-tests.sh --test YOURDIR`
1.  Review the differences between `main.golden.pdf` and
    `main.mismatched.pdf`.
1.  If the mismatched file contains no unwanted changes replace golden
    file with mismatched file: `mv main.mismatched.pdf main.golden.pdf`.
1.  Add and commit the updated test (make sure you actually add the
    golden file, as it might be ignored since it is a PDF).
1.  Success!

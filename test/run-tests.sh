#! /bin/sh

# Make sure we are in the test/ directory
cd "$(dirname $0)"

PDFTOPS_ARGS=""

# Setup build directory
#
# Arguments:
#  * $1 -- Directory containing current test sources (relative to test/-directory)
# Error code: 0 if the build directory could be correctly created, 1 otherwise
# Output: Absolute path to build directory if error code is 0, otherwise error messages.
#
# Example:
# ```
# DIR=$(setup_build_dir sample1)
# if [ $? ] ; then
#   echo "setup_build_dir set up a directory at ${DIR}"
# else
#   echo "setup_build_dir failed: ${DIR}"
# ```
setup_build_dir() {
    TESTNAME=${1:-undefined}
    if [ "${TESTNAME}" = "undefined" ]; then
	echo "No test given"
	return 1
    fi
    if [ ! -d "${PWD}/${TESTNAME}" ]; then
	echo "Could not find the sources ${PWD}/${TESTNAME} for test ${TESTNAME}"
	return 1
    fi
    SRCDIR="${PWD}/${TESTNAME}"
    if [ ! -f "${SRCDIR}/main.tex" ]; then
	echo "Could not find test source file ${SRCDIR}/main.tex"
	return 1
    fi

    # Setup temporary test directory where we'll run the test
    TESTDIR=$(mktemp -d)
    TEMPLATEDIR="${TESTDIR}/template/"
    mkdir ${TEMPLATEDIR}

    # Copy template to template dir
    cp -r ../frontmatter ../figure ${TEMPLATEDIR}
    cp ../template.tex ../settings.tex ${TEMPLATEDIR}

    # Copy latex source to template dir
    cp -r "${SRCDIR}"/* "${TESTDIR}"
    echo "${TESTDIR}"
}

# Runs a given (golden) test.
#
# Arguments:
#   $1 -- Directory containing current test (relative to test/-directory)
# Exit code:
#   0 if the test passed, 1 if the script fails, 2 if LaTeX fails and 3 if pdftops fails
# Side-effects:
#   If the test fails, the offending PDF is copied to $1/main.mismatch.pdf
run_test() {
    TESTNAME="${1:-undefined}"
    SRCDIR="${PWD}/${TESTNAME}"
    TESTDIR="$(setup_build_dir ${TESTNAME})"
    if [ ! $? -eq 0 ] ; then
	echo "An error has occurred: ${TESTDIR}"
	return 1
    fi

    if [ -f "${SRCDIR}/main.golden.pdf" ]; then
	if ! pdftops ${PDFTOPS_ARGS} "${SRCDIR}/main.golden.pdf" "${TESTDIR}/main.golden.ps"; then
	    echo "${TESTNAME}: pdftops failed on the golden file, see previous output."
	    return 1
	fi
    fi

    if ! tectonic "${TESTDIR}/main.tex"; then
	echo "${TESTNAME}: LaTeX failed, see previous output."
	return 2
    elif ! pdftops ${PDFTOPS_ARGS} "${TESTDIR}/main.pdf" "${TESTDIR}/main.ps" ; then
	echo "${TESTNAME}: pdftops failed, see previous output."
	return 3
    elif ! comparepdf --verbose=2 "${TESTDIR}/main.pdf" "${TESTDIR}/main.golden.pdf" > ; then
	echo "${TESTNAME}: Failed! PDF's don't match."
	echo "${TESTNAME}: Failed PDF can be found in ${SRCDIR}/main.mismatch.pdf"
	cp "${TESTDIR}/main.pdf" "${SRCDIR}/main.mismatch.pdf"
	return 1
    else
    	echo "${TESTNAME}: Passed!"
	return 0
    fi
}

# Generates a new golden file from existing sources
#
# Arguments:
#   $1 -- Directory containing current test sources (relative ot test/-directory)
# Exit code:
#   0 if successful, 1 if error the script failed before invoking LaTeX and 2 if LaTeX fails
# Side-effects:
#   Generates a "golden" PDF and places it in $1/main.golden.pdf
generate_golden() {
    TESTDIR="$(setup_build_dir ${1:-undefined})"
    SRCDIR="${PWD}/${1:-undefined}"
    if [ ! $? -eq 0 ] ; then
	echo "An error has occurred: ${TESTDIR}"
	exit 1
    fi

    if tectonic "${TESTDIR}/main.tex"; then
	cp "${TESTDIR}/main.pdf" "${SRCDIR}/main.golden.pdf"
    else
	return 2
    fi
}

# Parse command line arguments
#
# Supported formats:
#
# $0                              -- No arguments     -> run all tests
# $0 --test test1 [test2, ..]     -- $1 == --test     -> run some tests
# $0 --generate [test1,test2,..]  -- $1 == --generate -> generate golden files for some test
if [ $# -gt 0 ] && [ "$1" = "--generate" ];  then
    shift;
    for t in $@; do
	echo "Generating golden files for test ${t}"
	generate_golden ${t}
    done
elif [ $# -gt 0 ] && [ "$1" = "--test" ]; then
    shift;
    echo "Running selective testing for test(s): $@"
    FAILED=0
    for t in $@; do
	run_test ${t}
	FAILED=$((${FAILED} + $?))
    done
    exit ${FAILED}
elif [ $# -gt 0 ] && [ ${1:0:2} = "--" ]; then
    echo "Unrecognized option $1"
    echo "Usage: $0 [action] [test1, test2..]"
    echo
    echo "If no action is specified the script will run the all tests in this directory."
    echo "If an action is specified the script will only perform that action for the specified tests that follows the action."
    echo
    echo "Actions:"
    echo -e "--generate\tGenerates a golden file for the specified test"
    echo -e "--test\t\tRun the specified test (useful for debugging specific tests)"
    echo
    echo "Examples:"
    echo -e "$ sh run-tests.sh --generate sample1\t\t\tGenerates a golden file for sample1"
    echo -e "$ sh run-tests.sh --test sample1 sample2\t\tRun sample1 and sample2 tests"
    echo -e "$ sh run-tests.sh\t\t\t\t\tRun all tests"
else
    DIRS=$(ls -d */)
    echo "Running tests.."
    FAILED=0
    for t in ${DIRS}; do
	run_test $(basename "${t}")
	FAILED=$((${FAILED} + $?))
    done
    exit ${FAILED}
fi

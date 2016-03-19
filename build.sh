#!/bin/bash

set -e

# Release-dance code goes here.

# Constants
PRODUCT="Propachi: CSL processor monkey-patch for Zotero"
IS_BETA="false"
FORK="propachi-vanilla"
BRANCH="master"
CLIENT="propachi-vanilla"
VERSION_ROOT="1.1."

function xx-fetch-latest-processor () {
    cd "${SCRIPT_DIR}"
    cd ../citeproc-js
    ./test.py -B
    mv citeproc.js "${SCRIPT_DIR}/chrome/content/citeproc.js"
    cd "${SCRIPT_DIR}"
}

function xx-read-version-from-processor-code () {
    PROCESSOR_VERSION=$(cat "chrome/content/citeproc.js" | grep "PROCESSOR_VERSION:" | sed -e "s/.*PROCESSOR_VERSION:[^0-9]*\([.0-9]\+\).*/\1/")
}

function xx-make-the-bundle () {
    find . -name '.hg' -prune -o \
        -name '.hgignore' -prune -o \
        -name '.gitmodules' -prune -o \
        -name '*~' -prune -o \
        -name '.git' -prune -o \
        -name 'attic' -prune -o \
        -name '.hgsub' -prune -o \
        -name '.hgsubstate' -prune -o \
        -name '*.bak' -prune -o \
        -name 'version' -prune -o \
        -name 'releases' -prune -o \
        -name 'sh-lib' -prune -o \
        -name 'build.sh' -prune -o \
        -print \
        | xargs zip "${XPI_FILE}" >> "${LOG_FILE}"
}

function build-the-plugin () {
        set-install-version
        xx-fetch-latest-processor
        xx-read-version-from-processor-code
        xx-make-the-bundle
    }
    
. jm-sh/frontend.sh

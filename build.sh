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
SIGNED_STUB="propachi_replace_zotero_csl_processor_std_ver-"

function xx-fetch-latest-processor () {
    cd "${SCRIPT_DIR}"
    cd ../citeproc-js
    #cslrun -a
    cp citeproc.js "${SCRIPT_DIR}/chrome/content/citeprocVanilla.js"
    cp citeproc.js "${SCRIPT_DIR}/chrome/content/citeprocUppercase.js"
    sed -si 's/this\.development_extensions\.main_title_from_short_title = false/this\.development_extensions\.main_title_from_short_title = true/' "${SCRIPT_DIR}/chrome/content/citeprocUppercase.js"
    sed -si 's/this\.development_extensions\.uppercase_subtitles = false/this\.development_extensions\.uppercase_subtitles = true/' "${SCRIPT_DIR}/chrome/content/citeprocUppercase.js"
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

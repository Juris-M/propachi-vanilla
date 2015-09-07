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

# Error handlers
. sh-lib/errors.sh

# Setup
. sh-lib/setup.sh

# Version levels
. sh-lib/versions.sh

# Prompt for options
#. sh-lib/prompt.sh

# Parse command-line options
. sh-lib/opts.sh

# Functions for build
. sh-lib/builder.sh

# Functions for release
. sh-lib/releases.sh

# Functions for repo management
. sh-lib/repo.sh

# Perform release ops
case $RELEASE in
    1)
        echo "(1)"
        # Preliminaries
        increment-patch-level
        if [ "$BETA" -gt 0 ]; then
            increment-beta-level
        fi
        echo "Version: ${VERSION}"

        # Build
        echo "(a)"
        touch-log
        echo "(b)"
        refresh-style-modules
        echo "(c)"
        build-the-plugin
        echo "(d)"
        repo-finish 1 "Built as ALPHA (no upload to GitHub)"
        echo "(e)"
        ;;
    2)
        echo "(2)"
        # Claxon
        check-for-uncommitted
        # Preliminaries
        increment-patch-level
        increment-beta-level
        save-beta-level
        echo "Version is: $VERSION"
        # Build
        touch-log
        refresh-style-modules
        build-the-plugin
        git-checkin-all-and-push
        create-github-release
        add-xpi-to-github-release
        repo-finish 0 "Released as BETA (uploaded to GitHub, prerelease)"
        ;;
    3)
        echo "(3)"
        # Claxon
        check-for-uncommitted
        block-uncommitted
        # Preliminaries
        reset-beta-level
        increment-patch-level
        check-for-release-dir
        save-patch-level
        echo "Version is: $VERSION"
        # Build
        touch-log
        refresh-style-modules
        build-the-plugin
        git-checkin-all-and-push
        create-github-release
        add-xpi-to-github-release
        publish-update
        repo-finish 0 "Released as FINAL (uploaded to GitHub, full wax)"
        ;;
esac

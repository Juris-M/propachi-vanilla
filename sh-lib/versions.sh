function compose-version-string () {
    VERSION="${VERSION_ROOT}$PATCH"
    VERSION_STUB="$VERSION"
    if [ ${BETA} -gt 0 ]; then
        VERSION="${VERSION}beta${BETA}"
        IS_BETA="true"
    fi
    if [ ${RELEASE} -eq 1 ]; then
        VERSION="${VERSION}alpha"
    fi
    RELEASE_DIR="${SCRIPT_DIR}/releases/${VERSION_STUB}"
    LOG_FILE="${RELEASE_DIR}/${CLIENT}-v${VERSION}.log"
    XPI_FILE="${RELEASE_DIR}/${CLIENT}-v${VERSION}.xpi"
}

function save-patch-level () {
    echo $PATCH > version/patch.txt
}

function increment-patch-level () {
    PATCH=$((PATCH+1))
    compose-version-string
}

function reset-beta-level () {
    echo 0 > version/beta.txt
    BETA=$(cat version/beta.txt)
    compose-version-string
}

function increment-beta-level () {
    BETA=$((BETA+1))
    compose-version-string
}

function save-beta-level () {
    echo $BETA > version/beta.txt
}

VERSION=""
PATCH=$(cat version/patch.txt)
BETA=$(cat version/beta.txt)
DOORKEY=$(cat "${HOME}/bin/doorkey.txt")

SCRIPT_DIR=$(pwd)

if [ ! -d "releases" ]; then
    mkdir releases
fi

CHECKED_IN_OK=1

function check-for-release-dir () {
    if [ ${BETA} -eq 0 -a ! -d "${RELEASE_DIR}" ]; then
        echo "${RELEASE_DIR}"
        echo "There have been no pre-releases of this version level - think again"
        exit 1
    fi
}

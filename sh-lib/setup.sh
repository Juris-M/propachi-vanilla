PATCH=$(cat version/patch.txt)
BETA=$(cat version/beta.txt)
IS_BETA=0
VERSION=""
FORK="propachi"
BRANCH="vanilla"
CLIENT="propachi-vanilla"
VERSION_ROOT="4.0.27m"

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

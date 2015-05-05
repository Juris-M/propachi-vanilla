function create-github-release () {
    if [ "$BETA" -gt "0" ]; then
        RELEASE_TAG="v${VERSION_STUB}beta"
        RELEASE_NAME="Beta pre-release of v${VERSION_STUB}"
        RELEASE_BODY="Beta pre-releases do not update automatically, and may be removed after the release is finalized"
    else
        RELEASE_TAG="v${VERSION_STUB}"
        RELEASE_NAME="v${VERSION_STUB} final"
        RELEASE_BODY="To install the plugin, click on the &ldquo;${CLIENT}-v${VERSION_STUB}.xpi&rdquo; file below while viewing this page in Firefox. This release will update automatically."
    fi
    UPLOAD_URL=$(curl --fail --silent \
        --user "${DOORKEY}" \
        "https://api.github.com/repos/Juris-M/${FORK}/releases/tags/${RELEASE_TAG}" \
        | ~/bin/jq '.upload_url')
    if [ "$UPLOAD_URL" == "" ]; then
        # Create the release
        DAT=$(printf '{"tag_name": "%s", "name": "%s", "body":"%s", "draft": false, "prerelease": %d}' "$RELEASE_TAG" "$RELEASE_NAME" "$RELEASE_BODY" "$IS_BETA")
        UPLOAD_URL=$(curl --fail --silent \
            --user "${DOORKEY}" \
            --data "${DAT}" \
            "https://api.github.com/repos/Juris-M/${FORK}/releases" \
            | ~/bin/jq '.upload_url')
    fi
    UPLOAD_URL=$(echo $UPLOAD_URL | sed -e "s/\"\(.*\){.*/\1/")
}

function add-xpi-to-github-release () {
    # Upload "asset"
    NAME=$(curl --fail --silent --show-error \
        --user "${DOORKEY}" \
        -H "Accept: application/vnd.github.manifold-preview" \
        -H "Content-Type: application/x-xpinstall" \
        --data-binary "@${RELEASE_DIR}/${CLIENT}-v${VERSION}.xpi" \
        "${UPLOAD_URL}?name=${CLIENT}-v${VERSION}.xpi" \
            | ~/bin/jq '.name')
    echo "Uploaded ${NAME}"
}

function publish-update () {
    # Generate a signed update manifest
    uhura -o update-TRANSFER.rdf -k ~/juris-m-distrib-keys/keyfile.pem -p "@${HOME}/bin/doorkey-jaggies.txt" "${RELEASE_DIR}/${CLIENT}-v${VERSION}.xpi" "https://github.com/Juris-M/${FORK}/releases/download/v${VERSION_STUB}/${CLIENT}-v${VERSION}.xpi"
    # Slip the update manifest over to the gh-pages branch, commit, and push
    git checkout gh-pages >> "${LOG_FILE}" 2<&1
    if [ ! -f update.rdf ]; then
        echo "XXX" > update.rdf
        git add update.rdf
    fi
    mv update-TRANSFER.rdf update.rdf >> "${LOG_FILE}" 2<&1
    git commit -m "Refresh update.rdf" update.rdf >> "${LOG_FILE}" 2<&1
    git push origin gh-pages >> "${LOG_FILE}" 2<&1
    echo "Refreshed update.rdf on project site"
    git checkout "${BRANCH}" >> "${LOG_FILE}" 2<&1
}

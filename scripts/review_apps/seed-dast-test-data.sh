[[ "$TRACE" ]] && set -x

function create_user() {
    local user="${1}"

    curl --silent --show-error --header "PRIVATE-TOKEN: ${REVIEW_APPS_ROOT_TOKEN}" \
        --data "email=${user}@example.com" \
        --data "name=${user}" \
        --data "username=${user}" \
        --data "password=${REVIEW_APPS_ROOT_PASSWORD}" \
        --data "skip_confirmation=true" \
        "${CI_ENVIRONMENT_URL}/api/v4/users" > /tmp/user.json

    [[ "$TRACE" ]] && cat /tmp/user.json

    jq .id /tmp/user.json
}

function create_project_for_user() {
    local userid="${1}"

    curl --silent --show-error --header "PRIVATE-TOKEN: ${REVIEW_APPS_ROOT_TOKEN}" \
        --data "user_id=${userid}" \
        --data "name=awesome-test-project-${userid}" \
        --data "visibility=private" \
        "${CI_ENVIRONMENT_URL}/api/v4/projects/user/${userid}" > /tmp/project.json

    [[ "$TRACE" ]] && cat /tmp/project.json
}

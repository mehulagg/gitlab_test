[[ "$TRACE" ]] && set -x

function create_user() {
    local user="${1}"

    curl --silent --show-error --header "PRIVATE-TOKEN: ${REVIEW_APPS_ROOT_TOKEN}" \
        --data "email=${user}@example.com" \
        --data "name=${user}" \
        --data "username=${user}" \
        --data "password=${REVIEW_APPS_ROOT_PASSWORD}" \
        "${CI_ENVIRONMENT_URL}/api/v4/users" > /tmp/user.json

    jq .id /tmp/user.json
}

# function create_project_for_user () {
#     local project="${2}"

#     curl --silent --show-error --header "PRIVATE-TOKEN: ${REVIEW_APPS_ROOT_TOKEN}" \
#         --data "email=${user}@example.com" \
#         --data "name=${user}" \
#         --data "username=${user}" \
#         --data "password=${REVIEW_APPS_ROOT_PASSWORD}" \
#         "${CI_ENVIRONMENT_URL}/api/v4/users" > /tmp/user.json    
# }

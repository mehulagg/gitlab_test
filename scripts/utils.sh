function retry() {
    if eval "$@"; then
        return 0
    fi

    for i in 2 1; do
        sleep 3s
        echo "Retrying $i..."
        if eval "$@"; then
            return 0
        fi
    done
    return 1
}

function setup_db_user_only() {
    source scripts/create_postgres_user.sh
}

function setup_db() {
    setup_db_user_only

    bundle exec rake db:drop db:create db:schema:load db:migrate

    bundle exec rake gitlab:db:setup_ee
}

function install_api_client_dependencies_with_apk() {
  apk add --update openssl curl jq
}

function install_api_client_dependencies_with_apt() {
  apt update && apt install jq -y
}

function install_gitlab_gem() {
  gem install httparty --no-document --version 0.17.3
  gem install gitlab --no-document --version 4.13.0
}

function echoerr() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;31m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;31m%s\n\033[0m" "${1}" >&2;
  fi
}

function echoinfo() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;33m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;33m%s\n\033[0m" "${1}" >&2;
  fi
}

function compile_webpack_assets_if_needed() {
  cat assets-hash.txt || echo "missing assets-hash.txt" > assets-hash.txt
  mv assets-hash.txt master-assets-hash.txt || echo "missing master-assets-hash.txt" > master-assets-hash.txt
  cat master-assets-hash.txt

  assets_paths="app/assets fixtures/emojis app/views/shared/empty_states app/views/shared/icons vendor/assets/javascripts"
  [ -d "ee/" ] && assets_paths="$assets_paths ee/app/assets ee/app/views/shared/empty_states ee/app/views/shared/icons"

  find $assets_paths -type f -exec md5sum {} \; | sort -k 2 | md5sum | cut -d " " -f 1 > assets-hash.txt

  if [[ "$(cat assets-hash.txt)" != "$(cat master-assets-hash.txt)" ]]; then
    time bin/rake webpack:compile > webpack-compile.log 2>&1
  fi
}

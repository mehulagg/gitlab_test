#!/bin/bash
# Temporary setup to get application.css from dev.gitlab.org

download_styles() {
  mkdir -p styles
  curl $(curl https://dev.gitlab.org/users/sign_in | sed -n 's/.*href="\/assets\/application/https:\/\/dev.gitlab.org\/assets\/application/p' | sed 's/".*//') > styles/application.css
}

now=$(date +%s)
modified=$(date -r styles/application.css +%s)
date_modified_minutes_ago=$(((now - modified) / 60))
if [ $date_modified_minutes_ago -gt 60 ]; then
  download_styles
fi

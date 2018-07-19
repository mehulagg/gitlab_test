#!/bin/bash
# Temporary setup to get application.css from dev.gitlab.org

mkdir styles
curl $(curl https://dev.gitlab.org/users/sign_in | sed -n 's/.*href="\/assets\/application/https:\/\/dev.gitlab.org\/assets\/application/p' | sed 's/".*//') > styles/application.css

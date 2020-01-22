#!/bin/sh

set -e

upstream="master"

upstream_schema=$(mktemp)
trap "{ rm -f $upstream_schema; }" EXIT

# Load the upstream schema into the database
git show $upstream:db/schema.rb > $upstream_schema
rake db:drop db:create db:schema:load SCHEMA=$upstream_schema

# Run migrations from this branch
rake db:migrate

if [ ! -z "$(git diff --name-only -- db/schema.rb)" ]; then
  printf "Changes in db/structure.sql changes are not consistent with the migrations on this branch."
  printf "The diff is as follows:\n\n"

  diff=$(git diff -p --binary -- db/schema.rb)
  printf "%s" "$diff"

  exit 1
else
  printf "Schema changes in db/schema.rb are consistent with the migrations on this branch."
fi

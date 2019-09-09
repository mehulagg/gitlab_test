#!/usr/bin/env bash

karma_files=$(find spec/javascripts ee/spec/javascripts -type f -name '*_spec.js' -not -path '*/helpers/*')
violations=""

for karma_file in $karma_files; do
  jest_file=${karma_file/spec\/javascripts/"spec/frontend"}

  if [ -f $jest_file ]; then
    violations="$violations $jest_file"
  fi
done

if [[ -z "$violations" ]]; then
  echo "All good!"
  exit 0
else
  echo "Danger! The following Jest specs have corresponding files in the Karma spec directory (i.e. spec/javascripts):"
  echo ""
  echo "------------------------------"
  for file in $violations; do
    echo $file
  done
  echo "------------------------------"
  echo ""
  echo "Please either:"
  echo ""
  echo "1. Fully migrate these files to Jest and remove their corresponding Karma files."
  echo "2. Remove the Jest spec."
  echo ""
  echo "Why is this a problem?"
  echo ""
  echo "- It's nice to have a single source of truth for the unit tests of a subject."
  echo "- This will cause conflicts if the remaining Karma spec is migrated using our automated tool."
  echo "  https://gitlab.com/gitlab-org/frontend/playground/migrate-karma-to-jest"
  echo ""
  exit 1
fi

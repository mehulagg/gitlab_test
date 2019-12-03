#! /usr/bin/env bash

target_ref=$1
source_ref=HEAD

if [ -z "$target_ref" ]
then
  echo "Error! An argument for the target ref is expected. Example:"
  echo ""
  echo "  ./check_no_new_karma.sh \$CI_MERGE_REQUEST_TARGET_BRANCH_SHA"
  echo ""
  exit 1
fi

merge_base=$(git merge-base $target_ref $source_ref)

if [ -z "$merge_base" ]
then
  echo "Could not find a merge base for $target_ref and $source_ref"
  echo ""
  exit 1
fi

diff_cmd="git diff $merge_base...$source_ref --name-only --diff-filter=A | grep -E \"spec/javascripts/.*_spec\""

echo ""
echo "Running the following command to see if new karma files are introduced:"
echo ""
echo "  $diff_cmd"
echo ""

new_karma_files=$(eval "$diff_cmd")

if [ -z "$new_karma_files" ]
then
  echo "All good :)"
  echo ""
  exit 0
else
  echo "Danger! New Karma specs detected:"
  echo ""
  echo "------------------------------"
  echo $new_karma_files
  echo "------------------------------"
  echo ""
  echo "Why is this a problem?"
  echo ""
  echo "We are currently in the process of migrating our Karma specs to Jest. Please move these spec files to"
  echo "the Jest directory 'spec/frontend' and make any changes necessary."
  echo ""
  exit 1
fi

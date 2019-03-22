#!/bin/bash -e

set -o pipefail

clone_repo_and_checkout_commit()
{
  #TODO
  echo ""
}

get_list_of_changed_files()
{
  local git_branch="${1}"
  git diff --name-only "${git_branch}" "$(git merge-base "${git_branch}" master)"
}
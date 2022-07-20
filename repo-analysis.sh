#!/usr/bin/env bash
set -Euex

USERNAME=$GH_USER
TOKEN=$GH_TOKEN
BASE_URL=https://api.github.com
OWNER=emmadev
PER_PAGE=100
REPOS_FILE=repos.txt
CURRENT_REPO=""
OUTPUT_FILE=repo-analysis.csv

function write_repos_to_file() {
  # Assuming we have less than 500 repos (currently 284)
  for PAGE in 1 2 3 4 5
  do
    URL="$BASE_URL/orgs/$OWNER/repos?page=$PAGE&per_page=$PER_PAGE"
    curl -s -u "$USERNAME:$TOKEN" "$URL" | jq -r '.[].name' >> "$REPOS_FILE"
  done
}

function prepare_output_file() {
    COL1="Repo"
    COL2="Create date"
    COL3="PRs merged (last 30 days)"
    COL4="Total lines of code"
    echo "$COL1, $COL2, $COL3, $COL4" >> $OUTPUT_FILE
}

function iterate_over_repos() {
  while read -r REPO; do
    CURRENT_REPO=$REPO
    record_repo_analysis
  done < $REPOS_FILE
}

function get_col2() {
  # Create date
  echo "foo"
}

function get_col3() {
  # PRs merged
  echo "5"
}

function get_col4() {
  # Total lines of code
  echo "100"
}

function clone_repo() {
  git clone "git@github.com:emmadev/$CURRENT_REPO"
}

function cleanup_clone() {
  rm -rf "$CURRENT_REPO"
}

function record_repo_analysis() {
  clone_repo
  COL1=$CURRENT_REPO
  COL2=$(get_col2)
  COL3=$(get_col3)
  COL4=$(get_col4)
  cleanup_clone
  echo "$COL1, $COL2, $COL3, $COL4" >> $OUTPUT_FILE
}

function init() {
  # wipe out previous runs of the script if they exist
  rm -f $REPOS_FILE
  rm -f $OUTPUT_FILE

  write_repos_to_file
  prepare_output_file
  iterate_over_repos
}

init

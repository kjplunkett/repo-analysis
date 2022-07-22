#!/usr/bin/env bash
set -Eue

USERNAME=$GH_USER
TOKEN=$GH_TOKEN
BASE_URL=https://api.github.com
OWNER=$GH_OWNER
PER_PAGE=100
REPOS_FILE=repos.txt
OUTPUT_FILE=output.csv
OUTPUT_FILE_COLUMNS=("repo" "description" "create_date" "last_updated_date" "archived" "prs_merged" "total_file_count" "total_line_count")

CURRENT_REPO=""
ALLOW_CACHED_DATA=0
PREDEFINED_REPOS=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a|--allow-cached-data) ALLOW_CACHED_DATA=1 ;;
        -p|--predefined-repos) PREDEFINED_REPOS=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function make_github_request() {
  # arg $1 = URL
  curl -s -u "$USERNAME:$TOKEN" "$1"
}

function write_repos_to_file() {
  echo "Gathering repos from $OWNER..."
  # NOTE: This script currently assumes less than 500 total repos...
  # TODO get a count and only paginate as much as necessary
  for PAGE in 1 2 3 4 5
  do
    URL="$BASE_URL/orgs/$OWNER/repos?page=$PAGE&per_page=$PER_PAGE"
    make_github_request "$URL" | jq -r '.[].name' >> "$REPOS_FILE"
  done
  REPO_COUNT=$(wc -l < $REPOS_FILE | xargs)
  echo "Wrote $REPO_COUNT repos to $REPOS_FILE"
}

function prepare_output_file() {
  HEADER_ROW=""
  for COLUMN in "${OUTPUT_FILE_COLUMNS[@]}"; do
    HEADER_ROW+="$COLUMN,"
  done
  echo "${HEADER_ROW::-1}" > $OUTPUT_FILE
}

function iterate_over_repos() {
  while read -r REPO; do
    CURRENT_REPO=$REPO
    record_repo_analysis
  done < $REPOS_FILE
}

function get_description() {
  jq '.description' "$CURRENT_REPO.json"
}

function get_create_date() {
  jq '.created_at' "$CURRENT_REPO.json"
}

function get_last_update_date() {
  jq '.updated_at' "$CURRENT_REPO.json"
}

function get_archived() {
  jq '.archived' "$CURRENT_REPO.json"
}

function get_prs_merged() {
  SEARCH_QUERY="type:pr+repo:$OWNER/$CURRENT_REPO+is:merged"
  URL="$BASE_URL/search/issues?q=$SEARCH_QUERY"
  make_github_request "$URL" | jq .total_count
}

function get_file_count() {
  cd "$CURRENT_REPO"
  git ls-files | wc -l | xargs
  cd ..
}

function get_line_count() {
  cd "$CURRENT_REPO"
  git ls-files | xargs wc -l | grep -o "[0-9]* total" | awk '{SUM += $1} END {print SUM}'
  cd ..
}

function clone_repo() {
  # if always clone then clone
  # else if repo exists don't clone
  # else clone
  REMOTE_URL="git@github.com:$OWNER/$CURRENT_REPO"
  git clone --depth 1 "$REMOTE_URL"
}

function get_repo_data() {
  [ ! -d "$CURRENT_REPO" ] && clone_repo

  URL="$BASE_URL/repos/$OWNER/$CURRENT_REPO"
  [ ! -f "$CURRENT_REPO.json" ] && make_github_request "$URL" > "$CURRENT_REPO.json"
}

function clean_repo_data() {
  rm -rf "$CURRENT_REPO"
  rm -rf "$CURRENT_REPO.json"
}

function record_repo_analysis() {
  get_repo_data
  COL1=$CURRENT_REPO
  COL2=$(get_description)
  COL3=$(get_create_date)
  COL4=$(get_last_update_date)
  COL5=$(get_archived)
  COL6=$(get_prs_merged)
  COL7=$(get_file_count)
  COL8=$(get_line_count)

  if (( "$ALLOW_CACHED_DATA" < 1 )); then
    clean_repo_data
  fi
  echo "$COL1,$COL2,$COL3,$COL4,$COL5,$COL6,$COL7,$COL8" >> $OUTPUT_FILE
}

function init() {
  START_TIME=$(date +%s)
  echo "Running repo analysis..."

  if (( "$PREDEFINED_REPOS" < 1 )); then
    rm -f $REPOS_FILE # delete existing repos file if it exists
    write_repos_to_file
  fi
  prepare_output_file
  iterate_over_repos

  END_TIME=$(date +%s)
  ELAPSED_TIME=$(( END_TIME - START_TIME ))
  echo "Repo analysis completed in $ELAPSED_TIME seconds"
}

init

# Repo Analysis

A script that collects data on many repos (currently up to 500 in a github org) and dumps the results into a CSV.

## Why make this?

There is a lot of data Github does not aggregate for you at the org level. 
This script generates that data in a format you can easily analyze, and share with others.

## Data points

The following data points are gathered in the columns of the resulting `output.csv`:

| Column Name       | Description                                             | Type               | Source     |
|-------------------|---------------------------------------------------------|--------------------|------------|
| repo              | The repo name                                           | string             | Github API |
| description       | The description of the repo                             | string             | Github API |
| create_date       | When the repo was created                               | ISO 8601 timestamp | Github API |
| last_updated_date | Last time a change was made in the repo                 | ISO 8601 timestamp | Github API |
| archived          | Whether or not the repo is archived                     | boolean            | Github API |
| prs_merged        | Total number of pull requests merged into the repo      | integer            | Github API |
| total_file_count  | Total number of tracked file in the repo                | integer            | Scripted   |
| total_line_count  | Total number of lines for all tracked files in the repo | integer            | Scripted   |


## Setup
> Prerequisites:
> - You have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed and an [SSH key setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for cloning the repos in the org
> - You have [cloc](https://github.com/AlDanial/cloc#install-via-package-manager) installed
> - You have bash>=5 installed (Run `bash --version` to check)

1. Export your github username to environment variable `GH_USER`
```sh
export GH_USER=myusername
```

2. Export your github org to environment variable `GH_OWNER` (if it is just your repos then this is your username again)
```sh
export GH_OWNER=myorg
```

4. Create a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with permission to read repos 
and export it to environment variable `GH_TOKEN`
```sh
export GH_TOKEN=1234
```

4. Run the script to analyze up to 500 repos in a github org
```sh
bash analyze.sh
```

4. Open the output file
```sh
open output.csv
```

## Additional command options

You can pass the following command options to the `analyze.sh` script:
- `--allow-cached-data` will skip the clone and api requests using data from previous runs of the script if it exists
- `--predefined-repos` will skip the generation of the `repos.txt` and assumes the user has created a `repos.txt` file 
in the project root with 1 repo name per line (does not handle empty lines or spaces)

## Debugging

Add the `x` flag to the `set` statement on the second line of the script to get more info. 

# Repo Analysis

## Setup
> This script assumes you have a valid SSH key setup for cloning `emmadev` repos

1. Export your github username to environment variable `GH_USER`
```sh
export GH_USER=kplunkett
```

2. Create a personal access token with access to read and clone repos 
and export it to an environment variable `GH_TOKEN`
```sh
export GH_TOKEN=1234
```

3. Run the script
```sh
bash repo-analysis.sh
```

4. Open the output file
```sh
open repo-analysis.csv
```

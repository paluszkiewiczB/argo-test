#!/bin/bash
# Script installs argocd helm chart (helm release and namespace is hardcoded to 'argocd')
# Requires properly set up kubectl config
# Requires installed envsubst

# Requires file "repo.txt" in "secrets" directory with following three lines:
#<git-repo-url>
#<git-repo-username>
#<git-repo-password>
#
# example:
#https://gitlab.com/paluszkiewiczHome/argo-test.git
#username
#s3cret!P@s$w0rD

set -ex
set -o pipefail

#changes working directory to script location, so paths can be relative
cd "$(dirname "$0")"

function argoInstalled() {
  local lines
  lines=$(helm list --namespace "argocd" | grep -c "argocd")
  if [ "$lines" -le 0 ]; then
    return 1
  else
    return 0
  fi
}

# Arg $1 - line number (counting from 1)
# Arg $2 - path to file
function readNthLine() {
  sed "$1q;d" "$2"
}

# Arg $1 path to file with credentials
# Arg $2 name for associative array to put config into
function readRepoConfig() {
  local file
  file=$1
  declare -n map="$2"
  map["url"]=$(readNthLine 1 "$file")
  map["user"]=$(readNthLine 2 "$file")
  # map used indirectly under name passed as arg $2
  # shellcheck disable=SC2034
  map["pass"]=$(readNthLine 3 "$file")
}

function installArgo() {
  local repositoryOutput
  repositoryOutput="$1"
  kubectl apply -f "namespace.yaml"
  helm install --namespace "argocd" "argocd" ../helmchart/argocd --values "$repositoryOutput"
}

if argoInstalled; then
  echo "Argo is already installed"
  exit 0
fi

credentialsFile="secrets/repo.txt"
declare -A credentials
readRepoConfig "$credentialsFile" credentials
repositoryOutput="$(dirname "$credentialsFile")/repository-filled.values"

REPO_URL=${credentials["url"]}
REPO_USR=${credentials["user"]}
REPO_PWD=${credentials["pass"]}
export REPO_URL REPO_USR REPO_PWD
# specify which variables to substitute; it's not bash substitution
# shellcheck disable=SC2016
envsubst '$REPO_URL:$REPO_USR:$REPO_PWD' <repository.yaml >"$repositoryOutput"

installArgo "$repositoryOutput"

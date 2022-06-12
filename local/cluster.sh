#!/bin/bash
# Script creates k3d cluster if not exists
# Arg $1 is the name of the cluster

set -e
set -o pipefail

function readName() {
  name=$(readName "$1")
  if [ -z "$name" ]; then
    echo "Required first parameter: name of the cluster"
    return 1
  fi
  echo "$name"
}

function clusterExists() {
  name=$(readName "$1")
  set +e
  if k3d cluster list | grep -q "$name"; then
    echo "true"
  else
    echo "false"
  fi
  set -e
}

function setupExistingCluster() {
  name=$(readName "$1")
  info=$(k3d cluster list | grep "$name")
  nodes=$(echo "$info" | awk '{print $2}')
  active=$(echo "$nodes" | cut -d/ -f1)

  if [ "$active" == 0 ]; then
    echo "Cluster $name is stopped. Starting the cluster"
    k3d cluster start "$name"
    echo "Cluster $name started"
  fi
}

function createNewCluster() {
  name=$(readName "$1")
  echo "Creating cluster $name"
  k3d cluster create "$name" --k3s-arg "--disable=traefik@server:0"
  echo "Cluster $name created"
}

name=$(readName "$1")

if [ "$(clusterExists "$name")" ]; then
  echo "Cluster $name already exists"
  setupExistingCluster "$name"
else
  echo "Cluster $name does not exist"
  createNewCluster "$name"
fi

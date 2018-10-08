#!/bin/sh

# By: Brandon Mitchell <public@bmitch.net>
# License: MIT
# Source Repo: https://github.com/sudo-bmitch/jenkins-docker

set -x

# configure script to call original entrypoint
set -- tini -- /usr/local/bin/jenkins.sh "$@"

# In Prod, this may be configured with a GID already matching the container
# allowing the container to be run directly as Jenkins. In Dev, or on unknown
# environments, run the container as root to automatically correct docker
# group in container to match the docker.sock GID mounted from the host.
if [ "$(id -u)" = "0" ]; then
  # get gid of docker socket file
  SOCK_DOCKER_GID=`ls -ng /var/run/docker.sock | cut -f3 -d' '`

  # get group of docker inside container
  CUR_DOCKER_GID=`getent group docker | cut -f3 -d: || true`

  # if they don't match, adjust
  if [ ! -z "$SOCK_DOCKER_GID" -a "$SOCK_DOCKER_GID" != "$CUR_DOCKER_GID" ]; then
    groupmod -g ${SOCK_DOCKER_GID} -o docker
  fi
  if ! groups jenkins | grep -q docker; then
    usermod -aG docker jenkins
  fi
  # Add call to gosu to drop from root user to jenkins user
  # when running original entrypoint
  set -- gosu jenkins "$@"
fi

# replace the current pid 1 with original entrypoint
exec "$@"


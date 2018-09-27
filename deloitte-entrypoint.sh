#!/bin/bash
set -eo pipefail

# Change user & group id if user id provided.
if [ ! -z "${DELOITTE_USER_ID}" ]
then
  echo "Starting with UID : ${DELOITTE_USER_ID}"
  usermod -u ${DELOITTE_USER_ID} deloitte
  groupmod -g ${DELOITTE_USER_ID} deloitte
  find / -not -path "/proc/*" -group 1000 -exec chgrp -h deloitte {} \;
fi

# Run mariadb's entrypoint.
exec /usr/local/bin/docker-entrypoint.sh "$@"

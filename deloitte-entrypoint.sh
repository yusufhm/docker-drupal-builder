#!/bin/bash
set -eo pipefail

# Change user & group id if user id provided.
if [ ! -z "${DELOITTE_USER_ID}" ]
then
  echo "Changing deloitte's UID to: ${DELOITTE_USER_ID}";
  usermod -u ${DELOITTE_USER_ID} deloitte;
  groupmod -g ${DELOITTE_USER_ID} deloitte;
  find / -not -path "/proc/*" -group 1000 -exec chgrp -h deloitte {} \;
fi

# Run mariadb's entrypoint.
export MYSQL_ALLOW_EMPTY_PASSWORD=true;
/usr/local/bin/docker-entrypoint.sh mysqld &> /tmp/mysql.log &

if [ ! -z "${DELOITTE_USER_ID}" ]
then
  export NVM_DIR=/home/deloitte/.nvm
  exec gosu ${DELOITTE_USER_ID} "$@"
else
  exec "$@"
fi

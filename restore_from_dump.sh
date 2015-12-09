#!/bin/bash

# Attempt to restore a database from a dump file
# Optionally restore only if the database is currently empty
# Requires
# - DB Name
# - Dump file path
# - Bool whether to restore if empty

# echo >&2 -e "\nOK GOT THIS FAR ...\n"; exit 1;

# Default parameters
DB_NAME=${DB_NAME:=}
DUMP_PATH=${DUMP_PATH:=}
RESTORE_ONLY_EMPTY=${RESTORE_ONLY_EMPTY:=true}


if [ -z "$DB_NAME" ]; then
    echo >&2 -e "\nNO DB_NAME PROVIDED ...\n"; exit 1;
fi

if [ -z "$DUMP_PATH" ]; then
    echo >&2 -e "\nNO DUMP_PATH PROVIDED ...\n"; exit 1;
fi

# # Check if we should only perform the restore if DB is empty,
# # if so, then perform check on db before continuing
# if [ "$RESTORE_ONLY_EMPTY" = true ]; then

# fi

# BACKUP_LOG="/var/log/postgresql/backup.log"

# if [ -n "${CRON_TIME}" ]; then
#     echo "=> Configuring cron schedule for database backups ..."

#     PG_HOST=${POSTGRES_PORT_3306_TCP_ADDR:-${PG_HOST}}
#     PG_PORT=${POSTGRES_PORT_3306_TCP_PORT:-${PG_PORT}}
#     PG_USER=${PG_USER:-${PG_ENV_PG_USER}}
#     PG_PASS=${PG_PASS:-${PG_ENV_PG_PASS}}

#     [ -z "${PG_HOST}" ] && { echo "=> PG_HOST cannot be empty" && exit 1; }
#     [ -z "${PG_PORT}" ] && { echo "=> PG_PORT cannot be empty" && exit 1; }
#     [ -z "${PG_USER}" ] && { echo "=> PG_USER cannot be empty" && exit 1; }
#     [ -z "${PG_PASS}" ] && { echo "=> PG_PASS cannot be empty" && exit 1; }
#     [ -z "${PG_DB}" ] && { echo "=> PG_DB cannot be empty" && exit 1; }
#     [ -z "${S3_BUCKET}" ] && { echo "=> S3_BUCKET cannot be empty" && exit 1; }
#     [ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
#     [ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
#     [ -z "${AWS_DEFAULT_REGION}" ] && { echo "=> AWS_DEFAULT_REGION cannot be empty" && exit 1; }

#     # Set environment variables to run cron job
#     echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> /etc/cron.d/postgres_backup
#     echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /etc/cron.d/postgres_backup
#     echo "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" >> /etc/cron.d/postgres_backup
#     echo "PG_HOST=${PG_HOST}" >> /etc/cron.d/postgres_backup
#     echo "PG_PORT=${PG_PORT}" >> /etc/cron.d/postgres_backup
#     echo "PG_USER=${PG_USER}" >> /etc/cron.d/postgres_backup
#     echo "PG_PASS=${PG_PASS}" >> /etc/cron.d/postgres_backup
#     echo "PG_DB=${PG_DB}" >> /etc/cron.d/postgres_backup
#     echo "S3_BUCKET=${S3_BUCKET}" >> /etc/cron.d/postgres_backup
#     [ -n "${MAX_BACKUPS}" ] && { echo "MAX_BACKUPS=${MAX_BACKUPS}" >> /etc/cron.d/postgres_backup; }
#     [ -n "${EXTRA_OPTS}" ] && { echo "EXTRA_OPTS=${EXTRA_OPTS}" >> /etc/cron.d/postgres_backup; }
#     echo "${CRON_TIME} /backup.sh >> ${BACKUP_LOG} 2>&1" >> /etc/cron.d/postgres_backup

#     # start cron if it's not running
#     if [ ! -f /var/run/crond.pid ]; then
#         exec /usr/sbin/cron -f
#     fi
# fi

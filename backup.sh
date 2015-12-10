#!/bin/bash
if [ "${POSTGRES_ENV_PG_PASS}" == "**Random**" ]; then
    unset POSTGRES_ENV_PG_PASS
fi

PG_HOST=${POSTGRES_PORT_5432_TCP_ADDR:-${PG_HOST}}
PG_PORT=${POSTGRES_PORT_5432_TCP_PORT:-${PG_PORT}}
PG_USER=${PG_USER:-${PG_ENV_PG_USER}}
PG_PASS=${PG_PASS:-${PG_ENV_PG_PASS}}

[ -z "${PG_HOST}" ] && { echo "=> PG_HOST cannot be empty" && exit 1; }
[ -z "${PG_PORT}" ] && { echo "=> PG_PORT cannot be empty" && exit 1; }
[ -z "${PG_USER}" ] && { echo "=> PG_USER cannot be empty" && exit 1; }
[ -z "${PG_PASS}" ] && { echo "=> PG_PASS cannot be empty" && exit 1; }
[ -z "${PG_DB}" ] && { echo "=> PG_DB cannot be empty" && exit 1; }
[ -z "${S3_BUCKET}" ] && { echo "=> S3_BUCKET cannot be empty" && exit 1; }
[ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
[ -z "${AWS_DEFAULT_REGION}" ] && { echo "=> AWS_DEFAULT_REGION cannot be empty" && exit 1; }


DEFAULT_MAX_BACKUPS=30
MAX_BACKUPS=${MAX_BACKUPS:-${DEFAULT_MAX_BACKUPS}}
BACKUP_NAME="${PG_DB}_`date +"%m%d%Y_%H%M%S"`.dump.gz"
BACKUP_PATH="/tmp/${BACKUP_NAME}"

echo "=> Backup started ..."

# First, make sure the that the S3_BUCKET path exists
#
count=`/usr/bin/aws s3 ls s3://$S3_BUCKET | wc -l`

if [[ $count -eq 0 ]]; then
  echo "Path $S3_BUCKET not found."
  exit 1
fi

# Create the database backup locally
su postgres sh -c "PGPASSWORD=${PG_PASS} /usr/bin/pg_dump -h ${PG_HOST} -p ${PG_PORT} -U ${PG_USER} -Fc --no-acl --no-owner ${PG_DB} | gzip -9 > ${BACKUP_PATH}"
if [ "$?" -ne 0 ]; then
    echo "   Backup failed"
    rm -rf $BACKUP_PATH
    exit 1
fi

# Copy the backup to the S3 bucket
echo "Copying $BACKUP_PATH to S3 ..."
S3_FILE_PATH="s3://$S3_BUCKET/$BACKUP_NAME"
/usr/bin/aws s3 cp $BACKUP_PATH $S3_FILE_PATH

# Clean up
rm -rf $BACKUP_PATH

echo "Removing old databse backup files ..."
files=($(aws s3 ls s3://$S3_BUCKET | awk '{print $4}'))
count=${#files[@]}
diff=`expr $count - $MAX_BACKUPS`
if [[ $diff -gt 0 ]]; then
  while [[ $diff -gt 0 ]]; do
    i=`expr $diff - 1`
    file=${files[$i]}
    /usr/bin/aws s3 rm s3://$S3_BUCKET/$file
    let diff=diff-1
  done
fi

echo "=> Backup done"

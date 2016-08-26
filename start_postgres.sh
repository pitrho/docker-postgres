#!/usr/bin/env bash

set -e

# Default parameters
#
DATADIR=${PG_DATADIR:=/var/lib/postgresql/%%PG_VERSION%%/main}
BINDIR=${PG_BINDIR:=/usr/lib/postgresql/%%PG_VERSION%%/bin}
CONFIG_FILE=${PG_CONFIG_FILE:=/etc/postgresql/%%PG_VERSION%%/main/postgresql.conf}
HBA_FILE=${PG_HBA_FILE:=/etc/postgresql/%%PG_VERSION%%/main/pg_hba.conf}
IDENT_FILE=${PG_IDENT_FILE:=/etc/postgresql/%%PG_VERSION%%/main/pg_ident.conf}
OUT_LOG=/var/log/postgresql/out.log
SLEEP_TIME=5

# Custom die function.
#
die() { echo >&2 -e "\nRUN ERROR: $@\n"; exit 1; }

StartPGServer()
{
  echo "=> Starting Postgres Server ..."
  PGARGS="-c config_file=$CONFIG_FILE -c data_directory=$DATADIR -c hba_file=$HBA_FILE -c ident_file=$IDENT_FILE"
  su postgres sh -c "$BINDIR/postgres ${PGARGS} ${EXTRA_OPTS} > $OUT_LOG 2>&1 &"
}

InitDB() {
  echo "=> Initializing DB ..."

  # If DATADIR does not exist, create it
  if [ ! -d $DATADIR ]; then
    echo "Creating Postgres data at $DATADIR"
    mkdir -p $DATADIR
  fi

  # If DATADIR has no content, initialize it
  if [ ! "$(ls -A $DATADIR)" ]; then
    echo "Initializing Postgres Database at $DATADIR"
    chown -R postgres $DATADIR
    su postgres sh -c "$BINDIR/initdb $DATADIR"
    touch $DATADIR/.EMPTY_DB
  fi
}

CreatePGUser()
{
  SHOW_PWD=false
  if [ "$PG_PASS" = "**Random**" ]; then
	    unset PG_PASS
      SHOW_PWD=true
	fi

  PASS=${PG_PASS:-$(pwgen -s 12 1)}
  _word=$( [ ${PG_PASS} ] && echo "preset" || echo "random" )
	echo "=> Creating PostgreSQL user ${PG_USER} in ${SLEEP_TIME} seconds ..."
  sleep $SLEEP_TIME
  psql -U postgres -c "CREATE USER ${PG_USER} WITH SUPERUSER ENCRYPTED PASSWORD '${PASS}';"
  echo "=> Done!"
  if [ "$SHOW_PWD" = true ]; then
    	echo "========================================================================"
    	echo "You can now connect to this PostgreSQL Server using:"
    	echo ""
    	echo "    psql -u $PG_USER -p $PASS -h <host> -p <port> -d <database>"
    	echo ""
    	echo "Please remember to change the above password as soon as possible!"
    	echo "User 'postgres' has no password but only allows local connections"
    	echo "========================================================================"
  fi
}

OnCreateDB()
{
    if [ "${ON_CREATE_DB}" = "**False**" ]; then
        unset ON_CREATE_DB
    else
        echo "Creating PostgreSQL database ${ON_CREATE_DB}"
        psql -U postgres -c "CREATE DATABASE ${ON_CREATE_DB};"
        echo "Database created!"
    fi
}

ImportSql()
{
    if [ -z "${ON_CREATE_DB}" ]; then
        echo "=> Cannot import SQL files. ON_CREATE_DB cannot be empty"
    else

      for FILE in ${STARTUP_SQL}; do
  	    echo "=> Importing SQL file ${FILE}"
        psql -U postgres $ON_CREATE_DB < ${FILE}
      done
    fi
}

echo "=> Starting PostgreSQL ..."
InitDB
StartPGServer

# Create admin user and pre create database
if [ -f $DATADIR/.EMPTY_DB ]; then
    CreatePGUser
    OnCreateDB
    rm $DATADIR/.EMPTY_DB
fi

# Import Startup SQL
if [ -n "${STARTUP_SQL}" ]; then
    if [ ! -f /sql_imported ]; then
        echo "=> Initializing DB with ${STARTUP_SQL}"
        ImportSql
        touch /sql_imported
    fi
fi

# Set backup schedule
if [ -n "${CRON_TIME}" ]; then
    exec /enable_backups.sh
fi

tail -f $OUT_LOG

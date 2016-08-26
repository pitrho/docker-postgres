#!/bin/bash

PG_VERSION="9.4"
IMAGE_TAG="pitrho/postgres"

# Custom die function.
#
die() { echo >&2 -e "\nRUN ERROR: $@\n"; exit 1; }

# Parse the command line flags.
#
while getopts "v:t:" opt; do
  case $opt in
    t)
      IMAGE_TAG=${OPTARG}
      ;;

    v)
      PG_VERSION=${OPTARG}
      ;;

    \?)
      die "Invalid option: -$OPTARG"
      ;;
  esac
done

# Crete the build directory
rm -rf build
mkdir build
cp pg_hba.conf build/
cp backup.sh build/
cp enable_backups.sh build/
sed 's/%%PG_VERSION%%/'"$PG_VERSION"'/g' start_postgres.sh > build/run

# Copy docker file, and override the MYSQL_VERSION string
sed 's/%%PG_VERSION%%/'"$PG_VERSION"'/g' Dockerfile.tmpl > build/Dockerfile

docker build -t="${IMAGE_TAG}" build/

rm -rf build

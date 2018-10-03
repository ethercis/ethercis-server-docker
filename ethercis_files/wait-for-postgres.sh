#!/bin/ash

#this is a customised version of the apache 2.0 licensed script at: https://github.com/NBISweden/LocalEGA/blob/13b99d9165ceb8f160d98735278ea3e29aa8dcd6/docker/entrypoints/wait-for-postgres.sh

#set environment vars which are used below
source /ethercis/env.rc

#set -e causes the shell to exit if any subcommand or pipeline returns a non-zero status
set -e

#parameters to this script
cmd="$@"

#psql uses this env. var for password. see: https://stackoverflow.com/questions/6405127/how-do-i-specify-a-password-to-psql-non-interactively
export PGPASSWORD=$DB_PASS

until psql -U $DB_USER -p $DB_PORT -h $DB_HOST -c "select 1"; do sleep 1; done

>&2 echo "Postgres is up - executing command"
exec $cmd
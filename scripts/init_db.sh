#!/usr/bin/env bash

RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
PURPLE="\e[0;35m"
CYAN="\e[0;36m"
GREY="\e[0;37m"
BOLD="\e[1m"
UNDERLINE="\e[4m"
CLEAR="\e[0m"

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
PROJECT_DIR=$(dirname "$SCRIPT_DIR")

# Default vars
DB_USER="${POSTGRES_USER:=postgres}"
DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
DB_NAME="${POSTGRES_DB:=newsletter}"
DB_PORT="${POSTGRES_PORT:=5432}"
DB_HOST="${POSTGRES_HOST:=localhost}"

help() {
    # Display Help
    echo -e $CYAN"Description:"$CLEAR
    echo -e "This is a db_init script for email_newsletter"
    echo -e
    echo -e $CYAN"Syntax:"
    echo -e $YELLOW'./init_db.sh [-h|sD] [-u|pA|n|p] "my_string"'
    echo -e
    echo -e $CYAN"Options:"
    echo -e $YELLOW"-h --help           \t$CLEAR Print this Help."
    echo -e $YELLOW"-sD --skip-docker   \t$CLEAR Skip Docker."
    echo -e $YELLOW"-u  --user          \t$CLEAR DB user. Default: $YELLOW$DB_USER"
    echo -e $YELLOW"-pA --password      \t$CLEAR DB password. Default: $YELLOW$DB_PASSWORD"
    echo -e $YELLOW"-n  --name          \t$CLEAR DB name. Default: $YELLOW$DB_NAME"
    echo -e $YELLOW"-ho --host          \t$CLEAR DB host. Default: $YELLOW$DB_HOST"
    echo -e $YELLOW"-p  --port          \t$CLEAR DB port. Default: $YELLOW$DB_PORT"
    echo -e
}

if ! [ -x "$(command -v psql)" ]; then
    echo -e $RED"Error: psql is not installed."$CLEAR
    exit 1
fi
if ! [ -x "$(command -v sqlx)" ]; then
    echo -e $RED"Error: sqlx is not installed."
    echo -e $YELLOW"Use:"
    echo -e $BLUE"cargo install --version=^0.6 sqlx-cli --features postgres"
    echo -e $YELLOW"to install it."$CLEAR
    exit 1
fi


if [[ $# -eq 0 ]]; then
    # If no arguments, display help
    help
else
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                help
                shift # shift argument
                exit 0
            ;;
            --skip-docker|-sD)
                help
                shift # shift argument
                SKIP_DOCKER=true
            ;;
            --user|-u)
                help
                DB_USER=("$2")
                shift # shift argument
                shift # shift value
            ;;
            --password|-pA)
                help
                DB_PASSWORD=("$2")
                shift # shift argument
                shift # shift value
            ;;
            --name|-n)
                help
                DB_NAME=("$2")
                shift # shift argument
                shift # shift value
            ;;
            --host|-ho)
                help
                DB_HOST=("$2")
                shift # shift argument
                shift # shift value
            ;;
            --port|-p)
                help
                DB_PORT=("$2")
                shift # shift argument
                shift # shift value
            ;;
            -*)
                echo -e $RED"Unknown option $BOLD$1"$CLEAR
                exit 1
            ;;
            *)
                echo -e $RED"Unknown argument $BOLD$1"
                echo -e $YELLOW'If you want to pass an argument with spaces'
                echo -e 'pass the argument like this: "my argument"'$CLEAR
                exit 1
            ;;
        esac
    done
fi

set -x
set -eo pipefail

if [[ -z "${SKIP_DOCKER}" ]]; then
    docker run \
    -e POSTGRES_USER=${DB_USER} \
    -e POSTGRES_PASSWORD=${DB_PASSWORD} \
    -e POSTGRES_DB=${DB_NAME} \
    -p ${DB_PORT}:5432 \
    -d postgres \
    postgres -N 1000
fi

export PGPASSWORD="${DB_PASSWORD}"
until psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q'; do
    echo -e $YELLOW"Postgres is still unavailable - sleeping"$CLEAR
    sleep 1
done
echo -e $GREEN"Postgres is up and running on port ${DB_PORT} - running migrations now!"$CLEAR
DB_URL="postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
echo "DATABASE_URL=${DB_URL}" > $PROJECT_DIR/.env
export DATABASE_URL=${DB_URL}
sqlx database create
sqlx migrate run
echo -e $GREEN"Postgres has been migrated, ready to go!"$CLEAR
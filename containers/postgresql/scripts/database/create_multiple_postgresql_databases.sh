#!/bin/bash
# Help can be found at the following link: https://github.com/mrts/docker-postgresql-multiple-databases

set -e
set -u

function create_databases_and_users() {
	local databases_info=$1

	# Split the databases_info string into the 3 variables (database, user, password), using as delimiter the : character.
	IFS=":" read -r database user password <<<"$databases_info"
	echo "Creating database '$database' with user '$user' and password '$password' ..."
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
		CREATE ROLE $user WITH LOGIN PASSWORD '$password';
			    CREATE DATABASE $database;
			    GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
	EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES_INFO" ]; then
	echo "Creting multiple databases with their corresponding users and credentials ..."
	for database_info in $(echo $POSTGRES_MULTIPLE_DATABASES_INFO | tr ',' ' '); do
		create_databases_and_users $database_info
	done
	echo "Multiple databases has been created!"
fi

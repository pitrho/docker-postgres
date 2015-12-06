# Docker Trusty/Precise Postgres

This repository contains a Dockerfile and associated
scripts for building a [PostgreSQL](http://www.postgresql.org/)
Docker image from an [Ubuntu 14.04 LTS](http://releases.ubuntu.com/trusty/)
base image (can change to Precise by modifying Dockerfile.tmpl).
This particular PostgreSQL Docker image makes it easy to

* make your database persistent across container restarts; and,
* configure PostgreSQL without changing the image, but instead by passing in arguments when the container is started.


## Building the image

Clone the repository

		git clone https://github.com/pitrho/docker-postgres.git
		cd docker-postgres
		./build

To use a different tag, pass the -t flag with the tag name

		./build -t new/tag

By default, this image will install PostgreSQL 9.4. If you want to install a
previous version, then pass the -v flag along with the version.

		./build -v 9.3

## Usage

To run the image and bind to port 5432:

  	docker run -d -p 5432:3306 pitrho/postgresql

The first time that you run your container, a new user `admin` with all
privileges will be created in with a random password. To get the password,
check the logs of the container by running:

  	docker logs <CONTAINER_ID>

You will see an output like the following:

	========================================================================
	You can now connect to this PostgreSQL Server using:

	    psql -u admin -p CwSlBmL6gE3P -h <host> -p <port> -d <database>

	Please remember to change the above password as soon as possible!
	User 'postgres' has no password but only allows local connections
	========================================================================

In this case, `CwSlBmL6gE3P` is the password allocated to the `admin` user.

Remember that the `postgres` user has no password,but it's only accessible
from within the container.

You can now test your deployment:

  	psql -U admin

## Changing the database user and password

Instead of using the default admin user and the auto-generate password, you can
use custom values. This can be done by passing environment variables PG_USER
and PG_PASS.

  	docker run -d -p 3306:3306 -e PG_USER=user -e PG_PASS=pass pitrho/postgresql

## Passing extra configuration to start postgresql server

To pass additional settings to `postgres`, you can use environment variable
`EXTRA_OPTS`.

  	docker run -d -p 3306:3306 -e EXTRA_OPTS="-c some_option=value" pitrho/postgresql


## Creating a database on container creation

If you want a database to be created inside the container when you start it up
for the first time ,then you can set the environment variable `ON_CREATE_DB` to
the name of the database.

    docker run -d -p 3306:3306 -e ON_CREATE_DB="newdatabase" pitrho/postgresql

If this is combined with importing SQL files, those files will be imported
into the created database.


## Database data and volumes

This image does not enforce any volumes on the user. Instead, it is up to the
user to decide how to create any volumes to store the data. Docker has several
ways to do this. More information can be found in the Docker
[user guide](https://docs.docker.com/userguide/dockervolumes/).

## Database backups

This image introduces a mechanism for creating and storing backups on Amazon S3.
The backups can be run manually or using an internal cron schedule.

To run the backups manually, do:

    docker run -e PG_USER=user PG_PASS=pass PG_DB=dname -e AWS_ACCESS_KEY_ID=keyid -e AWS_SECRET_ACCESS_KEY=secret -e AWS_DEFAULT_REGION=region -e S3_BUCKET=path/to/bucket /backup.sh

To run the backups on a cron schedule (e.g every day at 6 am), do:

    docker run -d -p 3306:3306 -e PG_DB=dname -e AWS_ACCESS_KEY_ID=keyid -e AWS_SECRET_ACCESS_KEY=secret -e AWS_DEFAULT_REGION=region -e S3_BUCKET=path/to/bucket -e CRON_TIME="0 6 * * * root"

## License

MIT. See the LICENSE file.

## Acknowledgements

We started with the excellent
[PostgreSQL Docker image from Discourse](https://github.com/srid/discourse-docker/tree/master/postgresql).

## Contributors

* [Kyle Jensen](https://github.com/kljensen)
* [Gilman Callsen](https://github.com/callseng)
* [Alejadnro Mesa](https://github.com/alejom99)

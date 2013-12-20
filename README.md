# Docker Precise Postgres

This repository contains a Dockerfile and associated
scripts for building a [PostgreSQL](http://www.postgresql.org/)
Docker image from an [Ubuntu 12.04 LTS](http://releases.ubuntu.com/precise/)
base image.  This particular PostgreSQL Docker image
makes it easy to

* make your database persistent across container restarts; and,
* configure PostgreSQL without changing the image, but instead by passing in arguments when the container is started.


## Building the image

Clone the repository

	export IMGTAG="pitrho/postgres"
	git clone https://github.com/pitrho/docker-precise-postgres.git
	cd docker-precise-postgres
	docker build -t $IMGTAG .

Verify you have the image locally

	docker images | grep "$IMGTAG"

## Example usage

### Basic usage

Start the image, creating an admin user "foo" with password "bar".

	PGID=$(docker run -d $IMGTAG -u foo -p bar)
	PGIP=$(docker inspect -format='{{.NetworkSettings.IPAddress}}' $PGID)

Now you should be able to connect with `psql` as such

	psql -h $PGIP -U foo -d postgres

You'll get prompted for a password, enter 'bar'.

A few comments:

* The `-u` and `-p` parameters are passed to the `start_postgres.sh` shell script, which is the `ENTRYPOINT` defined in the `Dockerfile`.
* You can see the other configuration options in the `start_postgres.sh` script.
* When run in this manner, the PostgreSQL data directory is on the container's [union file system](http://docs.docker.io/en/latest/terms/layer/). So, when the container is stopped or killed, your data will be deleted.


### Persisting data across container restarts

To persist data, you'll need to use
[Docker volumes](http://docs.docker.io/en/latest/use/working_with_volumes/).

On the host system, create a directory that will house the persisted
data.

	mkdir -p /tmp/pgdata

Now, mount that as a volume when you start up the container and
tell PostgreSQL to store its data there

	PGID=$(docker run -v /tmp/pgdata/:/tmp/pgdata/ -d $IMGTAG -u foo -p bar -d /tmp/pgdata/)
	PGIP=$(docker inspect -format='{{.NetworkSettings.IPAddress}}' $PGID)

Again, you can connect from the host system like

	psql -h $PGIP -U foo -d postgres

Go ahead and make some changes, e.g. creating a table, etc.  Then,
stop the container

	docker stop $PGID

Now, let's start it up again. Since we created the `foo` user previously, and
our data were persisted in the volume, there's no need to pass the `-u` and 
`-p` parameters this time

	PGID=$(docker run -v /tmp/pgdata/:/tmp/pgdata/ -d $IMGTAG -d /tmp/pgdata/)
	PGIP=$(docker inspect -format='{{.NetworkSettings.IPAddress}}' $PGID)

Now, when you connect to the PostgreSQL instance, you'll notice the changes
you made previously are still present.


### Customizing the PostgreSQL configuration

You can override each of the following
[PostgreSQL configuration file locations](http://www.postgresql.org/docs/9.1/static/runtime-config-file-locations.html)

* `data_directory`, 
* `config_file`, 
* `hba_file`, and
* `ident_file`.

To do so, you'll need to put them in a directory that is exposed to
the running container as a volume.  (The
[Docker cp](http://docs.docker.io/en/master/commandline/command/cp/)
command can only copy files *from* a contain, alas.)

For example, imagine we have a custom PostgreSQL config_file at `/tmp/pgconfig/postgresql.conf`
and we want to start PostgreSQL using this.  We'd start the container like

	PGID=$(docker run -v /tmp/pgconfig/:/tmp/pgconfig/ -d $IMGTAG -u foo -p bar -c /tmp/pgconfig/postgresql.conf)
	PGIP=$(docker inspect -format='{{.NetworkSettings.IPAddress}}' $PGID)

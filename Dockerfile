# -*- sh -*-

# Based on
# https://github.com/srid/discourse-docker/blob/master/postgresql/Dockerfile
FROM       	ubuntu:12.04
MAINTAINER  pitrho


# Prevent apt from starting postgres right after the installation
#
RUN echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d


# Set up the environment
#
ENV DEBIAN_FRONTEND noninteractive
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


# Fix encoding-related bug
# https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/813398
#
RUN apt-get -qy install language-pack-en #
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales


# Install postgresql 
#
RUN apt-get install -y -q postgresql-9.1 postgresql-contrib-9.1


# Allow autostart again
#
RUN rm /usr/sbin/policy-rc.d


# Move our files into the Docker image and make the
# entrypoint executable.
#
ADD start_postgres.sh /
RUN chmod a+x ./start_postgres.sh
ADD postgresql.conf /etc/postgresql/9.1/main/
ADD pg_hba.conf /etc/postgresql/9.1/main/


# Expose port 5432, the default Postgresql port, which will
# allow other container to connect to this container's Postgresql
#
EXPOSE 5432


# The entrypoint is our shell script.  You can pass in arguments
# to this shell script when you start the docker container, e.g.
#
#	$ docker run -d "pitrho/postgres" -u foo -p bar
#
# where the -u and -p arguments are passed to the shell script.
#
ENTRYPOINT ["/start_postgres.sh"]
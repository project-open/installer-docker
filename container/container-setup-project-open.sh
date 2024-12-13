#!/bin/bash
# ------------------------------------------------------------------
# container-setup-project-open.sh
# Based on container-setup-openacs.sh from Gustaf Neumann.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# This file is executed by docker because of the
# command line parameters in project-open.yaml:
#        /bin/bash /scripts/container-setup-openacs.sh \\
#        && /usr/local/ns/bin/nsd -f -t ${nsdconfig:-/usr/local/ns/conf/openacs-config.tcl} -u nsadmin -g nsadmin 

# ------------------------------------------------------------------
# From project-open.yaml
#      - TZ=${TZ:-Europe/Vienna}
#      - LD_PRELOAD=${LD_PRELOAD:-}
#      - oacs_httpport=8080
#      - oacs_httpsport=8443
#      - oacs_ipaddress=0.0.0.0
#      - oacs_hostname=${hostname:-localhost}
#      - oacs_server=${service:-oacs-5-10}
#      - oacs_db_name=${service:-oacs-5-10}
#      - oacs_db_host=${db_host:-host.docker.internal}
#      - oacs_db_port=${db_port:-5432}
#      - oacs_db_user=${db_user:-openacs}
#      - oacs_db_passwordfile=/run/secrets/psql_password
#      - oacs_serverroot=/var/www/openacs
#      - oacs_certificate=${certificate:-/var/www/openacs/etc/certfile.pem}
#      - oacs_logroot=${logroot:-/var/www/openacs/log}
#      - oacs_tag=${oacs_tag:-oacs-5-10}
#      - oacs_clusterSecret=${clusterSecret:-}
#      - oacs_paramterSecret=${parameterSecret:-}
#      - system_pkgs=${system_pkgs:-imagemagick}

# ------------------------------------------------------------------
# From .env
# PSQL_PASSWORD=openacs
# system_pkgs="imagemagick poppler-utils"
# httpsport=8445
# config_dir=/Users/neumann/src/naviserver-alpine
# clusterSecret=123
# parameterSecret=222
# ipaddress=0.0.0.0
# db_host=postgres


echo "====== container-setup-project-open.sh called"

source /usr/local/ns/lib/nsConfig.sh

# ------------------------------------------------------------------
# from nsConfig.sh
# build_dir="/usr/local/src"
# ns_install_dir="/usr/local/ns"
# version_ns=GIT
# version_modules=GIT
# version_tcl=8.6.15
# version_tcllib=1.20
# version_thread=
# version_xotcl=2.4.0
# version_tdom=0.9.5
# ns_user=nsadmin
# pg_user=postgres
# ns_group=nsadmin
# with_mongo=0
# with_postgres=0
# with_postgres_driver=1
# pg_incl="/usr/include/postgresql"
# pg_lib="/usr/lib"
# make="make"
# type="type -p"
# debian=1
# redhat=0
# macosx=0
# sunos=0
# freebsd=0
# archlinux=0
# alpine=0
# wolfi=0


CONTAINER_ALREADY_STARTED="/CONTAINER_ALREADY_STARTED_PLACEHOLDER"


if [ ! -e $CONTAINER_ALREADY_STARTED ] ; then
    touch $CONTAINER_ALREADY_STARTED
    echo "====== First container startup"

    echo "====== Content of oacs_serverroot=${oacs_serverroot}" 
    
    if [ ! -f ${oacs_serverroot}/install.xml ] ; then
        echo "====== Using Install file: ${install_file:-openacs-xowf-install.xml}"
        cp ${oacs_serverroot}/${install_file:-openacs-xowf-install.xml} ${oacs_serverroot}/install.xml
    fi
    
    oacs_core_tag=$oacs_tag
    oacs_packages_tag=$oacs_tag

    #
    # We have here always a serverroot, but maybe no checked out
    # version of the source code (which might be mounted via
    # "volumes".
    #
    cd  ${oacs_serverroot}
    if [ ! -d "packages" ] ; then
        echo "====== We have no OpenACS /packages, install from GIT"
        ls -l ${oacs_serverroot}

        echo "====== Cloning packages from GIT"
	# git config --global user.name "Project Open"
	# git config --global user.email "info@project-open.com"
        # git config --global url.https://${{ secrets.PAT }}@github.com/.insteadOf https://github.com/
	
        echo "====== Before git clone"
	git clone https://git@gitlab.project-open.net/project-open/packages.git
        ls -l ${oacs_serverroot}

        echo "====== Before git submodule update"
        cd ${oacs_serverroot}/packages
	git submodule update --recursive --init
        ls -l ${oacs_serverroot}/packages

        #
        # Check certificate
        #
        if [ ! -e ${oacs_certificate} ] ; then
            echo "====== No certificate found, using self-signed certificate from NaviServer installation."
            ln -sf /usr/local/ns/etc/server.pem ${oacs_certificate}
        fi
    else
        echo "====== Packages are already installed, use existing (external?) installation"
    fi

    #
    # Set permissions on serverroot
    #
    chown -R nsadmin:nsadmin ${oacs_serverroot}
    chmod -R g+w ${oacs_serverroot}

    echo "====== List of ${oacs_serverroot}:"
    ls -l ${oacs_serverroot}
    echo "====== List of ${oacs_serverroot}/packages:"
    ls -l ${oacs_serverroot}/packages

    
    #
    # Now we have to check, whether we have to create the database
    #
    echo "====== base-image '$base_image'"

    echo "====== Use PostgreSQL"
    if [ -e /usr/local/ns/bin/nsdbpg.so ] ; then
        echo "====== PostgreSQL library nsdbpg.so exists"
    else
        echo "====== PostgreSQL library nsdbpg.so does NOT exist"
    fi

    # db_admin_user=${db_admin_user:-postgres}
    db_admin_user=${db_admin_user:-nsadmin}
    db_dir=/usr

    if [ "$oacs_db_host" = "host.docker.internal" ] ; then
        echo "====== DB setup: Use the Database on the docker host"
        # We assume, the DB is created and already set up
    else
        echo "====== DB setup: Use the Database in a 'postgres' container"
	echo "====== DB setup:" db_admin_user=$db_admin_user db_dir=$db_dir oacs_db_name=$oacs_db_name oacs_db_host=$oacs_db_host oacs_db_user=$oacs_db_user
	# We assume that this is a fresh DB that needs to be set up
        #
        # Configure the database in the DB container
        #
        echo "====== DB setup: Configuration variables"
        env | sort

        echo "====== DB setup: Waiting for PostgreSQL to become available"
	DB_RETRY_COUNT=0
	DB_RETRY_MAX=60
	DB_RETRY_INTERVAL=1
        echo "====== DB setup: pg_isready -h ${oacs_db_host} -p ${oacs_db_port} 2>/dev/null"
	while ! pg_isready -h ${oacs_db_host} -p ${oacs_db_port} 2>/dev/null; do
	    DB_RETRY_COUNT=$(($DB_RETRY_COUNT + 1))
	    if [ $DB_RETRY_COUNT -ge $DB_RETRY_MAX ]; then
		echo "====== DB setup: PostgreSQL not ready after ${DB_RETRY_MAX} attempts. Exiting."
		exit 1
	    fi
	    echo "====== DB setup: Waiting for PostgreSQL to be ready, attempt: ${DB_RETRY_COUNT}"
	    sleep "${DB_RETRY_INTERVAL}"
	done
	echo "====== DB setup: PostgreSQL ready now with attempt: ${DB_RETRY_COUNT}"

        echo "====== DB setup: Checking if oacs_db_user ${oacs_db_user} exists in db..."
        echo "====== DB setup: psql -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${oacs_db_user}'\""
        dbuser_exists=$(psql -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${oacs_db_user}'\")
        if [ "$dbuser_exists" != "1" ] ; then
            echo "====== DB setup: Creating oacs_db_user ${oacs_db_user}."
            createuser -h ${oacs_db_host} -p ${oacs_db_port} -s -d ${oacs_db_user}
	else
            echo "====== DB setup: Already exists: oacs_db_user ${oacs_db_user}."
        fi

        echo "====== DB setup: Checking if database with name ${oacs_db_name} exists..."
        echo "====== DB setup: psql -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc \"SELECT 1 FROM pg_database WHERE datname='${oacs_db_name}'\""
        db_exists=$(psql -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc \"SELECT 1 FROM pg_database WHERE datname='${oacs_db_name}'\")
        if [ "$db_exists" != "1" ] ; then
            echo "====== DB setup: Database ${oacs_db_name} does not exist yet, creating..."
            echo "====== DB setup: createdb -h ${oacs_db_host} -p ${oacs_db_port} -E UNICODE ${oacs_db_name}"
            createdb -h ${oacs_db_host} -p ${oacs_db_port} -E UNICODE ${oacs_db_name}
            echo "====== DB setup: psql -h ${oacs_db_host} -p ${oacs_db_port} -d ${oacs_db_name} -tAc \"create extension hstore\""
            psql -h ${oacs_db_host} -p ${oacs_db_port} -d ${oacs_db_name} -tAc \"create extension hstore\"
        fi
    fi

else
    echo "====== Not first container startup"
fi

if [ -e /run/secrets/psql_password ] ; then
    export db_password=$(cat /run/secrets/psql_password)
    echo "====== found /run/secrets/psql_password: SET db_password ${db_password}"
fi

#
# Collect always the docker daemon data saved in /scripts/docker.config
#
echo "====== Collect docker daemon data from /var/run/docker.soc and save in /scripts/docker.config"
curl -s --unix-socket /var/run/docker.sock -o /scripts/docker.config http://localhost/containers/${HOSTNAME}/json

echo "====== Running /scripts/docker-setup.tcl"
/usr/local/ns/bin/tclsh /scripts/docker-setup.tcl
ls -ltr /scripts/

echo "====== container-setup-openacs.sh finished"

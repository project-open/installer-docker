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


# ------------------------------------------------------------------
# Make sure the postgres container accepts connections
wait_for_postgres() {
        echo "====== Wait for PG: Waiting up to a minute for PostgreSQL to become available"
	wait_count=0
	wait_max=600
        echo "====== Wait for PG: pg_isready -h ${oacs_db_host} -p ${oacs_db_port} 2>/dev/null"
	while ! pg_isready -h ${oacs_db_host} -p ${oacs_db_port} 2>/dev/null; do
	    wait_count=$(($wait_count + 1))
	    if [ $wait_count -ge $wait_max ]; then
		echo "====== Wait for PG: PostgreSQL not ready after ${wait_max} attempts. Exiting."
		exit 1
	    fi
	    echo "====== Wait for PG: Waiting for PostgreSQL to be ready, attempt: ${wait_count}"
	    sleep 0.1
	done
	echo "====== Wait for PG: PostgreSQL ready now with attempt: ${wait_count}"
}




# ------------------------------------------------------------------
# Check the database password passed on from 'docker compose'
if [ -e /run/secrets/psql_password ] ; then
    db_password=$(cat /run/secrets/psql_password)
    echo "====== Found /run/secrets/psql_password: SET db_password=${db_password}"
else
    db_password="secret"
    echo "====== Did not find /run/secrets/psql_password, exiting"
    exit 1
fi



# ------------------------------------------------------------------
# Check if we need to setup the containers
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

    
    # ------------------------------------------------------------------
    # Now we have to check whether we have to create the database
    #
    echo "====== base-image '$base_image'"

    echo "====== DB setup: Use PostgreSQL"
    if [ -e /usr/local/ns/bin/nsdbpg.so ] ; then
        echo "====== DB setup: PostgreSQL library nsdbpg.so exists"
    else
        echo "====== DB setup: PostgreSQL library nsdbpg.so does NOT exist"
    fi

    # db_admin_user=${db_admin_user:-postgres}
    db_admin_user=${db_admin_user:-nsadmin}
    db_dir=/usr

    if [ "$oacs_db_host" = "host.docker.internal" ] ; then
        echo "====== DB setup: Use the Database on the docker host"
        # We assume that the DB is created and already set up
    else
        echo "====== DB setup: Use the Database in a 'postgres' container"
	echo "====== DB setup:" db_admin_user=$db_admin_user db_dir=$db_dir oacs_db_name=$oacs_db_name oacs_db_host=$oacs_db_host oacs_db_user=$oacs_db_user
	# We assume that this is a fresh DB that needs to be set up

        echo "====== DB setup: Configuration variables"
        env | sort

	# Make sure the postgres container has finished init
	wait_for_postgres
	
	# ------------------------------------------------------------------
        echo "====== DB setup: Checking if database with name ${oacs_db_name} exists..."
        echo "====== DB setup: PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc \"SELECT 1 FROM pg_database WHERE datname='${oacs_db_name}'\""
        db_exists=$(PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc "SELECT 1 FROM pg_database WHERE datname='${oacs_db_name}'")
        if [ "$db_exists" != "1" ] ; then
            echo "====== DB setup: Database ${oacs_db_name} does not exist yet, creating..."
            echo "====== DB setup: createdb -h ${oacs_db_host} -p ${oacs_db_port} -E UNICODE ${oacs_db_name}"
            PGPASSWORD=${db_password} createdb -h ${oacs_db_host} -p ${oacs_db_port} -E UNICODE ${oacs_db_name}
            echo "====== DB setup: psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} -d ${oacs_db_name} -tAc \"create extension hstore\""
            PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} -d ${oacs_db_name} -tAc "create extension hstore"
	else
            echo "====== DB setup: Already exists: oacs_db_name=${oacs_db_name}"
        fi

	# ------------------------------------------------------------------
        echo "====== DB setup: Checking if data model already loaded..."

	# Show pg_tbles
        # PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} ${oacs_db_name} -tAc "SELECT * FROM pg_catalog.pg_tables"
	
        echo "====== DB setup: PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} ${oacs_db_name} -tAc \"SELECT count(*) FROM pg_catalog.pg_tables WHERE tablename='users'\""
        model_exists=$(PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} ${oacs_db_name} -tAc "SELECT count(*) FROM pg_catalog.pg_tables where tablename = 'users'")

	if [ "$model_exists" != "1" ] ; then
            echo "====== DB setup: Data-model does not exist (model_exists=${model_exists}), loading..."
	    # Redirect STDOUT to /tmp/project-open-v52.log, so we should only see errors in the logs:
            gunzip < project-open-vanilla-v52.sql.gz | PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} -d ${oacs_db_name} > ${oacs_serverroot}/import.project-open-v52.log
	    # gunzip < project-open-vanilla-v52.sql.gz | PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} -d ${oacs_db_name}
	    
	else
            echo "====== DB setup: Data-model already exists (model_exists=${model_exists})"
        fi
	
    fi

else
    echo "====== Not first container startup"
    # Make sure the postgres container has finished init
    wait_for_postgres
fi


# Show pg_tbles
PGPASSWORD=${db_password} psql -U ${oacs_db_user} -h ${oacs_db_host} -p ${oacs_db_port} ${oacs_db_name} -tAc "SELECT relname, n_live_tup FROM pg_stat_user_tables where n_live_tup > 0 ORDER BY relname;"


#
# Collect always the docker daemon data saved in /scripts/docker.config
#
echo "====== Collect docker daemon data from /var/run/docker.soc and save in /scripts/docker.config"
curl -s --unix-socket /var/run/docker.sock -o /scripts/docker.config http://localhost/containers/${HOSTNAME}/json

echo "====== Running /scripts/docker-setup.tcl, creating /script/docker-dict.tcl"
/usr/local/ns/bin/tclsh /scripts/docker-setup.tcl
ls -ltr /scripts/

echo "====== container-setup-openacs.sh finished"
# After this, compose.yaml will continue with the following command:
# /usr/local/ns/bin/nsd -f -t ${nsdconfig:-/usr/local/ns/conf/openacs-config.tcl} -u nsadmin -g nsadmin

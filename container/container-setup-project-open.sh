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


echo "==== container-setup-project-open.sh called --"

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
    echo "==== First container startup"

    echo "==== Content of oacs_serverroot=${oacs_serverroot}" 
    ls -l ${oacs_serverroot}
    
    mkdir -p ${oacs_serverroot}/log
    #mkdir -p ${oacs_serverroot}/www/SYSTEM

    if [ ! -f ${oacs_serverroot}/install.xml ] ; then
        echo "==== Using Install file: ${install_file:-openacs-xowf-install.xml}"
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
        echo "==== We have no OpenACS packages, install from GIT"
        ls -l ${oacs_serverroot}

        echo "==== Cloning packages from GIT"
	# git clone -b master https://gitlab.project-open.net/project-open/packages.git
        ls -l ${oacs_serverroot}
	
        cvs -d:pserver:anonymous@cvs.openacs.org:/cvsroot -Q checkout -r ${oacs_core_tag} acs-core
        if [ ! -d "packages" ] ; then
            #
            # This is for CVS vs. tar checkouts: Move files from openacs-4/* one level up.
            #
            mv $(echo openacs-4/[a-z]*) .
        fi

        #
        # Get content from the installer packages to the install location
        #
        cp ${oacs_serverroot}/packages/acs-bootstrap-installer/installer/www/*.* ${oacs_serverroot}/www/
        cp ${oacs_serverroot}/packages/acs-bootstrap-installer/installer/www/SYSTEM/*.* ${oacs_serverroot}/www/SYSTEM
        cp ${oacs_serverroot}/packages/acs-bootstrap-installer/installer/tcl/*.* ${oacs_serverroot}/tcl/

        #
        # Get more packages
        #
        echo "==== Check out application packages from CVS...."
        cd ${oacs_serverroot}/packages
        cvs -d:pserver:anonymous@cvs.openacs.org:/cvsroot -Q checkout -r ${oacs_packages_tag} xotcl-all
        cvs -d:pserver:anonymous@cvs.openacs.org:/cvsroot -Q checkout -r ${oacs_packages_tag} \
            acs-developer-support \
            attachments \
            richtext-ckeditor4 \
            openacs-bootstrap5-theme \
            bootstrap-icons \
            xowf

        #rm /var/www/openacs/install.xml

        if [ "${install_dotlrn}" = "1" ] ; then
            cvs -d:pserver:anonymous@cvs.openacs.org:/cvsroot -Q checkout -r ${oacs_packages_tag} dotlrn-all
        fi
        echo "==== Packages checked out from CVS done."
        ls -l ${oacs_serverroot}/packages

        #
        # Set permissions on server sources and log files
        #
        chown -R nsadmin:nsadmin ${oacs_serverroot}
        chmod -R g+w ${oacs_serverroot}

        #
        # Check certificate
        #
        if [ ! -e ${oacs_certificate} ] ; then
            echo "==== No certificate found, using self-signed certificate from NaviServer installation."
            ln -sf /usr/local/ns/etc/server.pem ${oacs_certificate}
        fi

        #
        # Make nsstats available under "/admin/nsstats" on every subsite.
        #
        if [ ! -e  ${oacs_serverroot}/packages/acs-subsite/www/admin/nsstats.tcl ] ; then
            cp /usr/local/ns/pages/nsstats.* ${oacs_serverroot}/packages/acs-subsite/www/admin
        fi
    else
        echo "==== Packages are already installed, use existing (external?) installation"
    fi

    #
    # Now we have to check, whether we have to create the database
    #
    echo "==== base-image '$base_image'"

    echo "==== Use PostgreSQL"
    if [ -e /usr/local/ns/bin/nsdbpg.so ] ; then
        echo "==== PostgreSQL library nsdbpg.so exists"
    fi

    db_admin_user=${db_admin_user:-postgres}
    db_dir=/usr

    if [ "$oacs_db_host" = "host.docker.internal" ] ; then
        echo "==== Use the Database on the docker host"
        #
        # We assume, the DB is created and already set up
        #
    else
        echo "==== Use the Database in the container"
        #
        # Configure the database in the DB container
        #
        echo "==== Configuration variables":
        env | sort
        echo "===== DB setup:" db_admin_user=$db_admin_user db_dir=$db_dir oacs_db_name=$oacs_db_name oacs_db_host=$oacs_db_host oacs_db_user=$oacs_db_user

	# Fraber 2024-12-11: I believe the PostgreSQL user creation now happens directly in the postgres container
	
        #echo "==== Checking if oacs_db_user ${oacs_db_user} exists in db..."
        #dbuser_exists=$(su ${db_admin_user} -c "${db_dir}/bin/psql -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${oacs_db_user}'\"")
        #if [ "$dbuser_exists" != "1" ] ; then
        #    echo "==== Creating oacs_db_user ${oacs_db_user}."
        #    su ${db_admin_user} -c "${db_dir}/bin/createuser -h ${oacs_db_host} -p ${oacs_db_port} -s -d ${oacs_db_user}"
        #fi

        #echo "==== Checking if database with name ${oacs_db_name} exists..."
        #db_exists=$(su ${db_admin_user} -c "${db_dir}/bin/psql -h ${oacs_db_host} -p ${oacs_db_port} template1 -tAc \"SELECT 1 FROM pg_database WHERE datname='${oacs_db_name}'\"")
        #if [ "$db_exists" != "1" ] ; then
        #    echo "==== Creating db ${oacs_db_name}..."
        #    su ${db_admin_user} -c "${db_dir}/bin/createdb -h ${oacs_db_host} -p ${oacs_db_port} -E UNICODE ${oacs_db_name}"
        #    su ${db_admin_user} -c "${db_dir}/bin/psql -h ${oacs_db_host} -p ${oacs_db_port} -d ${oacs_db_name} -tAc \"create extension hstore\""
        #fi
    fi


else
    echo "==== Not first container startup"
fi

if [ -e /run/secrets/psql_password ] ; then
    export db_password=$(cat /run/secrets/psql_password)
    echo "==== found /run/secrets/psql_password: SET db_password ${db_password}"
fi

#
# Collect always the docker daemon data saved in /scripts/docker.config
#
echo "==== Collect docker daemon data from /var/run/docker.soc and save in /scripts/docker.config"
curl -s --unix-socket /var/run/docker.sock -o /scripts/docker.config http://localhost/containers/${HOSTNAME}/json

echo "==== Running /scripts/docker-setup.tcl"
/usr/local/ns/bin/tclsh /scripts/docker-setup.tcl
ls -ltr /scripts/

echo "==== container-setup-openacs.sh finished"

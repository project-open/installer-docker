#!/bin/bash
# ------------------------------------------------------------------
# Checkout sources and build ]po[
#
# (c) Frank Bergmann (frank.bergmann@project-open.com)
# Released under MIT license
# ------------------------------------------------------------------

CURPWD=$PWD
echo "===== ================================================"
echo "===== build.bash: Starting in folder: $CURPWD"
echo "===== ================================================"
echo "===== "

echo "===== Getting the ]project-open[ installer frame"
echo "===== cd $CURPWD"
cd $CURPWD
echo "===== git clone https://gitlab.project-open.net/project-open/installer-linux.git"
git clone https://gitlab.project-open.net/project-open/installer-linux.git
echo "===== cd installer-linux"
cd installer-linux
git pull


echo "===== Getting the ]project-open[ source code"
echo "===== cd $CURPWD"
cd $CURPWD
echo "===== git clone https://gitlab.project-open.net/project-open/packages.git"
git clone https://gitlab.project-open.net/project-open/packages.git
echo "===== cd packages"
cd packages
echo "===== git pull"
git pull
echo "===== git submodule update --recursive --init"
git submodule update --recursive --init


echo "===== cd $CURPWD"
cd $CURPWD


echo "===== Creating self-signed certificate"
openssl req -x509 -newkey rsa:4096 -keyout openacs/etc/privkey.pem -out openacs/etc/certificate.crt -sha256 -days 3650 -nodes -subj "/C=ES/ST=Catalonia/L=Barcelona/O=Project Open Business Solutions, S.L./CN=project-open-v52.project-open.net"
cat openacs/etc/certificate.crt openacs/etc/privkey.pem > openacs/etc/certfile.pem


echo "===== Done build"
echo "===== "
echo "===== You can now type 'docker compose up' to start ]po[ using Docker"

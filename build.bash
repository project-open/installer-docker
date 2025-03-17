#!/bin/bash
# ------------------------------------------------------------------
# Checkout sources and build ]po[
#
# (c) Frank Bergmann (frank.bergmann@project-open.com)
# Released under MIT license
# ------------------------------------------------------------------

CURPWD=$PWD
echo "===== Starting in folder: $CURPWD"

echo "===== Getting the ]project-open[ installer frame"
echo "git clone https://gitlab.project-open.net/project-open/installer-linux.git"
git clone https://gitlab.project-open.net/project-open/installer-linux.git




echo "===== Getting the ]project-open[ source code"
echo "git clone https://gitlab.project-open.net/project-open/packages.git"
git clone https://gitlab.project-open.net/project-open/packages.git

echo "cd packages"
cd packages

echo "git submodule update --recursive --init"
git submodule update --recursive --init

echo "cd $CURPWD"
cd $CURPWD




echo "===== Starting docker build process"
echo "docker compose up"
docker compose up

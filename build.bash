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


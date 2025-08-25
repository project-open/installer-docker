#!/bin/bash
# ------------------------------------------------------------------
# Undo the effect of build.bash that performs a checkout of sources and builds ]po[
#
# (c) Frank Bergmann (frank.bergmann@project-open.com)
# Released under MIT license
# ------------------------------------------------------------------

CURPWD=$PWD
echo "===== ================================================"
echo "===== build-clear.bash: Starting in folder: $CURPWD"
echo "===== ================================================"
echo "===== "


echo "===== Deleteing the ]project-open[ installer frame"
echo "===== cd $CURPWD"
cd $CURPWD
echo "===== rm -r -f installer-linux"
rm -r -f installer-linux


echo "===== Deleting the ]project-open[ source code"
echo "===== cd $CURPWD"
cd $CURPWD
echo "===== rm -r -f packages"
rm -r -f packages


echo "===== cd $CURPWD"
cd $CURPWD
echo "===== rm -f compose-up.log"
rm -f compose-up.log
echo "===== rm -f openacs/etc/privkey.pem"
rm -f openacs/etc/privkey.pem
echo "===== rm -f openacs/etc/certificate.crt"
rm -f openacs/etc/certificate.crt


echo "===== git restore openacs/etc/certfile.pem"
git restore openacs/etc/certfile.pem

echo "===== Done build-clear"

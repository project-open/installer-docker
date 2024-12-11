#!/bin/bash
# ------------------------------------------------------------------
# Cleanup everything around the ]po[ installer
#
# (c) Frank Bergmann (frank.bergmann@project-open.com)
# Released under MIT license
# ------------------------------------------------------------------

docker container rm openacs-naviserver-1
docker container rm openacs-postgres-1
docker container rm project-open-v52-naviserver-1
docker container rm project-open-v52-projop-1
docker container rm project-open-v52-postgres-1
# docker container prune --force

docker volume rm --force openacs_db_data
docker volume rm --force openacs_oacs_data
docker volume rm --force project-open-v52_db_data
docker volume rm --force project-open-v52_oacs_data
docker volume prune --force



# syntax=docker/dockerfile:1
# ----------------------------------------------------------------------------------
# Dockerfile for ]project-open[ V5.2 based on Debian
# See the README.md file for details
# Copyright (c) 2024 Frank Bergmann (frank.bergmann@project-open.com)
# This code is provided under MIT license.
# ----------------------------------------------------------------------------------

FROM gustafn/openacs:latest-bookworm

# Install some basic tools
RUN apt -qq install -y less git net-tools > /dev/null 2>&1
# RUN apt -qq install -y emacs-nox file iproute2 iputils-ping procps poppler-utils imagemagick
# RUN apt -qq install -y gcc make libpq-dev autoconf automake m4 zlib1g-dev > /dev/null 2>&1


# Copy main configuration files so we can modify them in the build environment
COPY config/container-setup-project-open.sh /scripts/container-setup-project-open.sh
COPY config/openacs-config.tcl /usr/local/ns/conf/openacs-config.tcl
COPY config/nsConfig.sh /usr/local/ns/lib/nsConfig.sh

# Copy the openacs folder with www, etc and other files
COPY openacs /var/www/openacs

# ]po[ data-model to be loaded by container-setup-project-open.sh during first start
COPY project-open-vanilla-v52.sql.gz /var/www/openacs/project-open-vanilla-v52.sql.gz

# Copy the packages folder with the actual ]po[ code
COPY packages-v52-oacs59 /var/www/openacs/packages


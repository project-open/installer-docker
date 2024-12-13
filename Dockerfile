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


# Copy the main configuration files from build environment to the container
# Not sure why Gustaf created the extra nsConfig.sh
COPY container/container-setup-project-open.sh /scripts/container-setup-project-open.sh

COPY container/nsConfig.sh /usr/local/ns/lib/nsConfig.sh

# Copy the openacs folder with www, etc and other files
COPY openacs /var/www/openacs

# Copy the ]po[ data-model
COPY project-open-v52.sql.gz /var/www/openacs/project-open-v52.sql.gz

# Copy the packages folder with the actual ]po[ code
COPY openacs-4/packages /var/www/openacs/packages


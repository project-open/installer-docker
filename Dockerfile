# syntax=docker/dockerfile:1
# ----------------------------------------------------------------------------------
# Dockerfile for ]project-open[ V5.2 based on Debian
# See the README.md file for details
# Copyright (c) 2024 Frank Bergmann (frank.bergmann@project-open.com)
# This code is provided under MIT license.

FROM gustafn/openacs:latest-bookworm

# Try running some command.
# Running now increases the image size for distribution.
# Running at container build-time risks bad network connection.
RUN apt -qq install -y imagemagick poppler-utils

# Install some basic tools
RUN apt -qq install -y imagemagick poppler-utils less git cvs procps iputils-ping iproute2 net-tools file emacs-nox
# RUN apt -qq install -y gcc make libpq-dev autoconf automake m4 zlib1g-dev


# Copy the main configuration files from build environment to the container
# Not sure why Gustaf created the extra nsConfig.sh
COPY container/container-setup-project-open.sh /scripts/container-setup-project-open.sh
COPY container/nsConfig.sh /usr/local/ns/lib/nsConfig.sh

# fraber 2024-12-11: Not necessary, nothing for ]po[ to modify
# The docker-setup.tcl creates a /scripts/docker-dict.tcl
# COPY container/docker-setup.tcl /scripts/docker-setup.tcl


# WORKDIR /var/www/openacs/

# EXPOSE 5000
# COPY . .

# ENV FLASK_APP=app.py
# ENV FLASK_RUN_HOST=0.0.0.0
# RUN apk add --no-cache gcc musl-dev linux-headers
# RUN pip install -r requirements.txt

# No command, specified in docker-compose.yaml
# CMD ["flask", "run", "--debug"]


# the data needed to build the image
# WORKDIR /usr/src/projop
# COPY . /usr/src/projop

# installation script to build the image
# RUN [ "/usr/src/projop/install.sh" ]

# initialization script to setup the peristent data the first time the container is run
# ENTRYPOINT [ "/usr/src/projop/init.sh" ]

# command to start systemd
# CMD [ "/usr/sbin/init" ]

# ----------------------------------------------------------------------------------
# Docker image configuration
# ----------------------------------------------------------------------------------

# Expose the ]project-open[ and PostgreSQL ports
# EXPOSE 8000 5432

# Volume required by systemd
# VOLUME [ "/sys/fs/cgroup" ]

# All persistent data is managed in a single volume
# VOLUME [ "/var/lib/docker-projop/runtime" ]


]project-open[ V5.2 Docker
==========================

This Docker installer is one of the three official installers
for ]project-open[, for more information please see:
https://www.project-open.net/en/list-installers

Requirements
------------

We assume you are running a docker environment on a Linux host.
Please follow the instructions at docker.com  on to how to install
and setup a docker development environment.

The following instructions assume that you have configured docker
to be used as a normal user, so there is no need to become 'root'
in order to run docker commands.

The Build Environment
---------------------

Please clone the Docker installer GitHub repo to a local directory.

```bash
git clone https://github.com/project-open/installer-docker.git
```

You will get a directory structure similar to the one below:

<pre>
installer-docker/
    bin
    config
    installer-linux
    packages
</pre>
... with the following files on the top level:

- build.bash
- clear.bash
- compose.yaml
- Dockerfile
- README.md
- ROADMAP.md

Building the System
-------------------

The installer needs several external sources, so you have to
start with the "build.bash" script:

```bash
$ ./build.bash
$ docker compose up
```

This process may take between 1 and 60 minutes, depending on your hardware.

As a result you should see debugging output from two different containers,
"postgresql-1" and "projop-1". Please open a 2nd shell and check the running containers:

<pre>
$ docker ps
CONTAINER ID   IMAGE                    PORTS                                             NAMES
7a93414117ce   project-open-v52-projop  0.0.0.0:8080->8080/tcp, 0.0.0.0:8445->8443/tcp    project-open-v52-projop-1
57cba401208e   postgres:latest          5432/tcp                                          project-open-v52-postgres-1
</pre>

Now point your favorite browser to http://localhost:8080/ and you should get the ]project-open[ login page. Enter with:

- Email: 'sysadmin@tigerpond.com'
- Password: 'system'

After playing around with ]po[ you can stop the installation:

```bash
$ docker compose down
```

To start again:

```bash
$ docker compose up
```

And to remove the images (but not the source):

```bash
$ ./clean.bash
```

Issues and Support
------------------

Please see the Issues section of the Docker installer:
https://github.com/project-open/installer-docker/issues


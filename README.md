]project-open[ V5.2 Docker
==========================

This Docker installer is one of the three official installers
for ]project-open[. For information on the official VMware
distribution and the installers for Windows and Linux please see:
https://www.project-open.net/en/list-installers

Requirements
------------

We assume you are running a docker environment on a Linux host.
Please follow the instructions at docker.com  on to how to install
and setup a docker development environment.

The following instructions assume that you have configured docker
to be used as a normal user, so there is no need to become 'root'
in order to run docker commands.

### Linux Setup

We use Ubuntu 24.04 Server for development. The instructions below 
extend the volume size and install Docker and Emacs.
```bash
sudo apt update
sudo apt upgrade -y
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
sudo apt -y install docker.io docker-compose-v2 emacs-nox
```

### Docker Setup
```bash
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```
... and logout and login again to use docker as a normal user.

The Build Environment
---------------------

Please clone the Docker installer GitHub repo to a local directory.

```bash
git clone https://github.com/project-open/installer-docker.git
```

Building the System
-------------------

The installer needs several external sources, so you have to
start with the "build.bash" script:

```bash
$ ./build.bash
```

This will clone two additional GitHub repos "installer-linux" and "packages".
After that you can start the actual process with:

```bash
$ docker compose up
```

This may take between 1 and 60 minutes, depending on your hardware.

As a result you should see debugging output from two different containers,
"postgresql-1" and "projop-1". Please open a 2nd shell and check the running containers:

<pre>
$ docker ps
CONTAINER ID   IMAGE                    PORTS                                             NAMES
7a93414117ce   project-open-v52-projop  0.0.0.0:8080->8080/tcp, 0.0.0.0:8445->8443/tcp    project-open-v52-projop-1
57cba401208e   postgres:latest          5432/tcp                                          project-open-v52-postgres-1
</pre>

Now point your favorite browser to http://localhost:8080/ and you should get the ]project-open[ login page.
Enter as a system administrator with:

- Email: 'sysadmin@tigerpond.com'
- Password: 'system'

You can also enter as a manager:

- Email: 'bbigboss@tigerpond.com'
- Password: 'ben'

or as a normal employee:

- Email: 'lleadarch@tigerpond.com'
- Password: 'laura'

These users are provided as part of the "Tigerpond" demo company
that is used to showcase the features of the system. In the next
section you will learn how to adapt this system for your own
needs.


Configure the System
--------------------

1. Fix system pathes:
   Please point your browser to the following URL (assuming the
   ]po[ containers are running on your "localhost"):
   
   http://localhost:8080/docker-fix-path-parameters

   This will modify the ]po[ filesystem paths, which are different
   compared to a "vanilla" VM.
   You should see something about "Fix path parameters for Docker".
   Now you have to restart Docker.

2. System Configuration Wizard:
   Please work though the System Configuration Wizard, which is the
   only functionality available on a fresh system.
   This wizard will ask for your business sector etc. and disable
   functionality you probably don't need.

3. Interactive Administration Guide:
   Please work through the "Interactive Administration Guide":
   This guide is visible on the "Home" tab only for system administrators.
   Please expand the blue arrows to the left of "Simplify Your System".

4. Configure certificates:
   The HTTPS port on localhost is by default 8443, the default installation
   uses a self-signed certificate.
   
   Once your configuration has been set up, you will need SSL certificates.
   The easiest way to activate a real certificate.pem (PEM format with
   certificate and private key) is to manually copy it into the container:
   ```bash
   docker cp certificate.pem installer-docker-projop-1:/var/www/openacs/etc/certfile.pem
   ```
   After that please restart the server.

   In addition to the certificate, you will need to set the parameter
   UtilCurrentLocationRedirect to "https://server" (no trailing "/") in
   http://localhost:8080/intranet/admin/parameters/

5. Backup:
   It is sufficient to backup the container setup once.
   However, the docker volumes require daily backups with the container down.



Other actions
-------------

After playing around with ]po[ you can stop the installation:

```bash
$ docker compose down
```

To start again please use:

```bash
$ docker compose up
```

To remove the images completely and to start over (but not the source code):

```bash
$ ./clean.bash
```

Issues and Support
------------------

Please see the Issues section of the Docker installer:<br>
https://github.com/project-open/installer-docker/issues


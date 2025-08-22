Docker Installer for ]po[ Roadmap
=================================

This document helps the ]po[ team to document the current release
and plan the next releases.


]po[ V5.2.1 Docker Installer
--------------------------

This is a bug fix version of the V5.2.0 installer.

ToDo:
- Backup doesn't work because PG is not listening locally:
  Started to modify intranet-core/www/admin/backup/pg_dump.tcl
  to work with ~/.pgpass 

- Release a new version of packages.git repo with the new
  versions of acs-tcl and other packages.
  Then clean the packages created by build.bash and re-run
  the installer from scratch.
  
- There is an error in container-setup-project-open.sh.
  The error doesn't seem to cause an issue, though:
	====== Running /scripts/docker-setup.tcl, creating /script/docker-dict.tcl
	projop-1    | child process exited abnormally
	projop-1    |     while executing
	projop-1    | "exec curl -s --unix-socket /var/run/docker.sock -o /scripts/docker.config http://localhost/containers/$::env(HOSTNAME)/json"
	projop-1    |     (file "/scripts/docker-setup.tcl" line 3)

- Create a new version of Repo "packages" for this release

- Task Management "Tasks for User":
  Should disappear if there are no tasks at all

- Test if filestorage is copied correctly


Done V5.2.1:
- Test the entire installer from scratch again
- /usr/local/bin/dot doesn't exist for graphviz
- HTTP 404 redirection error with /logo.gif
  - Add logo
  - Check why redirection error
- Unable to get file list from '/web/projop/filestorage/home':
  find_path=/web/projop/filestorage/home
  can't create directory "/web": permission denied
  Also fix the other paths for backup etc.
- Create folder for ~/filestorage with subfolders with
  templates etc.
- util_current_location about unknown driver "http"
  (should be "nssock"?)
- Invalid command name "im_indicator_home_page_component"
- Set parameter UtilCurrentLocationRedirect to the
  actual address, explain in README.md




Done V5.2.0
-----------

This is the "official" Docker installer for ]po[.

- Started build.bash, needs to be finished
- Update version number of ]po[ packages
- Started to checkout GitLab installer-linux.
  Now the Dockerfile etc need to be modified
  accordingly


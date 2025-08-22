Docker Installer for ]po[ Roadmap
=================================

This document helps the ]po[ team to document the current release
and plan the next releases.


]po[ V5.2.1 Docker Installer
--------------------------

This is the first "official" Docker installer from ]po[.

ToDo:
- Unable to get file list from '/web/projop/filestorage/home':
  find_path=/web/projop/filestorage/home
  can't create directory "/web": permission denied
  Also fix the other paths for backup etc.
  
- Create folder for ~/filestorage with subfolders with
  templates etc.

- Set parameter UtilCurrentLocationRedirect to the
  actual address.
  - Add in installer
  - Explain in README.md

- Release a new version of packages.git repo with the new
  versions of acs-tcl and other packages.
  Then clean the packages created by build.bash and re-run
  the installer from scratch.
  
- invalid command name "im_indicator_home_page_component"

- util_current_location about unknown driver "http"
  (should be "nssock"?)

- No open issues at the moment (2025-03-20)

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

Done V5.2.0:
- Started build.bash, needs to be finished
- Update version number of ]po[ packages
- Started to checkout GitLab installer-linux.
  Now the Dockerfile etc need to be modified
  accordingly


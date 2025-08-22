# /www/docker-fix-path-parameters.tcl
#
# Copyright (C) 2004-2025 ]project-open[
#
ad_page_contract {
    Convert some parameters values from Windows to Linux
} {
    { return_url "/intranet/" }
}

# This page has to be executable without permissions for everyone
# It doesn't take any parameter anyway.


# ------------------------------------------------------
# Start of page
# ------------------------------------------------------

set page_title "Fix path parameters for Docker"

ad_return_top_of_page "[im_header]\n[im_navbar]"
ns_write "<h1>$page_title</h1>\n"
ns_write "<ul>\n"

# Determine the current path of the installation
# /var/www/openacs instead of /web/projop in vanilla installations
set serverroot $::acs::rootdir


# ------------------------------------------------------
# Convert all pathes to the Linux style, asuming "$server_name" as the name
# of the server
#
ns_write "<li>Converting pathes from \"/web/projop to $serverroot\n"
db_dml update_pathes "
	update apm_parameter_values
	set attr_value = '$serverroot' || substring(lower(attr_value) from 'c:/projectopen(.*)')
	where attr_value ~* '^c:/projectopen/'
"

db_dml update_pathes "
	update apm_parameter_values
	set attr_value = '$serverroot' || substring(lower(attr_value) from 'c:/project-open(.*)')
	where lower(attr_value) ~* '^c:/project-open/'
"

db_dml update_pathes "
	update apm_parameter_values
	set attr_value = '$serverroot' || substring(lower(attr_value) from '/web/projop(.*)')
	where lower(attr_value) ~* '^/web/projop/'
"

# ------------------------------------------------------
ns_write "<li>Setting specific parameters\n"
db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/templates'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'InvoiceTemplatePathUnix'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '/var/tmp'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'tmp_path'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '/usr/bin/dot'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'graphviz_dot_path'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/projects'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'CompanyBasePathUnix'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/conf_items'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'ConfItemBasePathUnix'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/events'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'EventBasePathUnix'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/risks'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'RiskBasePathUnix'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/home'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'HomeBasePathUnix'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/projects'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'ProjectBasePathUnix'
	)
"

db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/tickets'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'TicketBasePathUnix'
	)
"


db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/project_sales'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'ProjectSalesBasePathUnix'
	)
"


db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/users'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'UserBasePathUnix'
	)
"


db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/costs'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'CostBasePathUnix'
	)
"


db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/backup'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'BackupBasePathUnix'
	)
"


db_dml update "
	update apm_parameter_values
	set attr_value = '$serverroot/filestorage/bugs'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'BugBasePathUnix'
	)
"



# Convert the find command
ns_write "<li>Converting /bin/find to /usr/bin/find\n"
db_dml update_pathes "
	update apm_parameter_values
	set attr_value = '/usr/bin/find'
	where attr_value = '/bin/find'
"



# PostgreSQL backup 
ns_write "<li>Converting PG path from /pgsql/bin/ to /usr/bin/\n"
db_dml update_pathes "
	update apm_parameter_values
	set attr_value = '/usr/bin/'
	where parameter_id in (
		select	parameter_id
		from	apm_parameters
		where	parameter_name = 'PgPathUnix'
	)
"



ns_write "</ul>\n"
ns_write "<p>You can now return to the <a href=$return_url>previous page</a>.</p>"
ns_write [im_footer]

im_permission_flush


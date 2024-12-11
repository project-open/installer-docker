#!/usr/local/ns/bin/tclsh
# ------------------------------------------------------------------
# /scripts/docker-setup.tcl
# Script by Gustaf Neumann
# ------------------------------------------------------------------

# Apparently saving the docker configuration of the container
exec curl -s --unix-socket /var/run/docker.sock -o /scripts/docker.config http://localhost/containers/$::env(HOSTNAME)/json

package require json

set F [open /scripts/docker.config]; set json [read $F]; close $F
set jsonDict [json::json2dict $json]

#
# The docker.config file is a JSON file containing "HostIp" and
# "HostPort" for the plain HTTP port (internally "8080/tcp") and the
# HTTPS port (internally "8443/tcp") .
#
#    ...
#    "NetworkSettings": {
#        "Ports": {
#           "8080/tcp": [
#             {
#                "HostIp": "192.168.1.192",
#                "HostPort": "50170"
#             }
#           ],
#           "8443/tcp": [
#             {
#                "HostIp": "192.168.1.192",
#                "HostPort": "50171"
#             }
#           ],
#        }
#     },
#     ...
#
foreach {label networkMappings} [dict get $jsonDict NetworkSettings Ports] {
    if {$label eq "8080/tcp"} {
        set proto http
    } elseif {$label eq "8443/tcp"} {
        set proto https
    } else {
        puts stdout "docker-setup.tcl: error: unexpected label '$label' in $networkInfo"
        continue
    }
    puts stdout "docker-setup.tcl: processing docker network label '$label'"
    set networkMappings [lindex $networkMappings 0]
    try {
        set host [dict get $networkMappings HostIp]
        set port [dict get $networkMappings HostPort]
        dict set containerMapping $label [list proto $proto host $host port $port]
    } on error {errorMsg} {
        puts stdout "docker-setup.tcl: error: processing docker network leads to error: $errorMsg\n<<<$networkMappings>>>"
    }
}

set F [open /scripts/docker-dict.tcl w]
puts $F [list namespace eval ::docker {}]
puts $F [list set ::docker::jsonDict $jsonDict]
puts $F [list set ::docker::containerMapping $containerMapping]
close $F
puts stdout "docker-setup.tcl: script /scripts/docker-dict.tcl generated"

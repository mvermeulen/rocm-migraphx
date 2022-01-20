#!/bin/bash
#
# Dump a sqlite3 database
#
sqlite3 $1 <<EOF
.output backup.sql
.dump
.exit
EOF

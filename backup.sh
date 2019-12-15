#!/bin/sh

sqlite3 dnd.sqlite3 <<END
.output backup.sql
.dump
END


#!/bin/sh
kill -9 `ps x | grep -e "[0-9] ruby script/server -e production --port 3002" | awk '{ print $1 }'`

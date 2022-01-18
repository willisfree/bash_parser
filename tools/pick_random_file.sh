#!/bin/bash

# Pick random file from a directory by supplied path and print it's full path on stdout
# $1 arg must be a full path to directory

directory=$1

[ -z "$directory" ] && exit

printf "%s" "$(shuf -en 1 "$directory"/*)"

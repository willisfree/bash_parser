#!/bin/bash

# edited: 23.04.2020

source /usr/local/bin/hlib.sh

function cd_physical_path() {
	# below directory independent method will work:
	# 1. if this script will be run from symlinked directory 
	# 2. it this script will be run by symlink itself
	# 3. and of course if this scipt was called directly
	this_script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
	debug_log "Real path of this script is $this_script_dir"
	cd "$this_script_dir"
}; cd_physical_path

url=$1
[ ! "$url" ] && die "yout must specify url"

used_links=../data/used_links.txt

#todo: load used links in an array for speed
function was_used() {
	local link=$1
	while IFS= read -r used_link; do
		if [ "$used_link" = "$link" ]; then
			debug_log "link was used"
			return 0;	# link was used
		fi
	done < "$used_links"
	debug_log "link wasn't used"
	return 1;			# link was't used
}

was_used "$url"

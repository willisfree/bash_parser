#!/bin/bash

# debug_log here
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

links=../data/links.txt
used_links=../data/used_links.txt
page=page.html

#todo: load used links in an array for speed
function was_used() {
	local link=$1
	while IFS= read -r used_link; do
		if [ "$used_link" = "$link" ]; then
			return 1;	# link was used
		fi
	done < "$used_links"
	return 0;			# link was't used
}

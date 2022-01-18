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

# initialization
base_url=$1
[ ! "$base_url" ] && die "you must provide url"
links_num=$2
[ ! "$links_num" ] && links_num=100

links=../data/links.txt
used_links=../data/used_links.txt
page=page.html

# kwork 
url_select=".wants-card__header-title > a::attr(href)"

# youdo
<< \///
base_url="https://youdo.com/tasks-all-any-webdevelopment-3"
url_select="a.b-tasks__item__title::attr(href)"
///


#todo: load used links in an array for speed
function was_used() {
	#echo "INTERESTING: $link"
	local link=$1
	#echo "LOCAL: $link"
	while IFS= read -r used_link; do
		if [ "$used_link" = "$link" ]; then
			return 0;	# link was used
		fi
	done < "$used_links"
	return 1;			# link was't used
}

touch "$links" "$used_links"

wget -k -q "$base_url" -U firefox -O "$page"

buffer=$(cat "$page" | hxnormalize -x 2>/dev/null | hxselect -c -s'\n' "$url_select")
[ ! "$buffer" ] && die "failed to get links from this page: $base_url"

while IFS= read -r link && [ $links_num -ne 0 ]; do
	if ! was_used "$link"; then
		printf "%s\n" "$link" #| tee -a "$used_links"
	else
		debug_log "link was used already: $link"
	fi
	((links_num--))
done <<< "$buffer"

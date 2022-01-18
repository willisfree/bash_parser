#!/bin/bash

# post_link.sh 22.04.20
# get link, convert it to post and make publication

function cd_physical_path() {
        # debug_log here
        source /usr/local/bin/hlib.sh

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

./link_was_used.sh "$url" && die "$url was used already"

# convert to csv
../links_to_csv_posts/link_to_csv_str.sh "$url"
exit_if_failed

# convert to html
html_post=$(../csv_post_to_html_post/generate_post ../data/current_posts)
exit_if_failed

# save link to used and make publication
[ "$html_post" ] && {
	printf "%s\n" "$url" >> ../data/used_links.txt
	../make_post/start.sh "$html_post"
	exit 0
}

debug_log "failed to make publication"
exit 1

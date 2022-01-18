#!/bin/bash

# plan_post.sh 28.03.20
# get newest unused link from specified category
# convert it and post right now

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

category=$1

[ ! "$category" ] && die "you must provide category: dev, seo, market, design, text, audio"

# notes:
# current_posts clears every iteration because there is can be case when we sucess to processe next link to csv post but failed 
# to generate html from this post and increment post's counter so in next iteration if all will be good we eventually post new
# html post, but now there is one csv post wich never be publish
# though originaly it was in this way because either nor link_to_csv_str.sh nor generate_post report error codes correctly
# (now it fixed i think)
# end of notes;

# get newest unused link from site
page_num=1
found=0
max_tries=3
while [ $found -eq 0 ] && [ $page_num -le $max_tries ]; do
	new_links=($(../collect_links/collect_links.sh -c $category -s $page_num -n 1))
	for unused_link in ${new_links[@]}; do
		# ../data/current_posts will contain oly one post in time
		# save previous post
		cat ../data/current_posts >> ../data/current_backups
		./del_post.sh
		./reset_next_post.sh
		../links_to_csv_posts/link_to_csv_str.sh $unused_link
		#exit_if_failed
		html_post=$(../csv_post_to_html_post/generate_post ../data/current_posts)
		#exit_if_failed
		if [ $? -eq 0 ] && [ "$html_post" ]; then
			found=1
			printf "%s\n" "$unused_link" >> ../data/used_links.txt
			break;
		fi
	done
	((page_num++))
done

#echo -------POST----------
#"$html_post"
#echo -------POST----------

../make_post/start.sh "$html_post"

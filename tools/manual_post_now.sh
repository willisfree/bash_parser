#!/bin/bash

# manual_post.sh 03.07.20
# read user's input
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

function yes() {
        [[ $1 == [yY] ]] && return 0;
        return 1;
}

# $1 arg must be prompt
# return user's input
# note: read builtin remove all spaces at the beginning of input
function read_input() {
        local input
        read -p "$1" input
        printf "%s" "$input"
}

# Read until user doesn't input correct value; case insensitive
# $1 arg must be a prompt
# $2 arg must be a string with valid numbers
# return user's input
function read_while() {
        local prompt=$1
        local valid=$2
        local input=$(read_input "$prompt")
        while [[ ${input,,} != [${valid,,}] ]]; do
                input=$(read_input "$prompt")
        done
        printf "%s" "$input"
}


# notes:
# current_posts clears every iteration because there is can be case when we sucess to processe next link to csv post but failed 
# to generate html from this post and increment post's counter so in next iteration if all will be good we eventually post new
# html post, but now there is one csv post wich never be publish
# though originaly it was in this way because either nor link_to_csv_str.sh nor generate_post report error codes correctly
# (now it fixed i think)
# end of notes;

	# ../data/current_posts will contain oly one post in time
	# save previous post
	cat ../data/current_posts >> ../data/current_backups
	./del_post.sh
	./reset_next_post.sh
	../links_to_csv_posts/manual_to_csv_str.sh
	html_post=$(../csv_post_to_html_post/generate_post ../data/current_posts)
	err_code=$?
	[ $err_code -ne 0 ] && [ ! "$html_post" ] && echo FAILED && exit $err_code

echo -------------------------------
echo "$html_post"
echo -------------------------------

make_post=$(read_while "Make publication?(y/n): " "yn")

yes "$make_post" && ../make_post/start.sh "$html_post"

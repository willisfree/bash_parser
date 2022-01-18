#!/usr/bin/bash

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

# doesn't support multiple write into one line (must be call once for one csv line)
function str_to_csv() {
	csv_str=$(printf "%s\0" "$@" | ./escape_dquotes.sh | xargs -0 printf "\"%s\"\0" | paste -zsd,)
	#echo 1>&2 "DEBUG: " "$csv_str"
	printf "%s" "$csv_str"
}

function read_multiline_str() {
	:;
	# idea for multiple string read with read -p:
	# replace cat and redirection with read in loop and add new string to previous
}

exec 3>&0
exec 4>&1
function read_string() {
	echo "$1" 0>&3 1>&4 
	#echo "(hint: press Ctrl-d when your input is finished)" 0>&3 1>&4 
	local str=$(cat -) 0>&3
	printf "%s" "$str"
}

function init() {
	title=$(read_string "Title: ")
	description=$(read_string "Description: ")
	price=$(read_string "Price (empty if price is set up by convention): ")
	[ -z "$price" ] && price="по договорённости"
	nickname=$(read_string "Customer nickname: ")
	while [ "${nickname:0:1}" != "@" ]; do
		nickname=$(read_string "Customer nickname (@nickname): ")
	done
}; init

data_path=../data
page="$data_path"/page.html
post="$data_path"/post_$(date +%Y%m%d).txt
post_link="$data_path"/current_posts
select=./html_select.sh

#if ! test -L "$post_link"; then	# just an alternative way
if [ ! -L "$post_link" ]; then
	printf "\"%s\" symlink was created\n" "$post_link"
	ln -sf "$post" "$post_link" 	# for convenience of testing;
					# don't create important files or dirs with "post" name! (ln -f will delete it)
	else
		post=$post_link		# test it
fi

preview_link=$(./get_preview_link.sh "$title" "$price")

# write to file
str_to_csv "$nickname" "$nickname" "$title" "$description" "$price" "" "$preview_link" >> $post

printf "\n" >> $post

# success
exit 0

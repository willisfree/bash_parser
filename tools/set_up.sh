#!/bin/bash

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

# Run necessary scripts with some user's settings
# i.e grab all links, convert it to csv posts and post number of posts which you want to publish

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

function is_equal() {
	[[ $1 == $2 ]] && return 0
	return 1
}

function yes() {
	[[ $1 == [yY] ]] && return 0;
	return 1;
}

# max signed int on x64
function max_sint_x64() {
	echo $((2**63-1))
}

# min signed int on x64
function min_sint_x64() {
	echo $((2**63))
}

function read_sint() {
	#local min=$(min_sint_x64)
	#local max=$(max_sint_x64)
	local prompt=$1
	local min=$2
	local max=$3
	#echo MIN $min
	#echo MAX $max
	local int=$(read_input "$prompt")
	shopt -s extglob
	#echo INT: ${int//?(-)[0-9]}
	# handle following cases: empy strings, numbers with zeroes at the beginning (disable interpretation like octal number)
	while [[ -z $int || ${int//?(-)[0-9]} || (${int##0*0} -ge $max) || (${int##0*0} -le $min) ]]; do
		int=$(read_input "$prompt")
		#echo INT: ${int//?(-)[0-9]}
	done
	shopt -u extglob
	printf "%s" "$int"
}
#read_sint ">_:" -3 100

# Read until user doesn't input unsigned int;
# $1 arg must be a prompt
# $2 arg must be a string with valid numbers 
# return user's input
function read_uint() {
	local prompt=$1
	local int=$(read_input "$prompt")
	while [[ ! $input =~ ^[0-9]+$ ]]; do
		input=$(read_input "$prompt")
	done
	printf "%s" "$int"
}

function init() {
	delete_all_posts=$(read_while "Delete all collected posts?(y/n): " "yn")
	grab=$(read_while "Grab some links?(y/n): " "yn")
	make_sort=$(read_while "Sort all links?(y/n):" "yn")
	convert_to_csv=$(read_while "Convert links to CSV posts?(y/n): " "yn")
	yes $convert_to_csv && links_number=$(read_sint "How many links do you want to convert: " 0 100)
	reset_counter=$(read_while "Reset post's counter?(y/n): " "yn")
	make_post=$(read_while "Make posts?(y/n): " "yn")
	[ -z ${links_number:+word} ] && links_number=$(read_sint "How many posts do you want to make: " 0 100)
}
init

yes $delete_all_posts && ./del_post.sh
yes $grab && ../collect_links/collect_links.sh -c dev -n 2
yes $make_sort && {
	../sorting/sort ../data/links.txt > ../data/sorted_links.txt
} || cp ../data/used_links.txt ../data/sorted_links.txt
yes $convert_to_csv && {
	../links_to_csv_posts/parse_links.sh -n $links_number
}
yes $reset_counter && ./reset_next_post.sh
yes $make_post && {
	for ((links_number; links_number; --links_number)); do
		html_post=$(../csv_post_to_html_post/generate_post ../data/current_posts)
		../make_post/start.sh "$html_post"
		[  $? -ne 0 ] && exit $?
	done
}

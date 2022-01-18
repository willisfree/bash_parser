#!/bin/bash

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

api_key=your_key
SUCCESS=7

function short_link()
{
	link=$1
	[ ! "$link" ] && die "url empty in ${FUNCNAME[0]}"
	resp=$(curl --silent "https://cutt.ly/api/api.php?key="$api_key"&"$method"="$link"")
	exit_if_failed
	status=$(jq '.url.status' <<<$resp)
	short_link=$(jq '.url.shortLink' <<<$resp)
	[ $status -ne $SUCCESS ] && die "failed to short $link (server's respons status: $status)"
	printf "%s\n" "${short_link//\"/}"
}

function usage()
{
	echo "
Usage: ./short_url.sh OPTION URL

Options:
	-s, --short	short link
	-g, --stat	get stat for link
"
}

function get_url()
{
		url=$1
		[ ! "$url" ] && die "url must not be empty"
}

case $1 in
	-s|--short)
		method=short
		get_url "$2"
		short_link "$url"
		;;
	-g|--stats)	# get stats
		die "not implemented yet"
		method=stat
		get_url "$2"
		print_stat "$url"
		;;
	*)
		usage
		;;
esac

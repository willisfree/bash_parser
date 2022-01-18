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


process_link=./link_to_csv_str.sh
#links_file=../data/links.txt
links_file=../data/sorted_links.txt

number=0

function process() {
	local num=$1
	while [ $num -ne 0 ] && IFS= read -r link; do
		"$process_link" "$link"
		((num--))
	done < "$links_file"
}

while :; do
	case $1 in
		-n|--number)
			if [ "$2" ]; then
				number=$2
				shift
			else
				die "--number requires a non-empty option argument"
			fi
			;;
		--)		# means end of all options (i.e stop parsing it)
			shift
			break;
			;;
		-?*)
			debug_log "WARN: Unknown option (ignored): $1"
			;;
		*)
			break;	# There are no more options
	esac
	shift	# get next option
done

process $number

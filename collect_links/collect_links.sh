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

pages_num=0
start_page_num=1

# kwork 
common_url="https://kwork.ru/projects?"

# categories
DEVELOPMENT="c=11"
MARKETING="c=45"
SEO="c=17"
TEXT="c=5"
DESIGN="c=15"
AUDIO_VID="c=7"

function collect() {
	local pages_total=$1
	for ((i=0; i<$pages_total; ++i)); do
		local page_num=$((start_page_num+i))	# offset
		debug_log "processing url: $common_url$SELECTED&page=$page_num"
		./process_one_page.sh "$common_url${SELECTED}&page=$page_num" "$links_num"
	done
}

function select_category() {
	case $1 in
		dev)
			SELECTED=$DEVELOPMENT
			S_ID=1
			;;
		seo)
			SELECTED=$SEO
			S_ID=2
			;;
		market)
			SELECTED=$MARKETING
			S_ID=3
			;;
		text)
			SELECTED=$TEXT
			S_ID=4
			;;
		design)
			SELECTED=$DESIGN
			S_ID=5
			;;
		audio)
			SELECTED=$AUDIO_VID
			S_ID=6
			;;
		*)
			die "you must choose on of the categories: seo, dev, market, text, design"
	esac
}

while :; do
	case $1 in
		-n|--number)
			if [ "$2" ]; then
				pages_num=$2
				shift
			else
				die "--number requires a non-empty option argument"
			fi
			;;
		-s|--start-page-num)
			if [ "$2" ]; then
				start_page_num=$2
				shift
			else
				die "--start-page-num requires a non-empty option argument"
			fi
			;;
		-ln|--links-number)
			if [ "$2" ]; then
				links_num=$2
				shift
			else
				die "--links_num requires a non-empty option argument"
			fi
			;;
		-c|--category)
			if [ "$2" ]; then
				select_category "$2"
				shift
			else
				die "--category requires a non-empty option argument"
			fi
			;;
		--)		# means end of all options (i.e stop parsing it)
                        shift
                        break;
                        ;;
		-\?|-h|--help)
			die "Usage: ${BASH_SOURCE[0]} [OPTION]
	-n, --number		initial pages number"
			;;
		-?*)
			die "WARN: Unknown option (ignored): $1"
			;;
		*)
			break;
			;;
	esac
	shift
done
[ ! "$SELECTED" ] && die "ERR: category not selected (-c)"
[ ! "$S_ID" ] && die "ERR: id of selected category is not set (bug in code)"

collect $pages_num

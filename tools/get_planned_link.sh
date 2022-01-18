#!/bin/bash

# created: 23.04.2020

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

DESIGN=1
DEVELOPMENT=2
TEXT=3
SEO=4
MARKETING=5
AUDIO_VIDEO=6

planned_links=../data/planned_links.txt

function select_category() {
        case $1 in
                dev)
                        SELECTED=$DEVELOPMENT
                        ;;
                seo)
                        SELECTED=$SEO
                        ;;
                market)
                        SELECTED=$MARKETING
                        ;;
                text)
                        SELECTED=$TEXT
                        ;;
                design)
                        SELECTED=$DESIGN
                        ;;
                audio)
                        SELECTED=$AUIO_VIDEO
                        ;;
                *)
                        die "you must choose on of the categories: seo, dev, market, text, design, audio"
        esac
}
# just write pairs (link category) in file and separate them with $SEP
function write_planned() {
	# not need because i want file to be empty when no more links 
	#[ ${#pairs[@]} -eq 0 ] && die "pairs empty in write_file"

	#declare -a links=${!pairs[@]}	# actually  we already have links; but just let it be here
	local buffer
	for link in ${links[@]}; do
		buffer+=$link
		buffer+=$SEP
		buffer+=${pairs[$link]}
		buffer+=$'\n'
	done
	printf "%s" "$buffer" > "$planned_links"
	return 0
}

select_category $1

declare -A pairs
declare -a links

SEP=\;
while IFS=$SEP read -r link category; do
	[ ! "$link" ] || [ ! "$category" ] && die "broken structure of $planned_links"
	#echo $link
	#echo $category
	pairs["$link"]=$category
	links+=("$link")
done < "$planned_links"

for link in ${links[@]}; do
	if [ "$SELECTED" -eq "${pairs["$link"]}" ] && ! ./link_was_used.sh "$link"; then
		used_link=$link
		printf "%s\n" "$link"
		break
	fi
done
[ ! "$used_link" ] && die "no unused links in this category or no links at all in category"

# delete used link
unset pairs["$used_link"]
links=(${links[@]/"$used_link"/})

write_planned
exit_if_failed

exit 0

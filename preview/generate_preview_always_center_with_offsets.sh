#!/bin/bash
# --------------------------------------------------------------------
# Create preview image i.e image with a short description text on it
# and print full path to generated image on stdout

# $1 arg is a text which will be imposes on an image
# $2 arg is a pay for an offer

description=$1
pay=$2

source /usr/local/bin/hlib.sh

# below directory independent method will work:
# 1. if this script will be run from symlinked directory 
# 2. it this script will be run by symlink itself
# 3. and of course if this scipt was called directly
this_script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
debug_log "Real path of this script is $this_script_dir"
cd "$this_script_dir"
# --------------------------------------------------------------------

# Directories
fonts_path=./Fonts
templates_path=./templates		# path to original images without any changes
previews_path=./previews		# path to processed images

# Images 
background_img=./dark_ground.png	# background for readability
description_img=./description_img.png	# transparent image with text

# Sizes
#description_size=1100
description_size=680 # width

#random_template_img=$(shuf -en 1 "$templates_path"/*)

# Get next template image sorted by numbers in ascending order
function init_template_img() {
	local templates=("$templates_path"/{1..27}.png)
	local limit_index=$((${#templates[@]})) # can't be used as index; max index will be limit_index-1
	local index=../data/next_template_index

	read -r template_index <"$index"
	if [ ! "$template_index " ] || [ "$template_index" -ge $limit_index ] || [ "$template_index" -le 0 ]; then
		template_index=0
	fi

	while [ ! -e ${templates[$template_index]} ]; do
		((template_index++))
	done

	template_img=${templates[$template_index]}
	# update index
	((template_index++)); echo "$template_index" > "$index"
}

init_template_img
preview_img=$previews_path/$(basename "$template_img")

#echo "$template_img"
#echo "$preview_img"

# creates transparent image with text
function text_to_image() {
	local text=$1
	local size=$2
	local font=$3
	local image=$4
	[ ! "$text" ] || [ ! "$size" ] || [ ! "$font" ] || [ ! "$image" ] && die "one of the parameters not specified"
	
	debug_log "Converting text ($text) into image";
	convert +repage -trim -background transparent -fill "#000000" -font "$font" -pointsize 60 \
		-gravity West -size "$size" caption:"$(echo $text | fmt -w 60)" "$image"
	exit_if_failed
}

function add_text_layer() {
	local text_h=$(identify -format "%h" "$description_img")
	local text_w=$(identify -format "%w" "$description_img")
	#local height_offset=-100
	#local width_offset=170
	local height_offset=-60
	local width_offset=60

	debug_log "Adding text layer ($description_img) on image ($preview_img)";

	composite -geometry +$((1080/2-text_w/2+width_offset))+$((608/2-text_h/2+height_offset)) \
		"$description_img" "$preview_img" "$preview_img"
	exit_if_failed
}

function add_price() {
	# For East, +X is left
	#343434 grey color
	convert -gravity East -fill "#000000" -font "$fonts_path"/HKGrotesk-Medium.WOFF -pointsize 40 \
		-annotate +120+120 "$pay" "$preview_img" "$preview_img"
		#-annotate +250+190 "$pay" "$preview_img" "$preview_img"
}

[ ! "$description" ] && die "Specify description for preview";

text_to_image "$description" "$description_size" "$fonts_path"/HKGrotesk-Bold.WOFF "$description_img"
cp "$template_img" "$preview_img"
add_text_layer
add_price

# remove metadata
exiftool -all= "$preview_img" 1>&2

debug_log "$preview_img was processed successfuly"
printf "%s" "$(realpath "$preview_img")"

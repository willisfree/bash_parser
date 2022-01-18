#!/bin/bash

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

# directories
fonts_path=./Fonts
#templates_path=./templates		# path to original images without any changes
#templates_path=./materialise_palettes	# path to original images without any changes
templates_path=./1920	# path to original images without any changes
previews_path=./previews		# path to processed images

# images 
background_img=./dark_ground.png	# background for readability
description_img=./description_img.png	# transparent image with text

# sizez
#preview_width=1280
#preview_height=543
preview_width=1920
preview_height=1080
#preview_size=1280x543
background_size=1280x543
#description_size=1200x500
#description_size=1000x300
description_size=1120 #x400


#random_template_img=$(shuf -en 1 "$templates_path"/*)
random_template_img=img1.png
preview_img=$previews_path/$(basename "$random_template_img")

#echo "$random_template_img"
#echo "$preview_img"

# create background image, which will be use for a fill layer
function create_background() {
	if [ ! -e "$background_img" ]; then
		debug_log "Creating dark ground ($background_img)"
		convert -size "$background_size" xc:black "$background_img"
		exit_if_failed
	fi
}

# create transparent image with text
function text_to_image() {
	local text=$1
	local font=$2
	debug_log "Converting text ($text) into image";
	convert -background transparent -fill black -font ~/Downloads/HKGrotesk-Bold.WOFF -pointsize 80 \
		-gravity West -size "$description_size" caption:"$(echo $text | fmt -w 60)" "$description_img"
	exit_if_failed
}

# add fill layer on a templated image
function add_fill_layer() {
	debug_log "Adding fill layer ($background_img) on template image ($random_template_img) for readability";
	composite -gravity center -watermark 20.0 "$background_img" "$random_template_img" "$preview_img"
	exit_if_failed
}

function add_text_layer() {
	debug_log "Adding text layer ($description_img) on preview image ($preview_img)";
	composite  -geometry +660+460 "$description_img" "$preview_img" "$preview_img"
	exit_if_failed
}

function add_price() {
	convert -gravity center -pointsize 32 -font "$fonts_path"/"$font" -fill "#cee3f8"       \
		-annotate +0+200 "$pay" "$preview_img" "$preview_img"
}

<< \////
function crop_img() {
	local img=$1
	local size=$2
	echo "$size"
	debug_log "Crop image ($img) with size ($size)";
	convert -crop "$size" "$img" "$img"
	exit_if_failed
}
////

function resize_img() {
	local img=$1
	local size=$2
	debug_log "Resize image ($img) with size ($size)";
	convert -resize "$size" "$img" "$img"
	exit_if_failed
}

if [ -z "$description" ]; then
	die "Specify description for preview";
fi

create_background
text_to_image "$description" Roboto-Medium.ttf
#text_to_image "$description" HankenGrotesk-Bold.ttf
#text_to_image "$description" Vollkorn-Black.ttf
add_fill_layer
cp "$random_template_img" "$preview_img"

#composite -compose dst_out -gravity center -alpha set liberty.png "$preview_img" "$preview_img"
#composite  -compose src-over -gravity center liberty.png "$preview_img" "$preview_img"
#composite  -compose src-over -gravity center lib.png "$preview_img" "$preview_img"
#composite  -compose src-over -gravity center splatter_lib.png "$preview_img" "$preview_img"

add_text_layer
add_price
#resize_img "$preview_img" "$preview_width"
#crop_img "$preview_img" "x$preview_height"

# remove metadata
exiftool -all= "$preview_img" 1>&2

debug_log "$preview_img was processed successfuly"
printf "%s" "$(realpath "$preview_img")"

#!/bin/bash

source /usr/local/bin/hlib.sh

# Create preview image, load it to a server and print image's url on stdout

# $1 arg is text which will be imposes on an image
# $2 arg is a price for task

description=$1
price=$2

hashes_path=../data/uploaded_hashes

function write_log() {
	local hash=$1
	local url=$2
	printf "#%s\n%s\n\n" "$url" "$hash" >> "$hashes_path"
}

# get image path
#img=$(../preview/generate_preview.sh "$description" "$price")
img=$(../preview/generate_preview_always_center_with_offsets.sh "$description" "$price")

# load to server
temp=$(imgurbash2 "$img" 2>&1)
exit_if_failed
# use head for case when output is multiple lines (for example when xsel or xclip isn't installed imgurbash2 will complain)
url=$(head -n1 <<<$temp | cut -d' ' -f1)
delete_hash=$(head -n1 <<<$temp | cut -d'=' -f2 | cut -d')' -f1)

write_log "$delete_hash" "$url"

# print url
printf "%s\n" "$url"

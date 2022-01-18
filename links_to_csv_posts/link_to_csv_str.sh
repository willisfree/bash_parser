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


# 20.07.20 update; all tasks's url now contain /view at the end; but curl with -L must work too
url=$1/view


# specific functions for each site
# ------------------------------------
# get only ineteger value from price
function process_price() {
	# kwork
	#price=${price% *}${price##* }	# remove space between Р and Цена
	#price=${price:5}		# remove "Цена "
	#price=${price,,}		# change register of "Р"
	#price=${price/:/}

	raw_price=$price
	# 20.07.20 title was update on the kwork site
	price=${price//[^0-9 ]/}			# remove all except digits and space (so '4 000' will show correctly)
	price=$(echo $price)				# remove price leading spaces (using IFS)
	[ "${raw_price//[^до]/}" ] && price="до ${price}"	# add 'up' word if contains in original
	price=${price}р

	return 0
}

function process_title() {
	#kwork
	title_cpy=${title,,}

# first idea
<<\////
	banned="куплю"
	[ -z ${title_cpy##*$banned*} ] && die "This link contain banned title."
	banned="покупаю"
	[ -z ${title_cpy##*$banned*} ] && die "This link contain banned title."
	banned="cкуп"
	[ -z ${title_cpy##*$banned*} ] && die "This link contain banned title."
////

# second idea better
<<\////
	banned="куплю"
	case "$1" in
		*"$a"*|*"$b"*|*"$c"*)
			die "This link contain banned title."
			;;
	esac
////
# third idea even better
	blacklist=('куплю' 'скуп' 'покуп' 'xотите\ продать') # if you want to use white space so escape it like this: 'до\ ма'
	for word in ${blacklist[@]}; do
		[ -z "${title_cpy##*"$word"*}" ] && die "This link contain banned title."
	done

}
# -------------------------------------


# kwork
#title_select=".wants-card__header > .wants-card__header-title"
#descr_select=".wish_name > div"
#price_select=".wants-card__header-price.m-hidden"
#tag_select=$title_select	# no tags on kwork

# kwork 20.07.20 update
title_select=".wants-card__header-title"
descr_select=".wish_name > div"
price_select=".wants-card__header-price.m-hidden"
tag_select=$title_select	# no tags on kwork


# youdo
<< \////
title_select="h1.b-task-block__header__title"
descr_select=".b-task-block__info > .b-task-block__description > .b-nl2br"
price_select=".js-budget-text"
tag_select=".b-task-brief__item[itemprop=\"serviceType\"]"
////

warning=1

function exit_if_same() {
	if [ "$1" == "$2" ]; then
		exit 1
	fi
}

function warning() {
	printf "%s\n" "warning: $1"
}

# $1 description
# $2 value 
function is_empty() {
	if [ ! -z "${2// }" ]; then
		printf "%s was found\n" "$1"
		return 0
	else
		warning "$1 empty for $url"
		return $warning
	fi
}

# examples (both do the same):
# -- wrong --
# printf "%s\0" He\"ll\"o How\ \"ar\"e\ you End | ./escape_dquotes.sh | xargs -0 printf "\"%s\"\n"  | paste -sd,
# (IFS=$'\n' ; /usr/bin/printf "\"%s\"\n" $(printf "%s\n" He\"ll\"o How\ \"ar\"e\ you End | ./escape_dquotes.sh) |  paste -sd,)
# -- correct -- (use zero terminator instead of new line)
# printf "%s\0" He\"ll\"o How\ \"ar\"e\ you "$(a='En\nd'; printf "$a")" | ./escape_dquotes.sh | xargs -0 printf "\"%s\"\0" | paste -zsd,

# doesn't support multiple write into one line (must be call once for one csv line)
function str_to_csv() {
	csv_str=$(printf "%s\0" "$@" | ./escape_dquotes.sh | xargs -0 printf "\"%s\"\0" | paste -zsd,)
	#echo 1>&2 "DEBUG: " "$csv_str"
	printf "%s" "$csv_str"
}

# tries to collect all necessary data from page;
# if one of the neccessary fields doesn't exist than exits from the script
function parse_page() {
	title=$(cat $page | "$select" "$title_select")
	is_empty "title" "$title"
	exit_if_same "$?" "$warning"
	process_title

	description=$(cat $page | "$select" "$descr_select")
	echo ======================
	echo "$description"
	echo ======================
	is_empty "description" $description
	exit_if_same "$?" "$warning"

	# get price if exist
	price=$(cat $page | "$select" "$price_select")
	is_empty "price" "$price"
	if [ $? = $warning ]; then
		#price="not stated"
		price="по договорённости"
	else
		process_price
	fi

	# get tag if exist
	tag=$(cat $page | "$select" "$tag_select")
	is_empty "tag" "$tag"
	if [ $? = $warning ]; then
		tag="..."
	fi

	preview_link=$(./get_preview_link.sh "$tag" "$price")
	is_empty "preview_link" "$preview_link"
	# TODO: decide what to do when link wasn't supplied
}

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

# delete previous page
rm "$page"

# download page
#curl -L "$url" > "$page" 2>/dev/null

curl "$url" > "$page" 2>/dev/null

# parse data
parse_page

reff_suffix="?ref=2367010"
ref_url=$url$reff_suffix # refferal url
shortened_url=$(../tools/short_link.sh -s "$ref_url")
# if we failed to get shotrened url save it unchanged
[ ! "$shortened_url" ] && shortened_url=$ref_url

# write to file
str_to_csv "$shortened_url" "$ref_url" "$title" "$description" "$price" "$tag" "$preview_link" >> $post

printf "\n" >> $post

# success
exit 0

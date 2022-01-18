#!/bin/bash

# input: get html code from stdin and css selector like arg
# output: text content from html node which has given css selector

LANG=

css_select=$1
html_code="cat -"
html_processor="w3m -T text/html -dump -cols 1000000"
#html_processor="lynx -stdin -dump"

selected=$($html_code | hxnormalize -x | hxselect "$css_select" | $html_processor)

# preserve original formatting
printf "%s\n" "$selected"

# doesn't preserve original formatting
#echo $selected

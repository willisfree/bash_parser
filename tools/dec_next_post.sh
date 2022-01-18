#!/bin/bash
read -r current_num <../data/next_line
[ ! $current_num ] && exit 1
((current_num--))
echo "$current_num" > ../data/next_line

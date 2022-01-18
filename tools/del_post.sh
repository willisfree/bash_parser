#!/bin/bash

# clears only if post symlinc exists in directory along with this script
printf "" > "$(readlink -e ../data/current_posts)"

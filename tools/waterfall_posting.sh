#!/bin/bash

delay_sec=30 # seconds
category=dev

while true; do 
	curr_time=$(date +%s);
	./plan_post.sh "$category" $(date +%T -d \@$((curr_time+delay_sec)));
done

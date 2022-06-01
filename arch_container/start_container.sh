#!/usr/bin/bash

script_path="$( cd "$(dirname "$0")" ; pwd -P )"

sudo docker run --rm -d \
	-p 3632:3632 \
	-p 3633:3633 \
	-v "$script_path/distccd.log":"/distccd.log" \
	arch_distcc

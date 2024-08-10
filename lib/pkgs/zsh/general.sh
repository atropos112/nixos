#!/usr/bin/env bash
set -o vi

if [ "$SSH_CLIENT" != "" ] || [ "$SSH_TTY" != "" ]; then
	# Set the TERM environment variable to vt100
	export TERM=xterm
fi

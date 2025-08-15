#!/usr/bin/env bash

function rebase-node {
	set -xeuo pipefail
	export NODE_NAME="$1"

	if [ -z "$NODE_NAME" ]; then
		echo "Usage: rebase-node <node-name>"
		exit 1
	fi

	# if hostname == NODE_NAME, then return 1
	if [ "$(hostname)" = "$NODE_NAME" ]; then
		echo "You are already on the node $NODE_NAME"
		exit 1
	fi

	rsync --filter='dir-merge,-n /.gitignore' -av --delete /home/atropos/projects/ "$NODE_NAME:/persistent/home/atropos/projects"
	rsync --filter='dir-merge,-n /.gitignore' -av --delete /home/atropos/nixos/ "$NODE_NAME:/persistent/home/atropos/nixos"
	rsync --filter='dir-merge,-n /.gitignore' -av --delete /home/atropos/.config/nvim/ "$NODE_NAME:/persistent/home/atropos/.config/nvim"

	rsync -av --delete /home/atropos/.mozilla/ "$NODE_NAME:/persistent/home/atropos/.mozilla"
}

function refresh-devenvs {
	find /home/atropos/projects -type d -exec test -f {}/.devenv.flake.nix \; -print -exec bash -c "cd {} && devenv shell ls" \;
}

function sssh {
	/run/current-system/sw/bin/mosh "$@" -- tmux new -As atropos
}

function bjq {
	printf "$@" | base64 -d | jq
}

function nxrn {
	cached-nix-shell --command "$1" -p "$1"
}

function lat {
	tail -n 100 -f "$@" | bat --paging=never -l log --theme DarkNeon --style plain
}

function upload {
	curl --upload-file "$1" https://transfer.sh
}

function ssh() {
	# check if $TERM = "xterm-kitty"
	if [ "$TERM" = "xterm-kitty" ]; then
		kitty +kitten ssh "$@"
	else
		/run/current-system/sw/bin/mosh "$@"
	fi
}

function cd() {
	__zoxide_z "$@"
	if type cdfunc &>/dev/null; then # Check if cdfunc exists
		cdfunc                          # Execute cdfunc if it exists
	fi
}

function grih {
	git rebase -i HEAD~"$1"
}

# Found this cool function here: https://news.ycombinator.com/item?id=38471822
function frg {
	result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
		fzf --ansi \
			--color 'hl:-1:underline,hl+:-1:underline:reverse' \
			--delimiter ':' \
			--preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
			--preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
	file=''${result%%:*}
	linenumber=$(echo "''${result}" | cut -d: -f2)
	if [[ -n "$file" ]]; then
		"$EDITOR" +"''${linenumber}" "$file"
	fi
}

gpbump() {
	if [ "$1" = "" ]; then
		echo "Please provide a commit message."
		return 1
	fi

	# Stage all changes
	git add --all

	# Commit with the provided message
	git commit -m "$1"

	# Push the changes
	git push

	# Get the most recent tag
	latest_tag=$(git describe --tags --abbrev=0)

	# Bump the patch version
	new_tag=$(echo "$latest_tag" | awk -F. -v OFS=. '{$3++; print}')

	# Create the new tag
	git tag "$new_tag"

	# Push the new tag
	git push --tags

	echo "New tag created: $new_tag"
}

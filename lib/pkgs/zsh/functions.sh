#!/usr/bin/env bash
function rebase-surface {
	# if hostname of current machine is NOT giant then exit with 1 and echo message
	if [ "$(hostname)" != "giant" ]; then
		echo "You are not on giant, you are on $(hostname)"
		return 1
	fi
	rsync -av --delete /home/atropos/projects/ surface:/persistent/home/atropos/projects
	rsync -av --delete /home/atropos/nixos/ surface:/persistent/home/atropos/nixos
	rsync -av --delete /home/atropos/.config/nvim surface:/persistent/home/atropos/.config/nvim
	# /run/current-system/sw/bin/ssh surface "rm -rf .config/vivaldi/*"
	# rsync -av --delete /home/atropos/.config/vivaldi/ surface:/persistent/home/atropos/.config/vivaldi

	/run/current-system/sw/bin/ssh surface "rm -rf .mozilla/*"
	rsync -av --delete /home/atropos/.mozilla/ surface:/persistent/home/atropos/mozilla
}

function rebase-giant {
	if [ "$(hostname)" != "surface" ]; then
		echo "You are not on giant, you are on $(hostname)"
		return 1
	fi
	rsync -av --delete /home/atropos/projects/ giant:/persistent/home/atropos/projects
	rsync -av --delete /home/atropos/nixos/ giant:/persistent/home/atropos/nixos
	rsync -av --delete /home/atropos/.config/nvim giant:/persistent/home/atropos/.config/nvim

	# /run/current-system/sw/bin/ssh giant "rm -rf .config/vivaldi/*"
	# rsync -av --delete /home/atropos/.config/vivaldi/ giant:/persistent/home/atropos/.config/vivaldi
	/run/current-system/sw/bin/ssh giant "rm -rf .mozilla/*"
	rsync -av --delete /home/atropos/.mozilla/ giant:/persistent/home/atropos/.mozilla
}

function sssh {
	/run/current-system/sw/bin/mosh "$@" -- tmux new -As atropos
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

function nnvim() {
	# Check if ATRO_NIX_STORE_NVIM exists and if ~/.config/nvim/init.lua doesn't exists
	if [[ -n "$ATRO_NIX_STORE_NVIM" && ! -f "$HOME/.config/nvim/init.lua" ]]; then
		# Run nvim with the specified configuration
		NVIM_APPNAME="nix-store-nvim" nvim "$@"
	else
		# Run nvim with the default configuration
		nvim "$@"
	fi
}

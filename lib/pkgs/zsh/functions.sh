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
	/run/current-system/sw/bin/ssh surface "rm -rf .config/vivaldi/*"
	rsync -av --delete /home/atropos/.config/vivaldi/ surface:/persistent/home/atropos/.config/vivaldi
}

function rebase-giant {
	if [ "$(hostname)" != "surface" ]; then
		echo "You are not on giant, you are on $(hostname)"
		return 1
	fi
	rsync -av --delete /home/atropos/projects/ giant:/persistent/home/atropos/projects
	rsync -av --delete /home/atropos/nixos/ giant:/persistent/home/atropos/nixos
	rsync -av --delete /home/atropos/.config/nvim giant:/persistent/home/atropos/.config/nvim

	/run/current-system/sw/bin/ssh giant "rm -rf .config/vivaldi/*"
	rsync -av --delete /home/atropos/.config/vivaldi/ giant:/persistent/home/atropos/.config/vivaldi
}

function sssh {
	/run/current-system/sw/bin/mosh "$@" -- tmux new -As atropos
}

function nxrn {
	cached-nix-shell --command "$1" -p "$1"
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

#!/usr/bin/env bash
#compdef fastapi

_fastapi_completion() {
	# shellcheck disable=SC2154
	eval "$(env _TYPER_COMPLETE_ARGS="${words[1, $CURRENT]}" _FASTAPI_COMPLETE=complete_zsh fastapi)"
}

compdef _fastapi_completion fastapi

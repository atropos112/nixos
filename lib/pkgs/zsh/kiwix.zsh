#!/usr/bin/env bash

websites_dir="$HOME/media/websites"
links_file="$HOME/nixos/lib/pkgs/zsh/kiwix-links.txt"
update_interval=1 # Months

function kiwix-download-with-docker {
  docker run -v "$websites_dir":/output --shm-size=1gb ghcr.io/openzim/zimit zimit --url "$1" --name "$2" --workers 24 --waitUntil domcontentloaded
}

function kiwix-start {
  kiwix-serve "$websites_dir"/*.zim --port 8080 --blockexternal --address 127.0.0.1
}

function kiwix-add() {
  url="$1"
  name="$2"

  # Check if the entry already exists in the links file
  if grep -qF "$url $name" "$links_file"; then
    echo "The entry already exists in the links file."
  else
    # Assuming kiwix-download is a command that downloads the content
    kiwix-download-with-docker "$url" "$name"

    echo "$url $name" >>"$links_file"
    echo "Added $name"
  fi
  sudo chown -R "$USER":users "$websites_dir"
}

function kiwix-update() {
  # Check if there is any file in the directory that does not end with .zim
  zim_files_exist=false

  for file in "${websites_dir}"/*; do
    if [[ ! $file =~ \.zim$ ]]; then
      zim_files_exist=true
      break
    fi
  done

  if [ "$zim_files_exist" = true ]; then
    echo "There are files in the directory that do not end with .zim"
    exit 1
  fi

  current_date="$(date '+%s')"
  while read -r line; do
    url="${line%% *}"
    name="${line#* }"
    zim_file=$(ls "$websites_dir/$name"*.zim)
    creation_date=$(stat -c %Y "$zim_file")                            # Get the file's creation timestamp
    months_ago=$(((current_date - creation_date) / 60 / 60 / 24 / 30)) # Calculate months ago
    echo "------------"
    echo "$line"
    # Check if it's been 4 or more months since the last update
    if [ "$months_ago" -ge $update_interval ]; then
      echo "$name was created $months_ago months ago, removing $zim_file and downloading a new one"
      rm "$zim_file"
      # Assuming kiwix-download-with-docker can update the content
      kiwix-download-with-docker "$url" "$name" &
    else
      echo "$name was created $months_ago months ago, skipping"
    fi
    echo "------------"
  done <"$links_file"
  wait
  sudo chown -R "$USER":users "$websites_dir"
  sudo docker container prune -f
}

#!/bin/bash

# When calling this file you should make sure the file you want to be modified is the first argument
processFile() {
	local file=$1
	local template=$2
	cat "$template" > "$file"
	echo "Updated $file"
}
checkService() {
  local file=$1
  # Parte del código que consigue el nombre del fichero
  if [[ "$(basename "$file")" != *.tpl ]]; then
    echo "ERROR: tried to check a non .tpl file"
    exit 3
  fi
  local fileName=$(basename "$file" .tpl)
  if [[ -e "$file" && -s "$file" ]] ; then
    # echo ""$fileName" Writer Service is online"
    echo 1
  else
    # echo ""$fileName" Writer Service is offline"
    if [ ! -e "$file" ]; then
      # echo "ERROR: "$file" does not exist"
      echo 0
    else
      # echo "ERROR: "$file" is empty"
      echo 0
    fi
  fi
}
WATCH_DIR="/home/gabs/Documents/devApps/"
TPL_DIR="$HOME/.config/CSS-HTML-Writer-Daemon/templates"
# "$HOME/.config/CSS-HTML-Writer-Daemon/templates/css.tpl" -> "css"
CSS_TPL="$TPL_DIR/css.tpl"
HTML_TPL="$TPL_DIR/html.tpl"
declare -A validation
validation[css]=$(checkService "$CSS_TPL")
validation[html]=$(checkService "$HTML_TPL")

if [ -d "$WATCH_DIR" ]; then
	if [ -d "$TPL_DIR/" ]; then
		inotifywait -m -r -e close_write --format '%w%f' "$WATCH_DIR" | while read FILE
		do
			case "$FILE" in
				*.css)
					if [[ ! -s "$FILE"  && ${validation[css]} -eq 1 ]] ; then
						processFile "$FILE" "$CSS_TPL"
					fi
					;;
			esac
			case "$FILE" in
				*.html)
					if [[  ! -s "$FILE" && ${validation[html]} -eq 1 ]] ; then
						processFile "$FILE" "$HTML_TPL"
					fi
					;;
			esac
		done
	else
		echo "ERROR: TPL directory is missing or path is incorrect"
		exit 2
	fi
else
	echo "ERROR: Watch directory does not exist"
	exit 1
fi

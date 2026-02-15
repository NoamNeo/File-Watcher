#!/bin/bash

# When calling this file you should make sure the file you want to be modified is the first argument
processFile() {
	local file=$1
	local template=$2
	cat "$template" > "$file"
	echo "Updated $file"
}
# 1: servicio online
# 2: servicio offline
# 3: ERROR fichero no existe
# 4: ERROR fichero está vacio
imprimirEstado() {
  case $1 in
    1)
      echo ""$2" Writer service is online" >&2
      ;;
    2)
      echo ""$2" Writer Service is offline" >&2
      ;;
    3)
      echo "ERROR: "$2" does not exist" >&2
      ;;
    4)
      echo "ERROR: "$2" file is empty" >&2
      ;;
  esac
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
    imprimirEstado 1 "$fileName"
    echo 1
  else
    imprimirEstado 2 "$fileName"
    if [ ! -e "$file" ]; then
      imprimirEstado 3 "$fileName"
      echo 0
    else
      imprimirEstado 4 "$fileName"
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

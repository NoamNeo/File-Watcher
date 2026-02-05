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
  if [[ -e "$file" && -s "$file" ]] ; then
  # Parte el código que activa o desactiva el servicio y da mensajes de error correctos
}
WATCH_DIR="/home/gabs/Documents/devApps/"
TPL_DIR="$HOME/.config/CSS-HTML-Writer-Daemon/templates"
# "$HOME/.config/CSS-HTML-Writer-Daemon/templates/css.tpl" -> "css"
CSS_TPL="$TPL_DIR/css.tpl"
HTML_TPL="$TPL_DIR/html.tpl"
SERVICE_CSS=0
SERVICE_HTML=0
VAR="css"
declare -A validation
validation[css]=0
validation[html]=0
echo ${validation["$VAR"]}
exit 0
if [[  -e "$CSS_TPL" && -s "$CSS_TPL" ]] ; then
	SERVICE_CSS=1
	echo "CSS Writer Service is online"
else
	echo "CSS Writer Service is offline"
	if [ ! -e "$CSS_TPL" ]; then
		echo "ERROR: css.tpl does not exist"
	else
		echo "ERROR: css.tpl is empty"
	fi
fi

if [[  -e "$HTML_TPL" && -s "$HTML_TPL" ]] ; then
	SERVICE_HTML=1
	echo "HTML Writer Service is online"
else
	echo "HTML Writer Service is offline"
	if [ ! -e "$HTML_TPL" ]; then
		echo "ERROR: html.tpl does not exist"
	else
		echo "ERROR: html.tpl is empty"
	fi
fi

if [ -d "$WATCH_DIR" ]; then
	if [ -d "$TPL_DIR/" ]; then
		inotifywait -m -r -e close_write --format '%w%f' "$WATCH_DIR" | while read FILE
		do
			case "$FILE" in
				*.css)
					if [[ ! -s "$FILE"  && $SERVICE_CSS -eq 1 ]] ; then
						processFile "$FILE" "$CSS_TPL"
					fi
					;;
			esac
			case "$FILE" in
				*.html)
					if [[  ! -s "$FILE" && $SERVICE_HTML -eq 1 ]] ; then
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

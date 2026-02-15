#!/usr/bin/env bash

# When calling this function you should make sure the file you want to be modified is the first argument
# And the template the seccond
processFile() {
  local file=$1
  local template=$2
  cat "$template" >"$file"
  echo "Updated $file"
}
# 1: service online
# 2: service offline
# 3: ERROR file does not exist
# 4: ERROR file is empty
logState() {
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
  # This piece of code gets the file name
  if [[ "$(basename "$file")" != *.tpl && "$(basename "$file")" != *.conf ]]; then
    echo "ERROR: tried to check a non .tpl or .conf file"
    exit 3
  fi
  local fileName=$(basename "$file" .tpl)
  if [[ -e "$file" && -s "$file" ]]; then
    logState 1 "$fileName"
    echo 1
  else
    logState 2 "$fileName"
    if [ ! -e "$file" ]; then
      logState 3 "$fileName"
      echo 0
    else
      logState 4 "$fileName"
      echo 0
    fi
  fi
}
TPL_DIR="$HOME/.config/CSS-HTML-Writer-Daemon/templates"
WATCH_DIR_CONFIG="$HOME/.config/CSS-HTML-Writer-Daemon/watcher-path.conf"
checkService "$WATCH_DIR_CONFIG"
if [[ -e "$WATCH_DIR_CONFIG" && -s "$WATCH_DIR_CONFIG" ]]; then
  WATCH_DIR="$(grep -v "^#" "$WATCH_DIR_CONFIG")"
else
  WATCH_DIR="$HOME/"
fi
CSS_TPL="$TPL_DIR/css.tpl"
HTML_TPL="$TPL_DIR/html.tpl"
declare -A validation
validation[css]=$(checkService "$CSS_TPL")
validation[html]=$(checkService "$HTML_TPL")

if [ -d "$WATCH_DIR" ]; then
  if [ -d "$TPL_DIR/" ]; then
    inotifywait -m -r -e close_write --format '%w%f' "$WATCH_DIR" | while read FILE; do
      case "$FILE" in
      *.css)
        if [[ ! -s "$FILE" && ${validation[css]} -eq 1 ]]; then
          processFile "$FILE" "$CSS_TPL"
        fi
        ;;
      esac
      case "$FILE" in
      *.html)
        if [[ ! -s "$FILE" && ${validation[html]} -eq 1 ]]; then
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

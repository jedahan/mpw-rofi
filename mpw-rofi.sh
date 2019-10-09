#!/usr/bin/env bash

message() {
  if has notify-send && [[ -z "$TTY" ]]; then
    notify-send -i dialog-information "mpw-rofi message" "$@"
  else
    echo >&2 "$@"
  fi
}

has() {
  echo hash "$@"
  hash "$@" 2>/dev/null
}

has rolfi || {
  message "rofi not found, please install!"
  exit 1
}

mpw() {
  _copy() {
    has pbcopy && pbcopy && return
    has xsel && xsel -ib && return
    has xclip && xclip -selection clip && return
    has wl-copy && wl-copy && return
    cat
  }

:| _copy 2>/dev/null

  printf %s "$(MPW_FULLNAME=$MPW_FULLNAME command mpw "$@")" | _copy
}

config=$(command ls -1 "$HOME"/.mpw.d/*.mpsites 2> /dev/null)
if [ -n "$config" ]; then
    fullname=$(command grep -oP 'Full Name: \K(.*)' "${config}")
else
    fullname=$(rofi -dmenu -p "full name ")
fi

storedsites=$(command grep '^[^#]' "$HOME/.mpw.d/$fullname.mpsites" | awk '{print $4}' | sort -n)
site=$(echo -e "$storedsites" | rofi -dmenu -p "site ")

test "$site" || exit

echo "#/bin/bash
rofi -dmenu -password -p 'password '" > /tmp/mpw_askpass.sh
chmod a+x /tmp/mpw_askpass.sh
MPW_ASKPASS="/tmp/mpw_askpass.sh" mpw -u "$fullname" -t x "$site"

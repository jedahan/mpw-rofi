#/bin/bash
mpw() {
    _copy() {
	if hash pbcopy 2>/dev/null; then
            pbcopy
        elif hash xclip 2>/dev/null; then
            xclip -selection clip
	elif hash wl-copy 2>/dev/null; then 
            wl-copy
        else
            cat; echo 2>/dev/null
            return
	fi
        echo >&2 "Copied!"
    }

:| _copy 2>/dev/null

    printf %s "$(MPW_FULLNAME=$MPW_FULLNAME command mpw "$@")" | _copy
}

count=$(ls -1 $HOME/.mpw.d/*.mpsites.json 2> /dev/null | wc -l)
if [ $count != 0 ]
then
    pathtoconfig=$(ls -1 $HOME/.mpw.d/*.mpsites.json 2> /dev/null | head -1)
    fullname=${pathtoconfig%.*}
    fullname=${fullname%.*}
    fullname=${fullname##*/}
else
    fullname=$(rofi -dmenu -p "Full name")
fi

storedsites=$(cat "$HOME/.mpw.d/$fullname.mpsites.json" | jq -r '.sites | keys[]' | sort -n)
site=$(echo -e "$storedsites" | rofi -dmenu -p "Site name")

if [ -z $site ]
then
    exit
fi
echo "#/bin/bash
rofi -dmenu -password -p 'Password'" > /tmp/mpw_askpass.sh
chmod a+x /tmp/mpw_askpass.sh
MPW_ASKPASS="/tmp/mpw_askpass.sh" mpw -u "$fullname" -t x "$site"

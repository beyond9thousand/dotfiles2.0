#!/usr/bin/env zsh

# Find and store total number of workspaces in an array
workspaces=($(bspc query -D --names))

# Create a structure function to store values in json format
wrap() {
    local onclick="\"onclick\":\"$1\""
    local text="\"text\":\"$2\""
    local class="\"class\":\"$3\""
    echo "{$onclick,$text,$class}"
}

# Pack current values into the structure with json format
pack() {
    buffer="["
    seq ${#workspaces} | while read -r val; do
        if bspc query -D -d focused --names | grep -q "$val"; then
            buffer+="$(wrap "bspc desktop -f $val" "" "focused_workspace"),"
        elif bspc query -D -d .occupied --names | grep -q "$val"; then
            buffer+="$(wrap "bspc desktop -f $val" "" "occupied_workspace glyph"),"
        else
            buffer+="$(wrap "bspc desktop -f $val" "" "empty_workspace glyph"),"
        fi
    done

    buffer="${buffer::-1}]" # strip the trailing comma and terminate
    echo "$buffer" | awk '{print}'
}

# Run once on startup and then follow changes
pack
bspc subscribe desktop node_transfer | while read -r _; do
    pack
done

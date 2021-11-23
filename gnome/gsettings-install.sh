#!/usr/bin/env bash

###################################################################
# IMPORT GNOME SETTINGS FROM FILES UNDER /gsettings DIRECTORY.
# Author       	   Jan Górkiewicz (https://greencashew.dev)
# Repository       https://github.com/greencashew/fresh-linux-software-installer/
###################################################################

echo "-------------------------------------------------------------------------"
echo "                    Update gnome settings                                "
echo "-------------------------------------------------------------------------"


readFile() {
    sed -e 's/[[:space:]]*#.*// ; /^[[:space:]]*$/d' $1 | 
    while IFS= read -r line || [ -n "$line" ];
    do
        local setting=($line)
        if [ "${#setting[@]}" -le 2 ]; then
            echo "[ERROR] Incorrect setting: $line"
            echo "Should be: SCHEMA [:PATH]  KEY VALUE"
            continue
        fi
        local newValue=${setting[@]:2}
        local actual=$(gsettings get ${setting[0]} ${setting[1]}) || ""
        if [ "$newValue" != "$actual" ]; then
            local query="${setting[0]} ${setting[1]} $newValue"
            if gsettings set $query ; then
                echo "[UPDATED] $query Previous: $actual"
            else
                echo "[ERROR] Unable to set $query, Actual: $actual"
            fi
        fi
    done
}

for path in gsettings/*; do
    readFile "${path}"
done


echo "-------------------------------------------------------------------------"
echo "                  Gnome settings has been updated                        "
echo "-------------------------------------------------------------------------"

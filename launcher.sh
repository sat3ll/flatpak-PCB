#!/bin/env sh
set -e

export WINEPREFIX=$XDG_DATA_HOME/wineprefix
export WINEARCH=win32
export WINEDLLOVERRIDES="mscoree=;mshtml=;"

# prefix with droid font
if [ ! -f "$XDG_DATA_HOME"/.prefix-installed ]; then
	cp -r /app/wineprefix-premade "$WINEPREFIX" && touch "$XDG_DATA_HOME"/.prefix-installed
fi

if [ ! -d "$XDG_DATA_HOME"/replay ]; then
  mkdir -p "$XDG_DATA_HOME"/replay
fi


# install thcrap
if [ ! -f "$XDG_DATA_HOME"/.thcrap-installed ]; then
  cp -r /app/thcrap-bundle "$XDG_DATA_HOME"/thcrap && touch "$XDG_DATA_HOME"/.thcrap-installed

  # FIXME: workaround broken DLLs
  cp "$XDG_DATA_HOME"/thcrap/bin/*.dll "$XDG_DATA_HOME"/thcrap/
fi

check_permissions() {
  if [ -z "$(grep "features.*devel" /.flatpak-info)" ] || [ -z "$(grep "shared.*network" /.flatpak-info)" ]; then
    zenity --error --text "Required permissions missing. Consult README.md for details"
    exit 1
  fi
}


if [ -z "$1" ]; then
  # Run original game

  # needed for sound and config to work
  cd /app/th07
  wine explorer /desktop=PCB,1920x1080 th07.exe
elif [ "$1" = "thcrap-conf" ]; then

  check_permissions

  # FIXME: workaround broken updater dll
  if [ ! -f "$XDG_DATA_HOME"/thcrap/thcrap_update.dll ]; then
    cp "$XDG_DATA_HOME"/thcrap/bin/thcrap_update.dll "$XDG_DATA_HOME"/thcrap/
  fi

  wine "$XDG_DATA_HOME"/thcrap/thcrap_configure.exe
elif [ "$1" = "config-select" ]; then

  check_permissions

  # FIXME: workaround broken updater dll
  if [ -f "$XDG_DATA_HOME"/thcrap/thcrap_update.dll ]; then
    rm "$XDG_DATA_HOME"/thcrap/thcrap_update.dll
  fi

  CONFS=$(ls -I games.js "$XDG_DATA_HOME"/thcrap/config)
  if [ -z "$CONFS" ]; then
    zenity --error --text "No config files found! Please generate them first then try again"
  else
    CHOICE=$(echo "$CONFS" | zenity --list --column "Available configs")
    STATUS=$?
    if [ $STATUS -eq 0 ]; then
      wine explorer /desktop=PCB,1920x1080 "$XDG_DATA_HOME"/thcrap/thcrap_loader.exe "$CHOICE" "Z:\app\th07\th07.exe"
    fi
  fi
fi

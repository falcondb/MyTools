#!/bin/bash
LINUXSRC=/Users/yifei.ma/opprojects/goprojects/src/github.com/falcondb/linux
IDE=/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea

function env_setup {
  [[ -z $1 ]] && echo "No LINUXSRC is given, set LINUXSRC to $LINUXSRC" || LINUXSRC=$1
  [[ -z $2 ]] && echo "NO IDE is given, set IDE to default IntelliJ path at $IDE " || IDE=$2
}


function search_open_struct_definition {
  local KW=$1
  [[ -z $1 ]] && echo "Usage: need a key word for the file search!" && return 1

  [[ $KW != "struct "* ]] && KW="struct "$1
  [[ " {" != ${KW:-2} ]] && KW=$KW" {"

  echo "Searching for struct definition for ${KW:-2}"
  FILES=`grep "$KW" $LINUXSRC/include`
  [[ -z $FILES ]] && echo "Unfortunately, no struct definition was found in linux/include..." && return 2

  echo "Found following files:\n$FILES"
  read -p "Do you like to open the files in IDE?" yn
      case $yn in
          [Yy]* ) IDE_open_files "$FILES";;
          [Nn]* ) echo "Done!";;
          * ) echo "Please answer yes or no.";;
      esac
}

function IDE_open_files {
  [[ -z $1 ]] && echo "Usage: need the file paths." && return 1
  [[ ! -x "$IDE" ]] && echo "IDE isn't set probably." && return 2

  while read -r line
    do
        echo "$IDE $(echo $line | cut -d ':' -f 1)"
        "$IDE" $(echo $line | cut -d ':' -f 1)
    done <<< "$1"
}

alias ssd=search_open_struct_definition
env_setup

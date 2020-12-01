. $(dirname $0)/common-env-setup.sh

umask u=rw,go=

NASM
LD

function env-setup {
  NASM=$(which nasma)
  LD=$(which nasma)
  PACKS
  [ -z $LD ] && PACKS="$PACKS binutils"
  [ -z $NASM ] && PACKS="$PACKS nasm"

    $SUDO $INSTALLER update -y && $SUDO $INSTALLER install -y nasm

  NASM=$(which nasma)
  echo "nasm is availabe at $NASM"

}

function assemble_link {
  [ -z $1 ] && echo "Need the file name!" && return 1
  local SN=${1%.*}
  nasm -f elf -o ${SN}.o $1 && \
  ld -m elf_i386 -s -o $SN ${SN}.o
}

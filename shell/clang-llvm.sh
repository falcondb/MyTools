APPNAME=atc
SRCCODE=$APPNAME.bpf.c
IRCODE=$APPNAME.bpf.ir
OBJCODE=$APPNAME.bpf.o
ASMCODE=$APPNAME.S

CLANGINC="-I/home/vm-admin/git/linux/tools/include/uapi \
-I/home/vm-admin/git/linux/tools/lib/ -I/home/vm-admin/git/linux/tools/bpf/bpftool/ \
-I."

## compile
clang -emit-llvm -g -c $SRCCODE -o $IRCODE $CLANGINC &>-
# clang -target bpf -S -o $ASMCODE $CLANGINC $SRCCODE && clang -target bpf -c $OBJCODE $ASMCODE 
llc -march=bpf -mcpu=probe -filetype=obj -o $OBJCODE $IRCODE

## disasmble
llvm-objdump -d -r --print-imm-hex $OBJCODE
llvm-objdump -S $OBJCODE

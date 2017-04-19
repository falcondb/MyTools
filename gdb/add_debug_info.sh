gcc -g -shared -o libabc.so abc.c

### remove debug section ###
objcopy --only-keep-debug libabc.so libabc.debug

### take a look at the debug section ###
objdump -s -j .gnu_debuglink libabc.so

### add the debug section to executable ###
objcopy --add-gnu-debuglink=libabc.debug libabc.so
$ objdump -s -j .gnu_debuglink libabc.so

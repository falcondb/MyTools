#! /bin/bash

### Run the source command from the current working console ###
for var in "$@" ; do 
	for f in ./.bash_profile_$@*; do source $f; done
done

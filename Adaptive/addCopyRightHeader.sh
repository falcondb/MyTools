[[ -z $1 ]] && return 1

cat template.header | sed "s/@FILENAME@/$(basename $1)/g" | cat - $1 > tempfile && mv tempfile $1

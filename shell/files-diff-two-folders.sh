[[ $# -le 1 ]] && echo Need to parameters && exit

LOGFILE=file-diff.log

echo > $LOGFILE

FPATTERN="*"
$1="conf/"
$2="/ap/live_build/apache2/conf/"

for f in `find $1 -name $FPATTERN -type f`
do

  orig=$(find $2 -name $(basename $f))

  [[ -n $orig ]] || echo "$f is not found in the target folder" && diff $f $orig >> $LOGFILE

  [[ $? -ne 0 ]] && echo "$f and $orig are out of sync !!! "
done

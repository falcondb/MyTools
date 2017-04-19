[[ $# -ne 2 ]] && exit

while [ $(pgrep $1) ]
do
	sleep 30
done

echo "$1 is donw" | mail -s "$1 is donw" $2

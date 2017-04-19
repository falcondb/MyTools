set -e -x

[[ $# -ne 2 ]] && echo "Usage: 1) account name; 2) email " && exit

[[ ! $2 == *"@"* ]] && echo "$2 looks like not a valid email" && exit

git config --global user.name $1
git config --global user.email $2

git config credential.helper store
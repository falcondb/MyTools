set -e -x

[[ $# -ne 2 ]] && echo "Usage: 1) path of the local repo; 2) url of the github repo" && exit
[[ ! 'which git' ]] && echo "No git in bin path" && exit

[[ ! $2 == *".git"* ]] && echo "$2 looks like not a valid git url" && exit


function reset_orgin() {

set -e
git remote remove origin
set -x -e

git remote add origin $2

}

function push_branches() {

for branch in $(git branch | awk '{print $NF}')  
do  
	git checkout $branch
	git push --set-upstream origin $branch  ##--allow-unrelated-histories

done 

}

####### Main entry #########

cd $1

reset_orgin $1 $2

push_branches $1 $2
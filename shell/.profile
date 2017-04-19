alias ltr='ls -ltr'
alias ll='ls -l'
alias dir='ls -l'
alias cd='function __mycd() { cd $1; echo "PWD: $PWD"; }; __mycd'
alias vg='vagrant'
alias vgu='vagrant up'
alias vgs='vagrant status'
alias vgsh='vagrant ssh'
alias vgd='vg destroy'
alias asp='ansible-playbook'
alias dki='function __dki() { docker exec -it $1 bash ; }; __dki'
alias dk='docker'
alias wgit='cd /Users/mayi/Work/git/'
alias pgit='cd /Users/mayi/Hobby/git/'
alias gh='history | grep'
alias mysh='ssh -X'
alias gitaddc='git status | grep modified | egrep '\.c$|\.h$|\.mk.in$|\.ac$|\.am$' | awk -F ' ' '{print $3}' | xargs git add'

HISTSIZE=100000
HISTFILESIZE=2000

export PATH=$PATH:/usr/local/sbin/

#JAVA_HOME=/Library/Java/Home
#export JAVA_HOME;

#SCALA_HOME=/usr/local/opt/scala/
#export SCALA_HOME

#CLASSPATH=$CLASSPATH:$SCALA_HOME/libexec/lib/scala-library.jar

export EDITOR='subl -w'

PS1="\u:\w$ "

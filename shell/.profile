alias ltr='ls -ltr'
alias ll='ls -l'
alias cd='function __mycd() { cd $1; echo "PWD: $PWD"; }; __mycd'
alias vg='vagrant'
alias vgu='vagrant up'
alias vgs='vagrant status'
alias vgsh='vagrant ssh'
alias vgd='vg destroy'
alias asp='ansible-playbook'
alias dki='function __dki() { docker exec -it $1 bash ; }; __dki'
alias dk='docker'
alias gh='history | grep'
alias mysh='ssh -X'
alias gitaddc='git status | grep modified | egrep '\.c$|\.h$|\.mk.in$|\.ac$|\.am$' | awk -F ' ' '{print $3}' | xargs git add'

MYIP=`ifconfig en0 | grep -w inet  | cut -d " " -f 2`

PS1="\[\033[1;33m\]\A \u@\h:\w$\[\033[0m\] "

HISTSIZE=100000
HISTFILESIZE=2000
HISTTIMEFORMAT=’%F %T ‘
HISTCONTROL=ignoredups
HISTIGNORE=”pwd:ls:ls –ltr:cd:exit:ssh”

export PATH=$PATH:/usr/local/sbin/

#JAVA_HOME=/Library/Java/Home
#export JAVA_HOME;

#SCALA_HOME=/usr/local/opt/scala/
#export SCALA_HOME

#CLASSPATH=$CLASSPATH:$SCALA_HOME/libexec/lib/scala-library.jar

export EDITOR='atom'


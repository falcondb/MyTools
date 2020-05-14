export PATH=$PATH:$HOME/3rd-party-libs/zookeeper/bin/:/usr//local/Cellar/llvm/9.0.0_1/bin/:/usr/local/opt/binutils/bin/
export GITHOME=$HOME/adaptive/git
export GOROOT="$(brew --prefix golang)/libexec"
export GOPATH=$HOME/opprojects/goprojects/
export ADA_BRANCH=${GITHOME}/planning
export EDITOR='atom'
export PATH=$PATH:$HOME/3rd-party-libs/zookeeper/bin/
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config

alias atom='/Applications/Atom.app/Contents/MacOS/Atom'
alias ll='ls -alh --color=auto'
alias grep='grep -rn --color=auto'
alias gogit='PS1="\[\033[1;33m\]\A \u@\h:\w (\$(git branch 2>/dev/null | grep '^*' | cut -f 3 -d ":" | colrm 1 2)) $\[\033[0m\] " && cd ${GITHOME}'
alias gb='./gradlew clean build'
alias gb_wo_tests='./gradlew clean build -x test'
alias gap='./gradlew artifactoryPublish'
alias perf-repo='ssh adaptive@perf-repo'
alias t='tree -L 1'
alias k='kubectl'
alias mygit='cd $GOPATH/src/github.com/falcondb/'

MYIP=`ifconfig en0 | grep -w inet  | cut -d " " -f 2`

PS1="\[\033[1;33m\]\A \u@\h:\w$\[\033[0m\] "

HISTSIZE=100000
HISTFILESIZE=2000
HISTTIMEFORMAT="%F %T "
HISTCONTROL=ignoredups
HISTIGNORE=”pwd:ls::cd:exit:ssh”

export EDITOR='atom'

source $HOME/.bash_profile_gostaff

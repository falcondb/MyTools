export JFROG_NAME=yma
export JFROG_DOCKER_REGI_TOKEN=AP3CCZuVFwPyziBKAWim3oZ4HcP
export artifactory_user=yma
export PATH=$PATH:$HOME/3rd-party-libs/zookeeper/bin/
export GITHOME=$HOME/adaptive/git
export ADA_BRANCH=${GITHOME}/planning
export EDITOR='atom'

alias atom='/Applications/Atom.app/Contents/MacOS/Atom'
alias ll='ls -alh'
alias gogit='zsh && cd ${GITHOME}'
alias gb='./gradlew clean build'
alias gb_wo_tests='./gradlew clean build -x test'
alias gap='./gradlew artifactoryPublish'
alias perf-repo='ssh adaptive@perf-repo'

MYIP=`ifconfig en0 | grep -w inet  | cut -d " " -f 2`

PS1="\[\033[1;33m\]\A \u@\h:\w$\[\033[0m\] "

HISTSIZE=100000
HISTFILESIZE=2000
HISTTIMEFORMAT="%F %T "
HISTCONTROL=ignoredups
HISTIGNORE=”pwd:ls::cd:exit:ssh”

export EDITOR='atom'

source $HOME/.bash_profile_adaptive

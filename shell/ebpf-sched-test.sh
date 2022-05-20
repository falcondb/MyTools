LINTREE=/home/vm-admin/git/linux/
NGIMAGE=nginx

HOSTHTML=/home/ym/html/
NGHTML=/usr/share/nginx/html

NUMSVS=3
CNAMES=()
CIPS=()

NUMREQS=50000
CONCUR=500

OUTPATH="./"
VMIP=192.168.53.130

function set-container-IPs {
  CIPS=()
  for (( i=0; i<$NUMSVS; i++ )); do
    CNAMES+=("nginx-perf-$i")
    CIPS[$i]=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CNAMES[$i]}`
  done
  export CIPS
}

function deploy-nginx {
  [[ $# -lt 1 ]] && (echo -e "Usage:\n\tFirst arg: number of services\n"; return 1)

  NUMSVS=$1
  CNAMES=()
  for (( i=0; i<$NUMSVS; i++ )); do
    CNAMES+=("nginx-perf-$i")

    [[ -n $PORTMAPPING ]] && HCPMAPPING="-p 62${i}80:80"
    docker rm -f ${CNAMES[$i]} >&-
    docker run --name ${CNAMES[$i]} $HCPMAPPING  -v $HOSTHTML:$NGHTML -d $NGIMAGE >&- \
    || (echo -e "failed to deploy service.\n \
       docker run --name ${CNAMES[$i]} -v  $HOSTHTML:$NGHTML -d $NGIMAGE"; return 2)
    echo "Deployed ${CNAMES[$i]} with IP ${CIPS[$i]}"
  done
}


function install-web-tools {
  apt-get install -y apache2-utils siege

}

function web-perf-test {
  [[ -n $1 ]] && NUMREQS=$1
  [[ -n $2 ]] && CONCUR=$2

  [[ -n $RESETBPFOUTPUT ]] && clear-bpf-output
  # if [ ${CIPS[@]} -eq 0 ]; then
  #   set-container-IPs
  # fi

  for (( i=0; i<$NUMSVS; i++ )); do
    URL=${CIPS[$i]}:80/
    echo "Sending $NUMREQS requests to $URL with concurry $CONCUR"
    ab -n $NUMREQS -c $CONCUR http://$URL 2>&1 > $OUTPATH/$(date +"%H-%M-%S")${CNAMES[$i]}-ab.log &
    ##siege -q -t 2S -c 500 -L ./siege.log  http://$URL
  done
}

function host-web-perf-test {
  [[ -n $1 ]] && NUMREQS=$1
  [[ -n $2 ]] && CONCUR=$2

  [[ -n $RESETBPFOUTPUT ]] && clear-bpf-output
  # if [ ${CIPS[@]} -eq 0 ]; then
  #   set-container-IPs
  # fi

  for (( i=0; i<$NUMSVS; i++ )); do
    URL=${VMIP}:62${i}80/
    echo "Sending $NUMREQS requests to $URL with concurry $CONCUR"
    ab -n $NUMREQS -c $CONCUR http://$URL 2>&1 > $OUTPATH/$(date +"%H-%M-%S")-p62${i}80-ab.log &
    ##siege -q -t 2S -c 500 -L ./siege.log  http://$URL
  done
}


function run-multiple-tests {
  [[ -z $NUMRUNS ]] && echo "NUMRUNS: number of runs" && return 1

  for (( r=0; r<$NUMRUNS; r++ )); do
    web-perf-test $NUMREQS  $CONCUR
    sleep 15
    echo "Finished $r run"
  done

  echo "Output $OUTPATH"
}


function host-run-multiple-tests {
  [[ -z $NUMRUNS ]] && echo "NUMRUNS: number of runs" && return 1

  for (( r=0; r<$NUMRUNS; r++ )); do
    host-web-perf-test $NUMREQS  $CONCUR
    sleep 60
    echo "Finished $r run"
  done

  echo "Output $OUTPATH"
}


function bpf-dependencies {
   apt-get install -y binutils-dev clang-12

}

function make-bpf-tools {
  pushd .
  cd $LINTREE/tools/bpf/bpftool/bpftool
  make install
  popd
}

function read-bpf-output {
   cat /sys/kernel/debug/tracing/trace_pipe
   ## bpftool p tracelog
}


function clear-bpf-output {
  echo > /sys/kernel/debug/tracing/trace
}


function use-bpf-auto-completion {
  local BASHAUTOCOMP=/usr/share/bash-completion/bash_completion
  local BPFTOOLCOMP=$LINTREE/tools/bpf/bpftool/bash-completion/bpftool

  if [[ ! -e $BPFTOOLCOMP ]] ; then
    echo "bash-completion for bpftool is not found at $BPFTOOLCOMP"
    echo "get a copy of it from a latest Linux source code"
    return 1
  fi

  if [[ ! -f $BASHAUTOCOMP ]] ; then
    [[ -z $INSTALLER ]] && INSTALLER=apt-get
    $SUDO $INSTALLER install -y bash-completion
  fi

  . $BASHAUTOCOMP
  . $BPFTOOLCOMP

    ## BASHPROFILE=~/.bashrc
    ## grep $BASHAUTOCOMP $BASHPROFILE || echo ". " $BASHAUTOCOMP  >> $BASHPROFILE
    ## grep $BPFTOOLCOMP  $BASHPROFILE || echo ". " $BPFTOOLCOMP  >> $BASHPROFILE
}

function enable-bpf-stats {

  sysctl -w kernel.bpf_stats_enabled=1
  ## echo 1 > /proc/sys/kernel/bpf_stats_enabled
  bpftool prog show id $PROGID
  ## run)time_ns xxxx run_cnt XXX
}


function get-target-cgroup {
  CSID=$(docker ps -q -f "name=nginx-perf-${NUMSVS}")
  export CGRPPATH=$(find /sys/fs/cgroup/cpu/ -name "${CSID}*")
}


function cal-avg {
  LOGPATTEN="*.log"
  [[ -n $1 ]] && LOGPATTEN=$1

  KEYWORDS=("Time taken for tests" "Requests per second" "Time per request" \
            "Transfer rate" "Total:")

  for w in "${KEYWORDS[@]}" ; do

  echo -e $w "\t" `grep  "$w" $LOGPATTEN| cut -d ":" -f 1,3 \
  | awk '{sum+=sprintf("%f",$2)}END{printf "%.6f\n%.6f\n",sum,sum/NR}' | tail -n 1`

  done

  KEYWORDS=("50%" "90%" "95%" "100%")
  for w in "${KEYWORDS[@]}" ; do

  echo -e $w "\t" `grep  "$w" $LOGPATTEN \
  | awk '{sum+=sprintf("%f",$3)}END{printf "%.6f\n%.6f\n",sum,sum/NR}' | tail -n 1`

  done
}


function analyze-bpf-log {
  LOGFILE=tracelog.log
  [[ -n $1 ]] && LOGFILE=$1

  KEYWORDS=("cfs_check_preempt_wakeup" "cfs_wakeup_preempt_entity" "tick tgid")

  for w in "${KEYWORDS[@]}" ; do

  echo -e $w "\tPremption\t" `grep "$w" $LOGFILE | grep "ret 1" | wc -l`  \
             "\tNot prempted\t" `grep "$w" $LOGFILE | grep "ret -1" | wc -l`

  done
}

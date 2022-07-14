FTPATH=/sys/kernel/debug/tracing/

function install-trace-tools {
  echo Installing trace-cmd
  $SUDO $INSTALLER -y trace-cmd

  which trace-cmd && echo "Installed trace-cmd!"

}

function mount-ftrace {
  [[ -e $FTPATH ]] || $SUDO mkdir $FTPATH
  mount | grep debugfs || \
    $SUDO mount -t debugfs nodev $FTPATH
}


function set-tracer-pid {
  [[ -z $1]] && echo "Need the pid" && return 1
  $SUDO sh -c "echo $1 > /sys/kernel/debug/tracing/set_ftrace_pid"
  cat set_ftrace_pid
}



function add-symbol-offset {
  $SUDO echo sym-offset > $FTPATH/trace_options

  #$SUDO echo sym-addr > $FTPATH/trace_options
}


function cleanup-ftrace {
  #$SUDO trace-cmd reset

  $SUDO echo nop > $FTPATH/current_tracer
  $SUDO echo > $FTPATH/set_ftrace_pid
  $SUDO echo > $FTPATH/set_ftrace_filter
  $SUDO echo 0 > $FTPATH/tracing_on
  $SUDO echo > $FTPATH/set_ftrace_notrace
  $SUDO echo > $FTPATH/set_graph_function
  $SUDO echo > $FTPATH/set_graph_notrace
  $SUDO echo > $FTPATH/trace
  $SUDO echo > $FTPATH/set_event

  #$SUDO echo > $FTPATH/tracing_thresh
}


function show-current-ftrace-settings {
  echo $FTPATH/current_tracer
  $SUDO cat $FTPATH/current_tracer
  echo

  echo $FTPATH/set_ftrace_pid
  $SUDO cat $FTPATH/set_ftrace_pid
  echo

  echo $FTPATH/set_ftrace_filter
  $SUDO cat $FTPATH/set_ftrace_filter
  echo

  echo $FTPATH/tracing_on
  $SUDO cat $FTPATH/tracing_on
  echo

  echo $FTPATH/set_ftrace_notrace
  $SUDO cat $FTPATH/set_ftrace_notrace
  echo

  echo $FTPATH/set_graph_function
  $SUDO cat $FTPATH/set_graph_function
  echo

  echo $FTPATH/set_graph_notrace
  $SUDO cat $FTPATH/set_graph_notrace
  echo

  echo $FTPATH/set_event
  $SUDO cat $FTPATH/set_event

  #$SUDO cat $FTPATH/tracing_thresh
}


function disable-tracing {
  echo 0 > $FTPATH/tracing_on
}

function restart-tracing {
  echo > $FTPATH/trace
  echo 1 > $FTPATH/tracing_on
}

function context-switch-on-pid {
  [[ -z $1 ]] && echo "Need the pid" && return 1
  TPID=$1
  FCOND="prev_pid == $TPID || next_pid == $TPID"

  disable-tracing

  [[ -z $2 ]]  \
    && echo '$FCOND' > $FTPATH/events/sched/sched_switch/filter \
    || echo '$FCOND' >> $FTPATH/events/sched/sched_switch/filter

  echo 1 > $FTPATH/events/sched/sched_switch/enable

  restart_tracing

}



function context-switch-on-comm {

  [[ -z $1 ]] && echo "Need the process command" && return 1
  TCOMM=$1
  FCOND="prev_comm == $TCOMM || next_comm == $TCOMM"
  disable-tracing

  [[ -z $2 ]]  \
    && echo \'$FCOND\' > $FTPATH/events/sched/sched_switch/filter \
    || echo $FCOND >> $FTPATH/events/sched/sched_switch/filter
  echo 1 > $FTPATH/events/sched/sched_switch/enable

  restart_tracing

}


function dump-trace-pipeline {
  OUTPATH=/tmp
  [[ -n $1 ]] && OUTPATH=$1
  $SUDO sh -c "cat $FTPATH/trace_pipe > $OUTPATH/trace_pipe.log"
}

alias mpstree='pstree -gpsn'

function enable-sched-tracers {
  # enable the tracers in .config
  # rebuild and deploy the kernel
  # cat $FTPATH/current_tracer
}


function my-faddr2line {
  if [[ -z $LSRC ]];  then
       echo "Please set linux source code path to ENV LSRC"
       return 1
  fi

  [[ $# -eq 1 ]] || (echo "Need parameters"; return 1)

  echo $($LSRC/scripts/faddr2line vmlinux $1)
}

function my-less {
  [[ ! $# -eq 1 ]] && (echo "Need parameters"; return 1)
  LINE=$1
  aT=(${LINE//:/ })
  less -N +${aT[1]}g $LSRC/${aT[0]}
}

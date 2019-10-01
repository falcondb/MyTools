# A script to setup Linux Perf-event profiling tool (https://perf.wiki.kernel.org/index.php/Main_Page), and the tools for JVM frame profiling.
# To enable Perf-event to work, /proc/sys/kernel/perf_event_paranoid needs to be 0 (suggested) or -1.

function setup-java-home {
  local JAVABIN=$(readlink $(readlink `which java`))
  export JAVA_HOME=$(dirname $(dirname $(dirname $JAVABIN)))
  echo JAVA_HOME=$JAVA_HOME
}

function setup-perf-toolings {
  [[ $(whoami) == "root" ]] || SUDO="sudo "
  $SUDO yum install -y perf git cmake make gcc gcc-c++
}

function setup-perf-map-agent {
  echo set up perf-map-agent
  pushd .
  git clone --depth=1 https://github.com/jrudolph/perf-map-agent
  cd perf-map-agent
  cmake .
  make
  export MAPPATH=$PWD
  popd
}

function setup-FlameGraph {
  echo set up FlameGraph
  pushd .
  git clone --depth=1 https://github.com/brendangregg/FlameGraph
  export FGPATH=$PWD/FlameGraph
  popd
}

function create-ES-symbol-map {
  pushd .
  cd $MAPPATH/out

  [[ 1 -ne $(pidof java | tr ' ' '\n' | wc -l) ]] && (echo more than 1 Java app; return 1)
  local ESPID=$(pidof java)
  java -cp attach-main.jar:$JAVA_HOME/lib/tools.jar net.virtualvoid.perf.AttachOnce $ESPID

  [[ -f /tmp/perf-$ESPID.map ]] || (echo "creating symbol file at /tmp/perf-$ESPID.map failed!"; exit 1)
  popd
}

function perf-sample {
  [[ $(whoami) == "root" ]] || SUDO="sudo "

  $SUDO perf record -F 99 -a -g
}

function FlameGraph {
  [[ $(whoami) == "root" ]] || SUDO="sudo "

  local graphFile=flamegraph.svg
  [[ -n $1 ]] && graphFile=$1

  $SUDO perf script | ${FGPATH}/stackcollapse-perf.pl | ${FGPATH}/flamegraph.pl --color=java --hash > flamegraph.svg && echo "Created FlameGraph $graphFile"
}

function export-preserve-frame {
  echo added +PreserveFramePointer to JAVA_OPTS
  export JAVA_OPTS="${JAVA_OPTS} -XX:+PreserveFramePointer"
  echo JAVA_OPTS=${JAVA_OPTS}
}

function check-perf-event-setting {
  local PES=`cat /proc/sys/kernel/perf_event_paranoid`
  [[ $PES -le 0 ]] && (echo Perf-event is enabled, its value is $PES; return 0) \
                   || (echo Perf-event is disabled, update /proc/sys/kernel/perf_event_paranoid to 0 on the Docker host machine; return 1)
}

function setup-perf {
  set -e
  setup-java-home
  setup-perf-toolings
  setup-perf-map-agent
  setup-FlameGraph
  export-preserve-frame
  check-perf-event-setting
  set +e
}

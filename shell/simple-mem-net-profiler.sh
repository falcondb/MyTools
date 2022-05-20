NETINTS=eth0,  // seems only eth0 is UP and using mlx driver, eth1, enp94sX are DOWN
IFS=","

pushd .
cd /tmp

for c in {1..100}
do
  TST=$(date '+%m-%d-%H-%M')
  vmstat -m | grep -v Cache | sort -k 5 -n  >> $TST-slab-distribution

  cat /proc/meminfo | sort -k 2 -n -r > $TST-memiinfo

  free -m > $TST-free

  for ni in $NETINTS; do
    echo  $TST: $ni \
          $(cat /sys/class/net/$ni/statistics/rx_packets)  \
          $(cat /sys/class/net/$ni/statistics/tx_packets) >> net-packet-stat
  done

  sleep 3600
done

popd

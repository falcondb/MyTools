ZKLEADERIP=
function find-leader {
 kubectl get po -l app=zk -o jsonpath='{.items[*].status.podIP}' | tr ' ' '\n'  > zkips.log ; echo >> zkips.log
 ZKLEADERIP=$(cat zkips.log | while read IP ; do echo stat - | nc $IP 2181 | grep "^Mode: leader" &> /dev/null && echo $IP ; done)
 rm -f zkips.log &>/dev/null
 [[ -n $VERBOSE ]] && echo "Zookeeper Leader IP: $ZKLEADERIP"
}


function restart-zk-leader {
 CMD="kubectl get pods -o=jsonpath='{.items[?(@.status.podIP==\"${ZKLEADERIP}\")].metadata.name}'"
 kubectl delete po $(eval "$CMD") 
}

function watchall {
   watch -n 2 kubectl get po -o wide 
}

function run-zk-fail-over-test {
  find-leader && restart-zk-leader && watchall
}

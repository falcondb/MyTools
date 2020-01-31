kubectl get po -l app=zk -o jsonpath='{.items[*].status.podIP}' | tr ' ' '\n'  > zkips.log ; echo >> zkips.log
cat zkips.log | while read IP ; do echo stat - | nc $IP 2181 | grep "^Mode: leader" && echo IP: $IP ; done
rm -f zkips.log &>/dev/null

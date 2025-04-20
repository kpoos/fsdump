#!/usr/bin/bash

# dump-tunnel.sh version v0.1
# opening ssh tunel for reverse data traffic needed by dump.sh, and starting 
# dump over the ssh session.
# closing ssh tunnel at the end.
# on the client, fsdump user runs the script with sudo, so add the next row 
# to the sudoers file
# fsdump ALL = NOPASSWD:/usr/bin/nohup /usr/bin/bash /root/dump.sh 10022
#
# Usage: ./dump-tunnel.sh <CLIENT> <TUNNEL_PORT>

CLIENT=$1;
TPORT=$2;
#MD5SUM=$(md5sum /fsdumptoop/tools/dump.sh)
ROOTHOME=`getent passwd root| cut -d: -f6`

#### Check and create crontab entry
function cron_check {
  number=$RANDOM
  offset=15

  #min=$(let("number%=60"))
  let "number %= 59" 
  min=$(expr $number + 1)

  number=$RANDOM
  let "number %= 23"
  hour=$(expr $number + 1)

  number=$RANDOM
  let "number %= 6"
  dom=$(expr $number + 1)
  dom2=$dom
  let "dom2 += offset"

  #echo "$min $hour $dom,$dom2 * *"
  echo "Saving crontab" 0
  crontab -l | cat > crontab.dump-save
  #croncmd="/root/dump.sh 2> /root/dump.sh_cron_errors < /dev/null"
  #croncmd="ssh root@$CLIENT -R $TPORT:localhost:22 /usr/bin/nohup /usr/bin/bash /root/dump.sh $TPORT"
  croncmd="/fsdumppool/tools/dump-tunnel.sh $CLIENT $TPORT 2> ~/dump-tunnel.sh_cron_errors_$CLIENT  < /dev/null"
  echo "."

  cronjob="$min $hour $dom,$dom2 * * $croncmd"
  ###crontab -l | $SSH ${DUMPUSER}@${DUMPSERVER} "cat > ${CFGDIR}/crontab"
  ### crontab - does not work on solaris
  ###( crontab -l | grep -v "$croncmd" ; echo "$cronjob" ) | crontab -
  crontab -l| grep "$croncmd" || cat <(crontab -l) <(echo "$cronjob") | crontab

}

if [ $# -ne 2 ]; then
  echo "Usage: ./dump-tunnel.sh <CLIENT> <TUNNEL_PORT>"
  exit 1
fi 

cron_check

ssh $CLIENT -R $TPORT:localhost:2022 sudo /usr/bin/nohup /usr/bin/bash /root/dump.sh $TPORT


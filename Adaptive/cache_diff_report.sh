#!/bin/sh
#set -x

SERVER=perf-db01
USER=yma
DIFFPATH=/bkup/continuous_diff/data/XantusPD2_Obfv2_Bkup_2016_07_16_C1-MixedLoad_SickKids_Genesis__cluster1

REPORT_PATH=$HOME/diff_report
REPORT_FILE=diff_report.txt

KEY_TO_INVESTIGATE="Diffs to Investigate"

function sanity_check () {
  [ $# -lt 2 ] && echo "First paramenter is the path of base diff\nSecond is the path of target diff\nThird is your email@adapativeinsight.com\n   E.g., $0 diff_265206-269646_run1 diff_265206-269646_run2 yma" && return 1

  [ ! -d $DIFFPATH/$1 ] && echo "Cann't find $DIFFPATH/$1 on server @SERVER" && return 1
  [ ! -d $DIFFPATH/$2 ] && echo "Cann't find $DIFFPATH/$2 on server @SERVER" && return 1
  [ ! -z $3 ] && USER=$3
  BASEDIFF=$1
  TARGETDIFF=$2
  REPORT_FILE=$REPORT_PATH/$TARGETDIFF/diff_report.txt
}

function prepare () {
  rm -r $REPORT_PATH/$TARGETDIFF
  mkdir -p $REPORT_PATH/$TARGETDIFF
}

function scan_files () {
  for f in $DIFFPATH/$TARGETDIFF/diff/*
  do
    local filename=$(basename $f)
    if [[ ! -f $DIFFPATH/$BASEDIFF/diff/$filename ]]; then
      echo "$filename is a new diff" >> $REPORT_FILE
    else
      diff $DIFFPATH/$BASEDIFF/diff/$filename $DIFFPATH/$TARGETDIFF/diff/$filename | grep -i "$KEY_TO_INVESTIGATE" >> $REPORT_FILE && echo -e "\n\n" >> $REPORT_FILE
    fi
  done

  for f in $DIFFPATH/$BASEDIFF/diff/*
  do
    local filename=$(basename $f)
    if [[ ! -f $DIFFPATH/$TARGETDIFF/diff/$filename ]]; then
      echo "$filename is resolved" >> $REPORT_FILE
    fi
  done
}

function collect_notify () {
  mail -s "Cache diff report for $TARGETDIFF base on $BASEDIFF on $SERVER" -a $REPORT_FILE \
  $USER@adaptiveinsights.com < /dev/null
}

sanity_check $@ || exit

prepare
scan_files
collect_notify

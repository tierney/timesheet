#!/bin/bash

file="/home/paul/notes/.timesheet"
curr="/home/paul/notes/.timesheet.state"
weekstart="thursday"

if [[ $# -eq 0 || $1 == "help" ]]; then
    echo -ne \
"USAGE:\n"\
"start [backdate] -- start timing\n"\
"stop [backdate] -- stop timing (prompts for message)\n"\
"peek|status -- show time this period\n"\
"message message -- describe period\n"\
"cancel -- cancel period\n"\
"today|day [ago] -- show time today or previous days\n"\
"week [ago] -- show time this or past weeks\n"\
"all -- show all time recorded\n"\
"entry \"startdate\" \"enddate\" message\n"\
"help\n"
    exit
fi

command=$1
shift

if [ $command == "status" ]; then
    command="peek"
fi

if [ $command == "today" ]; then
    command="day"
fi

if [ ! -e $file ]; then
    echo "no timesheet found.  creating $file"
    echo "timesheet" > $file
fi

fileid=`head -n1 $file`
if [ "$fileid" != "timesheet" ]; then
    echo "$file is not a timesheet file!"
    echo "make sure it has \"timesheet\" as its first line or use a different file"
    exit
fi

if [ -e $curr ]; then
    currid=`head -n1 $curr`
    if [ "$currid" != "timesheet" ]; then
        echo "$curr is not a timesheet state file!"
        echo "move the file or use a different one for the timesheet state file"
        exit
    fi
fi


function dur2str {
    local duration=$1
    local hours=$(expr $duration / 3600)
    local minutes=$(expr $duration % 3600 / 60)
    local seconds=$(expr $duration % 60)
    local timestr=
    local timelabel=
    if [ $hours -gt 0 ]; then
        if [[ $hours -eq 1 && $minutes -eq 0 && $seconds -eq 0 ]]; then
            timelabel="hour"
        else
            timelabel="hours"
        fi
        printf "%02d:%02d:%02d %s" $hours $minutes $seconds $timelabel
    elif [ $minutes -gt 0 ]; then
        if [[ $minutes -eq 1 && $seconds -eq 0 ]]; then
            timelabel="minute"
        else
            timelabel="minutes"
        fi
        printf "%02d:%02d %s" $minutes $seconds $timelabel
    else
        if [ $seconds -eq 1 ]; then
            timelabel="second"
        else
            timelabel="seconds"
        fi
        printf "%d %s" $seconds $timelabel
    fi
}

if [ $command == "start" ]; then
    if [[ ! -e $curr ]]; then
        if [ $# -gt 0 ]; then
            backdate="-d \"$@\""
            echo "backdating"
            echo "date $backdate" | bash
            if [ $? -ne 0 ]; then
                echo "invalid date. try again."
                exit
            fi
        fi
        echo "timesheet" > $curr
        echo "date $backdate +%Y/%m/%d\ %H:%M:%S >> $curr" | bash
        echo "started timing"
    else
        echo "the timer is already going."
        exit
    fi
elif [[ $command == "stop" || $command == "peek" ]]; then
    if [[ -e $curr ]]; then
        last=`head -n2 $curr | tail -n1`
        lastsec=`date -d "$last" +%s`
        if [ $# -gt 0 ]; then
            backdate="-d \"$@\""
            echo "backdating"
            echo "date $backdate" | bash
            if [ $? -ne 0 ]; then
                echo "invalid date. try again."
                exit
            fi
        fi
        now=`echo "date $backdate +%Y/%m/%d\ %H:%M:%S" | bash`
        thissec=`echo "date $backdate +%s" | bash`
        duration=$(expr $thissec - $lastsec)
        lines=`cat $curr | wc -l`
        if [ $command == "stop" ]; then
            if [ "$lines" == "2" ]; then
                message=
                while [ "$message" == "" ]; do
                    read -p "please enter a mesage: " message
                done
            else
                message=`tail -n1 $curr`
            fi
            echo "$last $now $message" >> $file
            rm $curr
            tail -n1 $file
        else
            echo "started $last"
            if [ $lines -gt 2 ]; then
                echo "message: `tail -n1 $curr`"
            fi
        fi
        echo
        echo "$(dur2str $duration)"
    else
        echo "the timer is not going"
    fi
elif [ $command == "message" ]; then
    if [ -e $curr ]; then
        lines=`cat $curr | wc -l`
        if [ "$lines" == "2" ]; then
            message=
            while [ "$message" == "" ]; do
                read -p "please enter a mesage: " message
            done
            echo "$message" >> $curr
        else
            echo "the message is already set"
            echo "message: `tail -n1 $curr`"
        fi
    else
        echo "the timer is not going"
    fi
elif [ $command == "cancel" ]; then
    echo "started `head -n2 $curr | tail -n1`"
    read -p "are you sure you want to cancel the entry? [y/N] " yn
    case "$yn" in
        y|Y) rm $curr; echo "cancelled timer";;
        *) echo "aborted.  did not cancel the timer";;
    esac
elif [[ $command == "day" || $command == "week" ]]; then
    if [ $command == "day" ]; then
        since=`date -d 00:00 +%s`
    elif [ $command == "week" ]; then
        since=`date -d "last $weekstart" +%s`
    fi
    until=`date +%s`
    tempfile=`tempfile -d /tmp/ -p time`
    cat $file | tail -n +2 | while read line; do
        sdate=`echo $line | awk '{print $1, $2}'`
        s=`date -d "$sdate" +%s`
        edate=`echo $line | awk '{print $3, $4}'`
        e=`date -d "$edate" +%s`
        if [[ $s -gt $since && $s -lt $until || $e -gt $since && $e -lt $until ]]; then
            if [[ $s -lt $since ]]; then
                s=$since
            fi
            if [[ $e -gt $until ]]; then
                e=$until
            fi
            thisduration=$((e - s))
            echo $thisduration >> $tempfile
            echo $(dur2str $thisduration) `echo $line | cut -d" " -f5-`
        fi
    done
    if [ -e $curr ]; then
        sdate=`head -n2 $curr | tail -n1`
        s=`date -d "$sdate" +%s`
        e=`date +%s`
        if [[ $s -gt $since && $s -lt $until || $e -gt $since && $e -lt $until ]]; then
            if [[ $s -lt $since ]]; then
                s=$since
            fi
            if [[ $e -gt $until ]]; then
                e=$until
            fi
            thisduration=$((e - s))
            echo $thisduration >> $tempfile
            echo "$(dur2str $thisduration) (current timer)"
        fi
    fi
    duration=0
    for i in `cat $tempfile`; do
        duration=$((duration + i))
    done
    rm $tempfile
    echo
    echo $(dur2str $duration)
elif [ $command == "all" ]; then
    echo "not yet implemented"
    exit
elif [ $command == "entry" ]; then
    echo "not yet implemented"
    exit
else
    echo "invalid command.  use the help command."
    exit
fi
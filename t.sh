#!/bin/bash

# user settings
file="$HOME/notes/.timesheet"
curr="$HOME/notes/.timesheet.state"
weekstart_day="thursday"
weekstart_time="11:30am"
weekhours=40

# some convenience variables. please don't touch
weekstart="$weekstart_day $weekstart_time"
weekseconds=$((weekhours * 3600))

# show help
if [[ $# -eq 0 || $1 == "help" ]]; then
    echo -ne \
"USAGE:\n"\
"start [backdate] -- start timing\n"\
"stop [backdate] -- stop timing (prompts for message)\n"\
"peek|status|this -- show time this period\n"\
"message message -- describe period\n"\
"cancel -- cancel period\n"\
"last -- show the last period\n"\
"today|yesterday|day [ago] -- show time today or previous days\n"\
"week [ago] -- show time this or past weeks (ago is -1, -2, ...)\n"\
"left|remaining -- show the total and per-day time left\n"\
"perday -- show the average time per-day done and to do\n"\
"break -- time since last period\n"\
"help -- show command help\n"
    exit
fi

command=$1
shift

# command aliases
if [[ $command == "status" || $command == "this" ]]; then
    command="peek"
fi

if [ $command == "today" ]; then
    command="day"
fi

if [ $command == "remaining" ]; then
    command="left"
fi

# automatically create a new timesheet file
if [ ! -e $file ]; then
    echo "no timesheet found.  creating $file"
    echo "timesheet" > $file
fi

# checks for a special signature ("timesheet" is the first line) to
# avoid modifying files that are not really for this timesheet program
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

# print a time in seconds in hours, minutes, and seconds
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

# perform timesheet management actions
if [ $command == "start" ]; then
    if [[ -e $curr ]]; then
        read -p "the timer is already going.  start a new one? [Y/n] " yn
        case "$yn" in
            n|N)
                echo "aborted.  did not cancel the timer";
                exit;
                ;;
            *)
                echo "stopping old timer";
                $0 stop $@;
                echo
                ;;
        esac
    fi
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
            message=$@
            while [ "$message" == "" ]; do
                read -p "please enter a mesage: " message
            done
            echo "$message" >> $curr
            echo "message set"
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
elif [ $command == "last" ]; then
    lines=`cat $file | wc -l`
    if [ $lines -gt 1 ]; then
        tail -n1 $file
    else
        echo "no timesheet entries yet"
    fi
elif [[ $command == "day" || $command == "week" || $command == "yesterday" \
    || $command == "left" ]]; then
    echo "poop$command"
    if [ $command == "yesterday" ]; then
        since=`date -d "yesterday 00:00" +%s`
        until=`date -d "yesterday 23:59:59" +%s`
    elif [ $command == "day" ]; then
        since=`date -d 00:00 +%s`
        until=`date +%s`
    elif [ $$command == "left" ]; then
        since=`date -d "last $weekstart" +%s`
        until=`date +%s`
    elif [ $command == "week" ]; then
        ago=$@
        if [ "$ago" == "" ]; then
            since=`date -d "last $weekstart" +%s`
            until=`date +%s`
        else
            since=`date -d "$weekstart_time $weekstart_day, $((ago-1)) weeks" +%s`
            until=`date -d "$weekstart_time $weekstart_day, $ago weeks" +%s`
        fi
    else
        echo "bob5"
    fi
    detail=true
    if [ $command == "left" ]; then
        detail=false
    fi
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
            if [ "$detail" == "true" ]; then
                echo  `echo $line | cut -d" " -f1` $(dur2str $thisduration) `echo $line | cut -d" " -f5-`
            fi
        fi
    done
    if [ -e $curr ]; then
        sdate=`head -n2 $curr | tail -n1`
        s=`date -d "$sdate" +%s`
        e=`date +%s`
        if [[ $s -gt $since && $s -lt $until || $e -gt $since && $e -le $until ]]; then
            if [[ $s -lt $since ]]; then
                s=$since
            fi
            if [[ $e -gt $until ]]; then
                e=$until
            fi
            thisduration=$((e - s))
            echo $thisduration >> $tempfile
            if [ "$detail" == "true" ]; then
                echo "$(dur2str $thisduration) (current timer)"
            fi
        fi
    fi
    duration=0
    for i in `cat $tempfile`; do
        duration=$((duration + i))
    done
    rm $tempfile
    if [ $command == "left" ]; then
        left=$((weekseconds - duration))
        echo "$(dur2str $left) left"
        daysleft=$(((`date -d "$weekstart" +%w` + 7 - `date +%w`) % 7))
        echo "$daysleft days left"
    else
        echo
        echo $(dur2str $duration)
    fi
elif [ $command == "perday" ]; then
    echo "not yet implemented"
    exit
elif [ $command == "break" ]; then
    if [ ! -e $curr ]; then
        lines=`cat $file | wc -l`
        if [ $lines -gt 1 ]; then
            last=`tail -n1 $file | awk '{print$3,$4}'`
            lastsec=`date -d "$last" +%s`
            currsec=`date +%s`
            echo "$(dur2str $((currsec - lastsec))) on break"
        else
            echo "no timesheet entries yet"
        fi
    else
        echo "the timer is on"
    fi
else
    echo "invalid command.  use the help command."
    exit
fi

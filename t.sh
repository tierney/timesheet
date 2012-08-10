#!/bin/bash

file="/home/paul/notes/.timesheet"
curr="/home/paul/notes/.timesheet.state"
weekstart="thursday"

if [[ $# -eq 0 || $1 == "help" ]]; then
    echo -ne \
        "USAGE:\n" \
        "start [backdate] -- start timing\n" \
        "stop [backdate] -- stop timing (prompts for message)\n" \
        "peek -- show time this period\n" \
        "status -- show time this period\n" \
        "message message -- describe period\n" \
        "cancel -- cancel period\n" \
        "day [ago] -- show time today or previous days\n" \
        "week [ago] -- show time this or past weeks\n" \
        "all -- show all time recorded\n" \
        "entry \"startdate\" \"enddate\" message\n" \
        "help\n"
    exit
fi

command=$1
shift

if [ $command == "status" ]; then
    command="peek"
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
        hours=$(expr $duration / 3600)
        minutes=$(expr $duration % 3600 / 60)
        seconds=$(expr $duration % 60)
        timestr=
        timelabel=
        if [ $hours -gt 0 ]; then
            if [[ $hours -eq 1 && $minutes -eq 0 && $seconds -eq 0 ]]; then
                timelabel="hour"
            else
                timelabel="hours"
            fi
            timestr="$hours:"
        fi
        if [ $minutes -gt 0 ]; then
            if [ "$timelabel" == "" ]; then
                if [[ $minutes -eq 1 && $seconds -eq 0 ]]; then
                    timelabel="minute"
                else
                    timelabel="minutes"
                fi
            fi
            timestr="$timestr$minutes:"
        fi
        if [ "$timelabel" == "" ]; then
            if [ $seconds -eq 1 ]; then
                timelabel="second"
            else
                timelabel="seconds"
            fi
        fi
        timestr="$timestr$seconds"
        echo "$timestr $timelabel"
        if [ $command == "stop" ]; then
            lines=`cat $curr | wc -l`
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
elif [ $command == "day" ]; then
    echo "not yet implemented"
    exit
elif [ $command == "week" ]; then
    echo "not yet implemented"
    exit
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
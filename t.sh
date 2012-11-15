#!/bin/bash

# user settings
file="$HOME/.timesheet"        # timesheet
curr="$HOME/.timesheet.state"  # current timer
weekstart_day="thursday"       # week starting day
weekstart_time="11:30pm"       # week starting time
weekhours=40                   # working hours in a week
maxdaysoff=2                   # maximum days off

# some convenience variables. please don't touch
weekstart="$weekstart_day $weekstart_time"
weekseconds=$((weekhours * 3600))

# show help
if [[ $# -eq 0 || $1 == "help" ]]; then
    echo -ne \
"OPERATION:\n"\
"start [-m msg] [backdate]\t\tstart timing\n"\
"stop [-m msg] [backdate]\t\tstop timing (prompts for message)\n"\
"message, msg [message]\tdescribe this period\n"\
"cancel\t\t\tcancel this period\n"\
"import\t\t\timport csv from mbox\n"\
"\n"\
"REPORTING:\n"\
"peek, status, this\tthis period's time\n"\
"last\t\t\tlast period's time\n"\
"break\t\t\ttime since last period\n"\
"today\t\t\ttoday's time\n"\
"yesterday, ytd\t\tyesterday's time\n"\
"day [ago]\t\tprevious day's time (ago = -1, -2, ...)\n"\
"week [ago]\t\tthis or a past week's time (ago = -1, -2, ...)\n"\
"left, remaining\t\ttime and days left this week\n"\
"done\t\t\thours done and days past this week\n"\
"since [date]\t\ttime since a date string (see -d in \"man date\")\n"\
"breakdown [ago]\t\tthis or a previous week's time in detail (ago = -1, ...)\n"\
"\n"\
"HELP:\n"\
"help\t\t\tshow this help screen\n"
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
if [ $command == "msg" ]; then
    command="message"
fi
if [ $command == "ytd" ]; then
    command="yesterday"
fi

# command-line message
message=
if [ "$1" == "-m" ]; then
    shift
    message=$1
    shift
fi

if [[ "$message" != "" && $command != "start"
            && $command != "stop" ]]; then
    echo "ignoring superfluous -m option"
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
    if [ "$currid" != "timesheet.state" ]; then
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

#pluralize a word
function pluralize {
    local singular=$1
    local plural=$2
    local num=$3
    if [ $num -eq 1 ]; then
        echo $singular
    else
        echo $plural
    fi
}

# perform timesheet management actions
if [[ $command == "start" ]]; then
    if [[ -e $curr ]]; then
        read -p "the timer is already going.  start a new one? [Y/n] " yn
        case "$yn" in
            n|N)
                echo "aborted.  did not cancel the timer";
                exit;
                ;;
            *)
                echo "stopping old timer";
                $0 stop $@
                echo
                ;;
        esac
    fi
    if [ $# -gt 0 ]; then
        if [ $command == "start" ]; then
            backdate="-d \"$@\""
            echo "date $backdate" | bash >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "invalid date. try again."
                exit
            fi
        fi
    fi
    echo "timesheet.state" > $curr
    echo "date $backdate +%Y/%m/%d\ %H:%M:%S >> $curr" | bash
    echo "started timing"
    if [ "$message" != "" ]; then
        $0 message $message
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
                while [ "$message" == "" ]; do
                    read -p "please enter a message: " message
                done
            else
                message=`tail -n1 $curr`
            fi
            echo "$last $now $message" >> $file
            rm $curr
            tail -n1 $file
            echo
            echo "$(dur2str $duration)"
        else
            if [ $lines -gt 2 ]; then
                message=`tail -n1 $curr`
            fi
            echo "$(dur2str $duration)" $message
            echo "started at `echo $last | cut -d" " -f2`"
        fi
    else
        echo "the timer is not going"
    fi
elif [ $command == "message" ]; then
    if [ -e $curr ]; then
        lines=`cat $curr | wc -l`
        if [ $lines -gt 2 ]; then
            echo "the message is already set"
            echo "message: `tail -n1 $curr`"
            read -p "do you want to change the message? [y/N] " yn
            case "$yn" in
                y|Y)
                    tempfile=`tempfile`
                    trap "rm -f $tempfile" EXIT
                    mv $curr $tempfile
                    head -n2 $tempfile > $curr
                    ;;
                *)
                    echo "okay.  leaving the existing message alone"
                    exit
                    ;;
            esac
        fi
        message=$@
        while [ "$message" == "" ]; do
            read -p "please enter a mesage: " message
        done
        echo "$message" >> $curr
        echo "message set"
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
    || $command == "left" || $command == "done" || $command == "since" ]]; then
    if [ $command == "yesterday" ]; then
        since=`date -d "yesterday 00:00" +%s`
        until=`date -d "yesterday 23:59:59" +%s`
    elif [ $command == "day" ]; then
        ago=$@
        if [ "$ago" == "" ]; then
            since=`date -d 00:00 +%s`
            until=`date +%s`
        else
            echo "not yet implemented for previous days"
            exit
        fi
    elif [[ $command == "left" || $command == "done" ]]; then
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
    elif [ $command == "since" ]; then
        date=$@
        since=`date -d "$date" +%s`
        until=`date +%s`
    fi
    detail=true
    if [[ $command == "left" || $command == "done" ]]; then
        detail=false
    fi
    tempfile=`tempfile -d /tmp/ -p time`
    trap "rm -f $tempfile" EXIT
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
                if [ $command == "week" ]; then
                    optdate=`echo $line | cut -d" " -f1`
                else
                    optdate=
                fi
                echo $optdate $(dur2str $thisduration) `echo $line | cut -d" " -f5-`
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
                if [ $command == "week" ]; then
                    optdate=`date +%Y/%m/%d`
                else
                    optdate=
                fi
                if [[ -e $curr && `cat $curr | wc -l` -gt 2 ]]; then
                    messageopt=" `tail -n1 $curr`"
                fi
                echo $optdate "$(dur2str $thisduration)$messageopt (current)"
            fi
        fi
    fi
    duration=0
    for i in `cat $tempfile`; do
        duration=$((duration + i))
    done
    if [ $command == "left" ]; then
        left=$((weekseconds - duration))
        echo "$(dur2str $left) left"
        daysleft=$(((`date -d "$weekstart" +%w` + 7 - `date +%w`) % 7))
        echo "$daysleft $(pluralize day days $daysleft) left including today"
    else
        if [ $detail == "true" ]; then
            echo
        fi
        if [ $command == "done" ]; then
            dayspast=$(((`date +%w` + 7 - `date -d "$weekstart" +%w`) % 7))
            echo "$(dur2str $duration)"
            echo "$dayspast $(pluralize day days $dayspast)"
        else
            echo $(dur2str $duration)
        fi
    fi
elif [ $command == "breakdown" ]; then
    # painfully slow! need to collect each day in one pass of the
    # timesheet database.
    for day in {0..6}; do
        since=`date -d "$day day last $weekstart" +%s`
        until=`date -d "$((day+1)) day last $weekstart" +%s`
        tempfile=`tempfile -d /tmp/ -p time`
        trap "rm -f $tempfile" EXIT
        cat $file | tail -n +2 | while read line; do
            sdate=`echo $line | awk '{print $1, $2}'`
            s=`date -d "$sdate" +%s`
            edate=`echo $line | awk '{print $3, $4}'`
            e=`date -d "$edate" +%s`
            if [[ $s -gt $since && $s -lt $until ]]; then
                thisduration=$((e - s))
                
                echo $thisduration >> $tempfile
            fi
        done
        duration=0
        for i in `cat $tempfile`; do
            duration=$((duration + i))
        done
        echo `date -d "$day day last $weekstart" +%a\ %b\ %d` \
            $(dur2str $duration)
    done
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
elif [ $command == "import" ]; then
    script=`readlink $0`
    dir=`dirname $script`
    mbox=$dir/mbox.py

    fetchmail
    $mbox
else
    echo "invalid command.  use the help command."
    exit
fi

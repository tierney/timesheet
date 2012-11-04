TIMESHEET=~/.py.timesheet
STATE=~/.py.timesheet.state

function dbg {
  arg=$@
  cat <<EOF

--------------------------------------------------------------------------------
EOF
  echo -e "[TEST] COMMAND $arg"
  eval $arg
  echo -e "\n[TEST] TIMESHEET $TIMESHEET"
  cat $TIMESHEET
  echo -e "\n[TEST] STATE $STATE"
  cat $STATE
  read -p "Press [Enter] to go to the next test"
}

read -p "Press [Enter] to start testing"

rm -f $TIMESHEET $STATE

echo "[TEST] basic functions"
dbg ./t.py start
dbg 'echo "test message 1" | ./t.py stop'
dbg ./t.py start
dbg 'echo "n" | ./t.py start'
dbg 'echo -ne "y\ntest message 2" | ./t.py start'
dbg 'echo "test message 3" | ./t.py stop'

echo -e "\nbasic error messages"
dbg ./t.py message
dbg ./t.py stop
dbg ./t.py cancel

echo -e "\ncancelling"
dbg ./t.py start
dbg 'echo "n" | ./t.py cancel'
dbg 'echo "y" | ./t.py cancel'

echo -e "\nmessages"
dbg ./t.py start
dbg 'echo "test message 4" | ./t.py message'
dbg ./t.py stop
dbg './t.py start -m "test message 5"'
dbg ./t.py stop
dbg ./t.py start
dbg './t.py stop -m "test message 6"'
dbg './t.py start -m "test message 7"'
dbg 'echo "n" | ./t.py message "test message 8"'
dbg 'echo "y" | ./t.py message "test message 9"'
dbg './t.py stop -m "test message 10"'

echo -e "\nbackdating"

dbg ./t.py start 2 hours ago
dbg ./t.py message test message 11
dbg ./t.py stop 1 hour ago
dbg ./t.py start 30 minutes ago
dbg ./t.py message test message 12
dbg 'echo "y" | ./t.py start 20 minutes ago'
dbg ./t.py message test message 13
dbg ./t.py stop 10 minutes ago

echo -e "\nbackdating with messages"

dbg './t.py start -m "test message 14" 2 hours ago'
dbg ./t.py stop 1 hour ago
dbg ./t.py start 30 minutes ago
dbg './t.py stop -m "test message 15" 20 minutes ago'
dbg './t.py start -m "test message 16" 2 hours ago'
dbg 'echo "y" | ./t.py start -m "test message 17" 5 minutes ago'
dbg './t.py stop -m "test message 18" 1 minute ago'

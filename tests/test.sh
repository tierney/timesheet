TIMESHEET=test.timesheet
STATE=test.state

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
dbg ../t.py -c test.config start
dbg 'echo "test message 1" | ../t.py -c test.config stop'
dbg ../t.py -c test.config start
dbg 'echo "n" | ../t.py -c test.config start'
dbg 'echo -ne "y\ntest message 2" | ../t.py -c test.config start'
dbg 'echo "test message 3" | ../t.py -c test.config stop'

echo -e "\nbasic error messages"
dbg ../t.py -c test.config message
dbg ../t.py -c test.config stop
dbg ../t.py -c test.config cancel

echo -e "\ncancelling"
dbg ../t.py -c test.config start
dbg 'echo "n" | ../t.py -c test.config cancel'
dbg 'echo "y" | ../t.py -c test.config cancel'

echo -e "\nmessages"
dbg ../t.py -c test.config start
dbg 'echo "test message 4" | ../t.py -c test.config message'
dbg ../t.py -c test.config stop
dbg '../t.py -c test.config start -m "test message 5"'
dbg ../t.py -c test.config stop
dbg ../t.py -c test.config start
dbg '../t.py -c test.config stop -m "test message 6"'
dbg '../t.py -c test.config start -m "test message 7"'
dbg 'echo "n" | ../t.py -c test.config message "test message 8"'
dbg 'echo "y" | ../t.py -c test.config message "test message 9"'
dbg '../t.py -c test.config stop -m "test message 10"'

echo -e "\nbackdating"

dbg ../t.py -c test.config start 2 hours ago
dbg ../t.py -c test.config message test message 11
dbg ../t.py -c test.config stop 1 hour ago
dbg ../t.py -c test.config start 30 minutes ago
dbg ../t.py -c test.config message test message 12
dbg 'echo "y" | ../t.py -c test.config start 20 minutes ago'
dbg ../t.py -c test.config message test message 13
dbg ../t.py -c test.config stop 10 minutes ago

echo -e "\nbackdating with messages"

dbg '../t.py -c test.config start -m "test message 14" 2 hours ago'
dbg ../t.py -c test.config stop 1 hour ago
dbg ../t.py -c test.config start 30 minutes ago
dbg '../t.py -c test.config stop -m "test message 15" 20 minutes ago'
dbg '../t.py -c test.config start -m "test message 16" 2 hours ago'
dbg 'echo "y" | ../t.py -c test.config start -m "test message 17" 5 minutes ago'
dbg '../t.py -c test.config stop -m "test message 18" 1 minute ago'

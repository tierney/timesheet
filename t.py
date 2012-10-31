#!/usr/bin/env python

import os
import sys
import util

from TimesheetLog import TimesheetLog
from TimesheetState import TimesheetState

from datetime import datetime
from datetime import timedelta

TIMESHEET = '~/.py.timesheet'
STATE = '~/.py.timesheet.state'

def print_usage():
  print "USAGE"
  print prog + " start [-m msg] [backdate]"
  print prog + " stop [-m msg] [backdate]"
  print prog + " message msg"
  print prog + " cancel"

def main(argv):
  if len(argv) == 1:
    print_usage()
    return

  # Get the command and its arguments
  command = argv[1]
  args = argv[2:]

  # Get the "-m message" parameter for the start and stop commands.
  command_message = None
  if len(args) > 0 and command in ['start', 'stop'] and args[0] == '-m':
    if len(args) == 1:
      print "-m must take a message as a parameter"
      exit(1)
    else:
      command_message = args[1]
      args = args[2:]

  argument = ' '.join(args)

  timesheet_log = TimesheetLog(os.path.expanduser(TIMESHEET))
  timesheet_state = TimesheetState(os.path.expanduser(STATE))

  if command == 'start':
    ret = timesheet_state.Get()
    if not ret:
      timesheet_state.Set(datetime.today())
      print "started timing"
    else:
      start_time, logged_message = ret

      yn = ''
      while yn == '':
        yn = raw_input("the timer is already going.  start a new one? [Y/n] ")
      if yn.lower() == 'y':
        print "stopping older timer"
        stop_time = datetime.today();
        while logged_message == '':
          logged_message = raw_input("please enter a message: ")
        timesheet_log.AddEntry(start_time,
                               stop_time,
                               logged_message)
        timesheet_state.Clear()
        print util.get_string_from_date(start_time),
        util.get_string_from_date(stop_time), logged_message
        print
        print util.get_string_from_timedelta(stop_time - start_time)
        print
        timesheet_state.Set(datetime.today())
        print "started timing"
      else:
        print "aborted.  did not cancel the timer"
  elif command == 'stop':
    ret = timesheet_state.Get()
    if not ret:
      print "cannot stop what has not been started."
      return

    start_time, logged_message = ret
    stop_time = datetime.today();

    # TODO(tierney): If message is empty, ask the user.
    timesheet_log.AddEntry(start_time,
                           stop_time,
                           logged_message)
    timesheet_state.Clear()
    print util.get_string_from_date(start_time),
    util.get_string_from_date(stop_time), logged_message
    print
    print util.get_string_from_timedelta(stop_time - start_time)
  elif command == "message":
    ret = timesheet_state.Get()
    if not ret:
      print "the timer is not going"
      return

    start_time, logged_message = ret

    if logged_message != '':
      print "the message is already set"
      yn = ''
      while y == '':
        yn = raw_input("do you want to change the message? [y/N] ")

      if yn.lower() == 'n':
        print "okay.  leaving the existing message alone"
        return

      logged_message = ''

    while logged_message == '':
      logged_message = raw_input("please enter a message: ")

    timesheet_state.Set(start_time, logged_message)

    print "message set"
  elif command == "cancel":
    ret = timesheet_state.Get()
    if not ret:
      print "cannot stop what has not been started."
      return

    start_time, logged_message = ret
    print "started", util.get_string_from_date(start_time)
    
    yn = ''
    while yn == '':
      yn = raw_input("are you sure you want to cancel the entry? [y/N] ")
    if yn.lower() == 'y':
      timesheet_state.Clear()
      print "cancelled timer"
    else:
      "aborted.  did not cancel the timer"
  elif command == "status":
    ret = timesheet_state.Get()
    if not ret:
      print "cannot stop what has not been started."
      return

    start_time, logged_message = ret
    stop_time = datetime.today();
    print util.get_string_from_timedelta(stop_time - start_time), logged_message
    print "started at", util.get_string_from_date(start_time)
  else:
    print "invalid command"
    return


if __name__=='__main__':
  main(sys.argv)

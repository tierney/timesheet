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

def print_usage(argv):
  prog = os.path.basename(argv[0])
  print "USAGE"
  print prog + " start [-m msg] [backdate]"
  print prog + " stop [-m msg] [backdate]"
  print prog + " message msg"
  print prog + " cancel"

def main(argv):
  if len(argv) == 1:
    print_usage(argv)
    return

  # Get the command and its arguments
  command = argv[1]
  args = argv[2:]

  # Get the "-m message" parameter for the start and stop commands.
  command_message = ''
  if len(args) > 0 and command in ['start', 'stop'] and args[0] == '-m':
    if len(args) == 1:
      print "-m must take a message as a parameter"
      return
    else:
      command_message = args[1]
      args = args[2:]

  argument = ' '.join(args)

  timesheet_log = TimesheetLog(os.path.expanduser(TIMESHEET))
  timesheet_state = TimesheetState(os.path.expanduser(STATE))

  if command == 'start':
    ret = timesheet_state.Get()

    if argument != '':
      # backdate the timer
      starttime = util.string2date(argument)
      if starttime == None:
        print "invalid date. try again."
        return
    else:
      starttime = datetime.today()

    if ret:
      # stop the old timer first
      yn = ''
      while yn == '':
        yn = raw_input("the timer is already going.  start a new one? [Y/n] ")
        if yn.lower() != 'y':
          print "aborted.  did not cancel the timer"
          return
      print "stopping old timer"
      stoptime = starttime;
      logged_time, logged_message = ret
      while logged_message == '':
        logged_message = raw_input("please enter a message: ")
      timesheet_log.AddEntry(logged_time, stoptime, logged_message)
      timesheet_state.Clear()
      print util.date2string(logged_time), util.date2string(stoptime),
      logged_message
      print '\n', util.delta2string(stoptime - logged_time), '\n'

    timesheet_state.Set(starttime, command_message)
    print "started timing"
    if command_message != '':
      print "message set"

  elif command == 'stop':
    ret = timesheet_state.Get()
    if not ret:
      print "cannot stop what has not been started."
      return

    if argument != '':
      # backdate the timer
      stoptime = util.string2date(argument)
      if stoptime == None:
        print "invalid date. try again."
        return
    else:
      stoptime = datetime.today();

    logged_time, logged_message = ret
    entry_message = ''
    if command_message != '':
      entry_message = command_message
    else:
      while logged_message == '':
        logged_message = raw_input("please enter a message: ")
      entry_message = logged_message
    timesheet_log.AddEntry(logged_time, stoptime, entry_message)
    timesheet_state.Clear()
    print util.date2string(logged_time), util.date2string(stoptime),
    entry_message
    print '\n', util.delta2string(stoptime - logged_time)

  elif command == 'message':
    ret = timesheet_state.Get()
    if not ret:
      print "the timer is not going"
      return

    logged_time, logged_message = ret
    if logged_message != '':
      print "the message is already set"
      yn = ''
      while yn == '':
        yn = raw_input("do you want to change the message? [y/N] ")
      if yn.lower() == 'n':
        print "okay.  leaving the existing message alone"
        return
      logged_message = ''
    if argument != '':
      entry_message = argument
    else:
      while logged_message == '':
        logged_message = raw_input("please enter a message: ")
      entry_message = logged_message
    timesheet_state.Set(logged_time, entry_message)
    print "message set"

  elif command == 'cancel':
    ret = timesheet_state.Get()
    if not ret:
      print "cannot stop what has not been started."
      return

    logged_time, logged_message = ret
    print "started", util.date2string(logged_time)
    
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

    logged_time, logged_message = ret
    stop_time = datetime.today();
    print util.delta2string(stop_time - logged_time), logged_message
    print "started at", util.date2string(logged_time)

  else:
    print "invalid command"
    return


if __name__=='__main__':
  main(sys.argv)

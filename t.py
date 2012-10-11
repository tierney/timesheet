#!/usr/bin/env python

import argparse
import sys
import util

from TimesheetLog import TimesheetLog
from TimesheetState import TimesheetState

def main(argv):
  assert len(argv) > 1

  command = argv[1]
  assert command in ['start', 'stop']

  timesheet_log = TimesheetLog('/home/tierney/.timesheet')
  timesheet_state = TimesheetState('/home/tierney/.timesheet.state')

  if command == 'start':
    ret = timesheet_state.Get()
    if not ret:
      timesheet_state.Set(util.get_current_time())
    else:
      logged_time, message = ret

      # TODO(tierney): If message is empty, ask the user.
      # response = raw_input('Stop the current timer (%s)?' % logged_time)

      timesheet_log.AddEntry(util.get_date_from_string(logged_time),
                             util.get_current_date(),
                             message)
      timesheet_state.Clear()
      timesheet_state.Set(util.get_current_time())

  if command == 'stop':
    ret = timesheet_state.Get()
    if not ret:
      print "Cannot stop what has not been started."
      return

    logged_time, message = ret

    # TODO(tierney): If message is empty, ask the user.
    # response = raw_input('Stop the current timer (%s)?' % logged_time)

    timesheet_log.AddEntry(util.get_date_from_string(logged_time),
                           util.get_current_date(),
                           message)
    timesheet_state.Clear()



if __name__=='__main__':
  main(sys.argv)

#!/usr/bin/env python

import os
class TimesheetState(object):
  def __init__(self, filename):
    self.filename = filename

  def Set(self, start_time):
    with open(self.filename, 'w') as fh:
      fh.write('timesheet.state\n')
      fh.write(start_time)

  # Returns the (datetime, string message) if the time is set or None.
  def Get(self):
    if not os.path.exists(self.filename):
      return None

    with open(self.filename, 'r') as fh:
      # First line should say 'timesheet'.
      protocol_to_check = fh.readline().strip()
      assert protocol_to_check == 'timesheet.state'

      logged_time = fh.readline()
      message = fh.readline()

      return logged_time, message

  def Clear(self):
    if os.path.exists(self.filename):
      os.remove(self.filename)

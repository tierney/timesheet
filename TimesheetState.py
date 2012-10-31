#!/usr/bin/env python

import os
from datetime import datetime
import util

class TimesheetState(object):
  def __init__(self, filename):
    self.filename = filename

  def Set(self, start_time, message = ''):
    assert isinstance(start_time, datetime)
    # TODO(paul): Make sure timesheet state file doesn't exist yet.
    with open(self.filename, 'w') as fh:
      fh.write('timesheet.state\n')
      fh.write(util.get_string_from_date(start_time))
      fh.write('\n')
      if message != '':
        fh.write(message);
        fh.write('\n')

  # Returns the (datetime, string message) if the time is set or None.
  def Get(self):
    if not os.path.exists(self.filename):
      return None

    with open(self.filename, 'r') as fh:
      # First line should say 'timesheet'.
      protocol_to_check = fh.readline().strip()
      assert protocol_to_check == 'timesheet.state'

      logged_time = fh.readline().strip()
      message = fh.readline().strip()

      return util.get_date_from_string(logged_time), message

  def Clear(self):
    if os.path.exists(self.filename):
      # TODO(paul): Make sure the file has timesheet.state at the top.
      os.remove(self.filename)

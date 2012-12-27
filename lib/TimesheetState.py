#!/usr/bin/env python

import os
from datetime import datetime
import util

class TimesheetState(object):
  def __init__(self, filename):
    self.filename = filename

  # Set start of timer and its message.
  def Set(self, start_time, message = ''):
    assert isinstance(start_time, datetime)
    assert isinstance(message, str)
    # TODO check that message is a string
    with open(self.filename, 'w') as fh:
      fh.write('timesheet.state\n')
      fh.write(util.date2string(start_time))
      fh.write('\n')
      if message != '':
        fh.write(message);
        fh.write('\n')

  # Returns the (datetime, string message) if the time is set or None.
  def Get(self):
    if not os.path.exists(self.filename):
      return None

    with open(self.filename, 'r') as fh:
      protocol_to_check = fh.readline().strip()
      assert protocol_to_check == 'timesheet.state'

      logged_time = fh.readline().strip()
      message = fh.readline().strip()

      return util.string2date(logged_time), message

  def Clear(self):
    assert os.path.exists(self.filename)
    with open(self.filename, 'r') as fh:
      protocol_to_check = fh.readline().strip()
      assert protocol_to_check == 'timesheet.state'
    os.remove(self.filename)

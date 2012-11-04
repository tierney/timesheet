#!/usr/bin/env python

from datetime import datetime
import util
import os

class TimesheetLog(object):
  def __init__(self, filename):
    self.filename = filename

  def AddEntry(self, start_date, stop_date, message):
    assert isinstance(start_date, datetime)
    assert isinstance(stop_date, datetime)
    assert '\n' not in message

    if os.path.exists(self.filename):
      with open(self.filename, 'r') as fh:
        protocol_to_check = fh.readline().strip()
        if protocol_to_check != 'timesheet':
          print "invalid timesheet file"
          exit(1)
    else:
      with open(self.filename, 'w') as fh:
        fh.write("timesheet\n")

    with open(self.filename, 'a') as fh:
      fh.write('%s %s %s\n' % (util.date2string(start_date),
                               util.date2string(stop_date),
                               message))


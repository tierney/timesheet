#!/usr/bin/env python

from datetime import datetime
import util
import os

class TimesheetLog(object):
  def __init__(self, filename):
    self.filename = filename

  # Returns bool added, str errmessage
  def AddEntry(self, start_date, stop_date, message):
    if not isinstance(start_date, datetime):
      return False, 'start date must be a datetime object'
    if not isinstance(stop_date, datetime):
      return False, 'stop date must be a datetime object'
    if '\n' in message:
      return False, 'message cannot have newline characters'

    if os.path.exists(self.filename):
      with open(self.filename, 'r') as fh:
        protocol_to_check = fh.readline().strip()
        if protocol_to_check != 'timesheet':
          return False, 'invalid timesheet file'
    else:
      with open(self.filename, 'w') as fh:
        fh.write("timesheet\n")

    with open(self.filename, 'a') as fh:
      fh.write('%s %s %s\n' % (util.date2string(start_date),
                               util.date2string(stop_date),
                               message))
    return True, ''


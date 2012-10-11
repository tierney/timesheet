#!/usr/bin/env python

from datetime import datetime
import util

class TimesheetLog(object):
  def __init__(self, filename):
    self.filename = filename
    # TODO(tierney): Check if valid timesheet file.

  def AddEntry(self, start_date, stop_date, message):
    assert isinstance(start_date, datetime)
    assert isinstance(stop_date, datetime)
    assert '\n' not in message

    with open(self.filename, 'a') as fh:
      fh.write('%s %s %s\n' % (util.get_string_from_date(start_date),
                               util.get_string_from_date(stop_date),
                               message))


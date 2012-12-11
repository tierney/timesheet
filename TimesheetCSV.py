#!/usr/bin/env python

from datetime import datetime
import util
import os
import csv
import operator

class TimesheetCSV(object):
  def __init__(self, filename):
    self.filename = filename
    self.list = None
    self._entries = None

  # always has the entries in the database as a list.  None means invalid timesheet file
  @property
  def entries(self):
    if self._entries == None:
      if os.path.exists(self.filename):
        needs_sorting = False
        with open(self.filename, 'rb') as fh:
          reader = csv.reader(fh, delimiter=',')
          self._entries = list(reader)

          # check need to sort
          last = None
          for row in self._entries:
            start_date = row[0]
            if last == None:
              last = start_date
            elif start_date < last:
              needs_sorting = True
              break
            else:
              last = start_date

        if needs_sorting:
          # TODO verbose output
          self._entries = sorted(self._entries, key=operator.itemgetter(0))
          with open(self.filename, 'wb+') as fh:
            writer = csv.writer(fh, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            for row in self._entries:
              writer.writerow(row)
      else:
        self._entries = []

    return self._entries

  # add a new entry
  def AddEntry(self, start_date, stop_date, message):
    if not isinstance(start_date, datetime):
      return False, 'start date must be a datetime object'
    if not isinstance(stop_date, datetime):
      return False, 'stop date must be a datetime object'
    if '\n' in message:
      return False, 'message cannot have newline characters'

    # TODO cache recent entry hashes

    # check for duplicate entries
    new_hash = hash(util.date2string(start_date)+util.date2string(stop_date))
    for row in reversed(self.entries):
      item_start = row[0]
      item_stop = row[1]
      item_hash = hash(item_start+item_stop)
      if new_hash == item_hash:
        return False, "duplicate entry"

    with open(self.filename, 'ab+') as csvfile:
      writer = csv.writer(csvfile, delimiter=',',
                          quotechar='"', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
      writer.writerow([util.date2string(start_date),
                       util.date2string(stop_date),
                       message])

    # force reread of timesheet
    self._entries = None

    return True, ''

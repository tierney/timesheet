#!/usr/bin/env python

from datetime import datetime
import util
import os
import csv

class TimesheetCSV(object):
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
      reader = csv.reader(self.filename, delimiter=',')
      # check for duplicate entries
      # hashkey = util.date2string(start_date)+util.date2string(stop_date)
      # search backwards in log for same hash key
      # open file
      # iterate over all entries (need 
    
    with open(self.filename, 'a+') as csvfile:
      writer = csv.writer(csvfile, delimiter=',',
                          quotechar='"', quoting=csv.QUOTE_MINIMAL)
      writer.writerow([util.date2string(start_date),
                       util.date2string(stop_date),
                       message])

    return True, ''


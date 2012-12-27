#!/usr/bin/env python

# Extract the iOS app's Eternity timer's csv's from a local mailbox in
# mbox format.  Use fetchmail to get the mail locally.

import os
import sys
import util
import mailbox
import csv
import StringIO

from datetime import datetime
from datetime import timedelta

class Importer(object):
  def __init__(self, timesheet_log):
    self.timesheet_log = timesheet_log

  def eternity(self, mbox_file):
    print 'importing app\'s csv timesheets from mailbox'
    print 'mailbox: ' + mbox_file
    print ''

    # open and lock the mailbox
    mbox = mailbox.mbox(mbox_file, create=False)
    mbox.lock()

    imported = 0
    try:
        for key, msg in mbox.iteritems():
            if msg['subject'].startswith('Eternity'):
                for part in msg.walk():  # assume its multipart by its subject
                    if part.get_content_type() == 'text/csv' and '_logs_' in part.get_filename():
                        sio = StringIO.StringIO(part.get_payload())
                        reader = csv.reader(sio, delimiter=',')
                        for f in reader:
                            if not f[0] == 'day':
                                if len(f) >= 8:
                                    print "importing " + str(f)
                                    startdate = util.string2date(f[0] + ' ' + f[1])
                                    d = f[3].split(':')
                                    hours = int(d[0])
                                    minutes = int(d[1])
                                    seconds = int(d[2])
                                    delta = timedelta(hours=hours, minutes=minutes, seconds=seconds)
                                    enddate = startdate + delta
                                    tag = f[7]
                                    note = f[6]
                                    message = ''
                                    if len(tag) > 0:
                                        message = tag
                                        if len(note) > 0:
                                          message += ', '
                                    message = message + note
                                    added, msg = self.timesheet_log.AddEntry(startdate, enddate, message)
                                    if added:
                                        print "added entry: " + util.date2string(startdate), util.date2string(enddate), message
                                        print ""
                                        imported += 1
                                    else:
                                        print msg
             # mbox.remove(key)                        
    finally:
        mbox.flush()
        mbox.close()
        mbox.unlock()

    if imported == 0:
        print "nothing to import"
    else:
        print "imported " + str(imported) + " entries"

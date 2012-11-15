#!/usr/bin/env python

# Extract the iOS app's Eternity timer's csv's from a local mailbox in
# mbox format.  Use fetchmail to get the mail locally.

import os
import sys
import util
import mailbox
import csv
import StringIO

from TimesheetLog import TimesheetLog
from TimesheetState import TimesheetState

from datetime import datetime
from datetime import timedelta

TIMESHEET = '~/.timesheet'
MBOX = '~/.mail/incoming'

def main(argv):
    print "The Eternity app's CSV timesheet importer"
    print "mailbox: " + MBOX
    print "timesheet: " + TIMESHEET
    print ""

    # ready the timesheet
    timesheet_log = TimesheetLog(os.path.expanduser(TIMESHEET))

    # open and lock the mailbox
    mbox = mailbox.mbox(MBOX, create=False)
    mbox.lock()

    imported = 0
    try:
        for key, msg in mbox.iteritems():
            if msg['subject'].startswith('Eternity weekly report for'):
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
                                    if len(tag) > 0:
                                        message = tag + ':'
                                    else:
                                        message = ''
                                    message = message + note
                                    timesheet_log.AddEntry(startdate, enddate, message)
                                    print "added entry: " + util.date2string(startdate), util.date2string(enddate), message
                                    print ""
                                    imported += 1
            mbox.remove(key)                        
    finally:
        mbox.flush()
        mbox.close()
        mbox.unlock()

    if imported == 0:
        print "nothing to import"
    else:
        print "imported " + str(imported) + " entries"
    
if __name__=='__main__':
    main(sys.argv)

#!/usr/bin/env python

import os
import sys
import ConfigParser
from datetime import datetime
from datetime import timedelta

import lib.util as util
from lib.TimesheetCSV import TimesheetCSV
from lib.TimesheetState import TimesheetState
from lib.Importer import Importer

def print_usage(prog):
  print 'Welcome to timesheet!'
  print ''
  print 'TIMER USAGE'
  print '  ' + prog + ' start [-m msg] [backdate]\tstart timing'
  print '  ' + prog + ' stop [-m msg] [backdate]\tstop timing'
  print '  ' + prog + ' message msg\t\t\tdescribe this period'
  print '  ' + prog + ' cancel\t\t\tcancel this period'
  print ''
  print '  [backdate] takes natural expressions like "3 hours ago" using GNU date'
  print '  [msg] is a string describing the time period'
  print ''
  print 'REPORTING'
  print '  ' + prog + ' status\t\t\tcurrent period\'s time'
  print '  ' + prog + ' week [backdate]\t\tbreakdown of this week by day'
  print '  ' + prog + ' day [backdate]\t\tbreakdown of today\'s work'
  print '  ' + prog + ' break\t\t\ttime since last period'
  print '  ' + prog + ' done\t\t\thours done this week'
  print '  ' + prog + ' left\t\t\thours left this week'
  print '  ' + prog + ' since [backdate]\t\twork done since a given date'
  print ''
  print '  [backdate] takes natural expressions like "3 hours ago" using GNU date'
  print ''
  print 'EXAMPLES OF BACKDATING'
  print '  ' + prog + ' start 5 minutes ago'
  print '  ' + prog + ' stop yesterday 3:25pm'
  print '  ' + prog + ' week 2 weeks ago'
  print '  ' + prog + ' day yesterday'
  print '  ' + prog + ' since 3 days ago'

def create_config(config_path):
  config = ConfigParser.ConfigParser()
  config.add_section('Parameters')
  config.set('Parameters', 'week_start', 'Monday 9:00am')
  config.set('Parameters', 'week_hours', '40')

  config.add_section('Storage')
  config.set('Storage', 'timesheet', '~/.timesheet')
  config.set('Storage', 'state', '~/.timesheet.state')

  config.add_section('Importing')
  config.set('Importing', 'mbox', '~/.mail/incoming')

  with open(config_path, 'wb+') as configfile:
    config.write(configfile)
  print 'I have created the configuration file ' + config_path + '.\n'

def main(argv):
  prog = os.path.basename(argv[0])  # program name as called
  argc = 1  # i like C
  
  # get or create config file
  config_path = os.path.expanduser('~/.timesheetrc')
  if len(argv[argc:]) >= 2 and argv[argc] == '-c':
    argc = argc + 1
    config_path = argv[argc]
    argc = argc + 1

  week_start = None
  week_hours = None
  timesheet_logfile = None
  timesheet_statefile = None
  mbox_path = None
  if not os.path.exists(config_path):
    create_config(config_path)
  try_config = 0
  success = False
  while try_config < 3 and not success:
    try_config += 1
    config = ConfigParser.ConfigParser()
    config.read(config_path)

    try:
      week_start = config.get('Parameters', 'week_start')
      week_hours = config.get('Parameters', 'week_hours')
      timesheet_logfile = config.get('Storage', 'timesheet')
      timesheet_statefile = config.get('Storage', 'state')
      mbox_path = config.get('Importing', 'mbox')
      success = True
    except ConfigParser.NoOptionError, err:
      print 'There is an option missing in the configuration file.'
      create_config(config_path)
    except ConfigParser.NoSectionError, err:
      print 'There is an option missing in the configuration file.'
      create_config(config_path)

  # get the timesheet command and its arguments
  if argc >= len(argv):
    print_usage(prog)
    return

  command = argv[argc]
  argc += 1
  args = argv[argc:]

  # get the "-m message" parameter for the start and stop commands.
  command_message = ''
  if len(args) > 0 and command in ['start', 'stop'] and args[0] == '-m':
    if len(args) == 1:
      print '-m must take a message as a parameter'
      return
    else:
      command_message = args[1]
      args = args[2:]

  argument = ' '.join(args)

  # get the timesheet log and state files
  timesheet_log = TimesheetCSV(os.path.expanduser(timesheet_logfile))
  timesheet_state = TimesheetState(os.path.expanduser(timesheet_statefile))

  # process commands
  if command == 'start':
    ret = timesheet_state.Get()

    if argument != '':
      # backdate the timer
      starttime = util.interpretdate(argument)
      if starttime == None:
        print 'invalid date. try again.'
        return
    else:
      starttime = datetime.today()

    if ret:
      # stop the old timer first
      yn = raw_input('the timer is already going.  start a new one? [Y/n] ')
      if yn.lower() == 'n':
        print 'aborted.  did not cancel the timer'
        return
      print 'stopping old timer'
      stoptime = starttime;
      logged_time, logged_message = ret
      while logged_message == '':
        logged_message = raw_input('please enter a message: ')
      added, msg = timesheet_log.AddEntry(logged_time, stoptime, logged_message)
      if not added:
        print msg
        exit(1)
      timesheet_state.Clear()
      print util.date2string(logged_time), util.date2string(stoptime),
      logged_message
      print '\n', util.delta2string(stoptime - logged_time), '\n'

    timesheet_state.Set(starttime, command_message)
    print 'started timing'
    if command_message != '':
      print 'message set'

  elif command == 'stop':
    ret = timesheet_state.Get()
    if not ret:
      print 'cannot stop what has not been started.'
      return

    if argument != '':
      # backdate the timer
      stoptime = util.interpretdate(argument)
      if stoptime == None:
        print 'invalid date. try again.'
        return
    else:
      stoptime = datetime.today();

    logged_time, logged_message = ret
    entry_message = ''
    if command_message != '':
      entry_message = command_message
    else:
      while logged_message == '':
        logged_message = raw_input('please enter a message: ')
      entry_message = logged_message
    added, msg = timesheet_log.AddEntry(logged_time, stoptime, entry_message)
    if not added:
      print msg
      exit(1)
    timesheet_state.Clear()
    print util.date2string(logged_time), util.date2string(stoptime),
    entry_message
    print '\n', util.delta2string(stoptime - logged_time)

  elif command == 'message':
    ret = timesheet_state.Get()
    if not ret:
      print 'the timer is not going'
      return

    logged_time, logged_message = ret
    if logged_message != '':
      print 'the message is already set'
      yn = raw_input('do you want to change the message? [y/N] ')
      if yn.lower() != 'y':
        print 'okay.  leaving the existing message alone'
        return
      logged_message = ''
    if argument != '':
      entry_message = argument
    else:
      while logged_message == '':
        logged_message = raw_input('please enter a message: ')
      entry_message = logged_message
    timesheet_state.Set(logged_time, entry_message)
    print 'message set'

  elif command == 'cancel':
    ret = timesheet_state.Get()
    if not ret:
      print 'cannot stop what has not been started.'
      return

    logged_time, logged_message = ret
    print 'started', util.date2string(logged_time)
    
    yn = raw_input('are you sure you want to cancel the entry? [y/N] ')
    if yn.lower() == 'y':
      timesheet_state.Clear()
      print 'cancelled timer'
    else:
      'aborted.  did not cancel the timer'

  elif command == 'status':
    ret = timesheet_state.Get()
    if not ret:
      print 'the timer is not going'
      return

    logged_time, logged_message = ret
    stop_time = datetime.today();
    print util.delta2string(stop_time - logged_time), logged_message
    print 'started at', util.date2string(logged_time)

  elif command == 'import':
    importer = Importer(timesheet_log)
    importer.eternity(mbox_path)

  elif command == 'week':
    # set the range sum up
    period_start = util.interpretdate(week_start) - timedelta(days=6)
    print period_start
    period_stop = datetime.today()

    # sum the range
    string_start = util.date2string(period_start)
    string_stop = util.date2string(period_stop)
    dur = timedelta(0)
    last_day = None
    for row in [ x for x in timesheet_log.entries if x[0] <= string_stop and x[1] >= string_start ]:
      entry_start = util.string2date(row[0])
      entry_stop = util.string2date(row[1])
      entry_dur = min(entry_stop, period_stop) - max(entry_start, period_start)
      entry_message = row[2]
      entry_day = row[0].split(' ')[0]
      if entry_day != last_day:
        if last_day != None:
          print ' ' * len(entry_day) + ' Total ' + util.delta2string(day_dur, decimal=True, abbr=True)
          print ''
        display_day = entry_day
        day_dur = timedelta(0)
      else:
        display_day = ' ' * len(entry_day)
      last_day = entry_day
      if len(entry_message) == 0:
        entry_message = '-'
      dur += entry_dur
      day_dur += entry_dur
      print display_day, util.delta2string(entry_dur, show_days=True, decimal=True, abbr=True) + '\t' + entry_message
    if last_day != None:
      print ' ' * len(entry_day) + ' Total ' + util.delta2string(day_dur, decimal=True, abbr=True)
      print ''

    # add the current timer if applicable
    ret = timesheet_state.Get()
    if ret:
      logged_time, logged_message = ret
      dur += period_stop - max(logged_time, period_start)

    print util.delta2string(dur)

  elif command == 'day':
    print 'coming soon!'

  elif command == 'break':
    print 'coming soon!'

  elif command == 'done':
    print 'coming soon!'

  elif command == 'left':
    print 'coming soon!'

  elif command == 'since':
    print 'coming soon!'

  else:
    print 'invalid command'
    return


if __name__=='__main__':
  main(sys.argv)

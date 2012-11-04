#!/usr/bin/env python

from datetime import datetime
from datetime import timedelta
import subprocess

# Converts string to formatted date by calling out to the unix date
# utility.  Returns None if conversion failed.
def string2date(string):
  popen = subprocess.Popen('date -d "%s" +%%Y/%%m/%%d\ %%H:%%M:%%S' % string,
                           shell=True,
                           stdout=subprocess.PIPE)
  stdout_, stderr_ = popen.communicate()
  if popen.returncode != 0:
    return None
  else:
    return datetime.strptime(stdout_.strip(), '%Y/%m/%d %H:%M:%S')

def date2string(date):
  assert isinstance(date, datetime)
  return date.strftime('%Y/%m/%d %H:%M:%S')

def delta2string(delta):
  assert isinstance(delta, timedelta)
  days = delta.days
  seconds = delta.seconds
  minutes = seconds / 60
  seconds = seconds % 60
  hours = minutes / 60
  minutes = minutes % 60
  pl = ''
  if days > 0:
    if days > 1 or hours > 0 or minutes > 0 or seconds > 0:
      pl = 's'
    return "%d:%02d:%02d:%02d" % (days, hours, minutes, seconds) + " day" + pl
  elif hours > 0:
    if hours > 1 or minutes > 0 or seconds > 0:
      pl = 's'
    return "%d:%02d:%02d" % (hours, minutes, seconds) + " hour" + pl
  elif minutes > 0:
    if minutes > 1 or seconds > 0:
      pl = 's'
    return "%d:%02d" % (minutes, seconds) + " minute" + pl
  elif seconds > 0:
    if seconds > 1:
      pl = 's'
    return "%d" % (seconds) + " second" + pl
  else:
    return None

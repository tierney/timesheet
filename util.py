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

def delta2string(delta, show_days=False, decimal=False, abbr=False):
  assert isinstance(delta, timedelta)
  days = delta.days
  seconds = delta.seconds
  minutes = seconds / 60
  seconds = seconds % 60
  hours = minutes / 60
  minutes = minutes % 60
  if not show_days:
    hours += 24 * days
    days = 0
  pl = ''
  if days > 0:
    if not decimal:
      number_str = "%d:%02d:%02d:%02d" % (days, hours, minutes, seconds)
    else:
      number_str = '%.1f' % (days + float(hours) / 24)
    if abbr:
      units = ' d'
    else:
      if days > 1 or hours > 0 or minutes > 0 or seconds > 0:
        pl = 's'
      units = ' day' + pl
    return number_str + units
  elif hours > 0:
    if not decimal:
      number_str = "%d:%02d:%02d" % (hours, minutes, seconds)
    else:
      number_str = '%.1f' % (hours + float(minutes) / 60)
    if abbr:
      units = ' hr'
    else:
      if hours > 1 or minutes > 0 or seconds > 0:
        pl = 's'
      units = ' hour' + pl
    return number_str + units
  elif minutes > 0:
    if not decimal:
      number_str = "%d:%02d" % (minutes, seconds)
    else:
      number_str = "%.1f" % (minutes + float(seconds) / 60)
    if abbr:
      units = ' min'
    else:
      if minutes > 1 or seconds > 0:
        pl = 's'
      units = ' minute' + pl
    return number_str + units
  elif seconds > 0:
    number_str = "%d" % (seconds)
    if abbr:
      units = ' sec'
    else:
      if seconds > 1:
        pl = 's'
      units = ' second' + pl
    return number_str + units
  else:
    return None

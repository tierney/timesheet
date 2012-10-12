#!/usr/bin/env python

from datetime import datetime
from datetime import timedelta
import subprocess

def get_date_from_string(string):
  popen = subprocess.Popen('date -d "%s" +%%Y/%%m/%%d\ %%H:%%M:%%S' % string,
                           shell=True,
                           stdout=subprocess.PIPE)
  stdout_, stderr_ = popen.communicate()
  return datetime.strptime(stdout_.strip(), '%Y/%m/%d %H:%M:%S')

def get_string_from_date(date):
  assert isinstance(date, datetime)
  return date.strftime('%Y/%m/%d %H:%M:%S')

def get_string_from_timedelta(delta):
  assert isinstance(delta, timedelta)
  days = delta.days
  seconds = delta.seconds
  minutes = seconds / 60
  seconds = seconds - minutes * 60
  hours = minutes / 60
  minutes = minutes - hours * 60
  return days, ":", hours, ":", minutes, ":", seconds, "|||", delta
  
  

    

#!/usr/bin/env python

from datetime import datetime
import subprocess

def get_current_time():
  dt = datetime.utcnow()
  return dt.strftime('%Y/%m/%d %H:%M:%S')

def get_current_date():
  return datetime.utcnow()

def get_date_from_string(string):
  popen = subprocess.Popen('date -d "%s" +%%Y/%%m/%%d\ %%H:%%M:%%S' % string,
                           shell=True,
                           stdout=subprocess.PIPE)
  stdout_, stderr_ = popen.communicate()
  return datetime.strptime(stdout_.strip(), '%Y/%m/%d %H:%M:%S')

def get_string_from_date(date):
  assert isinstance(date, datetime)
  return date.strftime('%Y/%m/%d %H:%M:%S')

Setup
=====

Open t in an editor and tweek the variables to set the location of the
timesheet and define your workweek.

Copy or symlink t to be in your PATH for easy execution.


Tutorial
========

Start timing

>  t start

Stop timing and it will ask you for a note about the work

>  t stop

Start a new timer even when the timer is running

>  t start

Add a message anytime during the time period

>  t message

Check current timer

>  t status

See how many much you are working, e.g.,

>  t today
>
>  t yesterday
>
>  t week
>
>  t since 3 days ago

See how many hours you've done this week and how much is left

>  t done
>
>  t left

See how much time you've been on break

>  t break

Design Goals
============

1. <b>Painless timing</b>

 > This timer stays out of your way.  Just type "t start" and "t stop"
 > to use the timer.  This is the most you need to time yourself.  No
 > need to think about writing specific times, adding notes about the
 > work before you even start, or selecting different timesheets.  Just
 > type "start" and begin working. Just timing yourself.  Adding notes is
 > optional and encouraged.  When you stop, you are asked for a message
 > to put with your time spent. Start a new timer at any point.  Any
 > existing timer will automatically be stopped after warning you.

2. <b>Forgiving</b>

 > If you are like me, you may not know exactly what you'll work on
 > before you start.  Add a note anytime with "t message".  If you forget
 > to add a note, you'll be asked when stopping the timer.  If you've
 > forgotten to start timing, don't worry use "t backstart 15 minutes
 > ago" to backdate the timer.  If you forgot to stop timing, type "t
 > stop 5 minutes ago".  If you really didn't do any work, cancel with "t
 > cancel".


3. <b>Easy time analysis</b>

 > Rich feedback on your work done.  Hours today, yesterday, last week.
 > Time on break.  How much time you've put in and how much time you have
 > left to do.


Conventions
===========

* For the analysis, there is a notion of a work week and a work day.
You specify the starting day of the week and how many working hours
are in it.


Storage format
==============

* The timesheet is stored in plain text with one entry per line
containing the start date/time, stop date/time, and a description.
This makes it easy to write your own analysis tools and even read and
edit the sheet manually.


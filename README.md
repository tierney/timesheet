timesheet
=========

Start timing with

>  t start

Stop timing with

>  t stop

You will be prompted for a message describing the time period.  You can also give a message any time during timing with

>  t message

Check the state of the current timer with

>  t status

See a break-down of the week with

> t week

If you forget to start or stop timing, you can backdate 



-------------
Configuration
-------------


------------
Dependencies
------------


-----------------------
Using the Timesheet CSV
-----------------------

The timesheet is stored in a simple CSV format.



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


------------
Design Goals
------------

Painless

This timer stays out of your way.  Just type "t start" and "t stop" to
use the timer.  This is the most you need to time yourself.  No need
to think about writing specific times, adding notes about the work
before you even start, or selecting different timesheets.  Just type
"start" and begin working. Just timing yourself.  Adding notes is
optional and encouraged.  When you stop, you are asked for a message
to put with your time spent. Start a new timer at any point.  Any
existing timer will automatically be stopped after warning you.

Forgiving

If you are like me, you may not know exactly what you'll work on
before you start.  Add a note anytime with "t message".  If you forget
to add a note, you'll be asked when stopping the timer.  If you've
forgotten to start timing, don't worry use "t backstart 15 minutes
ago" to backdate the timer.  If you forgot to stop timing, type "t
stop 5 minutes ago".  If you really didn't do any work, cancel with "t
cancel".

Easy

Rich feedback on your work done.  Hours today, yesterday, last week.
Time on break.  How much time you've put in and how much time you have
left to do.

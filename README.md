timesheet
=========

Basic Usage
-----------

Start timing with `t start`.  Stop with `t stop`.
Set a message anytime with `t message` or when stopping the timer. 
Cancel timing with `t cancel`.
Check on the current timer with `t status` and get a break-down of the week with `t week`.
If you forget to start or stop the timer, backdate like this: `t start 10 minutes ago`.  We use GNU's `date` to
parse [time expressions](http://www.gnu.org/software/coreutils/manual/coreutils.html#Date-input-formats).

Advanced Usage
--------------

See how long you've been on break with `t break`.  See how many hours you've worked this week with `t done`
and how much time is left in the week with `t left`.  `timesheet` defaults to a 40 hour work-week.
See the customization section below to change this.

Analyze your work in detail:
* `t today`
* `t yesterday`
* `t since 3 days ago`
* `t week 2 weeks ago`

Customization
-------------

* You can change the following in `~/.timesheetrc`
  * Work week starting day
  * Hours per week
* The timesheet is a CSV file at `~/.timesheet`

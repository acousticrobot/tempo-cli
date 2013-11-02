# tempo

A command Line interface for time tracking.  Record projects to track time to, and report time based time periods and also by project.

## running in development

You need to use `bundle exec bin/tempo` to run in development

### testing

rakes default behavior is to run unit tests and cucumber features

run `bundle exec rake test` to run unit tests only

if tests fail, you can cleanup the testing directories with `bundle exec rake clean`

### other command line time tracking apps:

This is a very opinionated time tracking app, you may find others that suit your working method better:

A utility that saves to separate time sheets for each project, using SQLite:

timetrap[https://github.com/samg/timetrap]

Another one worth checking out:

t_time_tracker[https://github.com/christiangenco/t_time_tracker]
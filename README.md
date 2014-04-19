# tempo

A command line interface for time tracking by project.

## Installation

    gem install tempo-cli   

### binary

Tempo cli runs with the binary `tempo`, but you can alias a shorter binary for your convenience, for example "t":

    echo "alias t='tempo'" >> ~/.bash_profile

## Methodology

### Track time by Project

Tempo tracks time against projects.  Projects can be nested, and tagged, and each time entry can have an additional description.  Time reports are produced by day.  

Future enhancements will include reports by project and time totals by day or by project.

### Records

All records are produced in YAML files, at the root user directory.  These reports can be edited by hand, but keep in mind that any invalid data could cause problems when it is read back into the app. Make sure time formatting is valid and that they don't overlap, and that all ids are unique per page. 

Each day's time records are designed to work independently. When adding or updating time records, only the records for the days in question are loaded into the app. The most recent day's records will also always be read in, to assure no running records are created earlier than existing records. 

### Features

#### command line assistance

run `tempo help` for a list of commands

run `tempo [command] --help` for help on any command

#### syntax

All commands and command options can be abbreviated to the first letter:

##### example

    # these two commands are the same:
    $ tempo project --list
    $ tempo p -l

#### fuzzy matching

Commands that manage the projects will use fuzzy matching for the project name. This means if you have a project called "put on my big boy pants" you will be able to checkout this project by running `tempo checkout pants`. If you have a situation where fuzzy matching causes errors because it matches with more than one project, you can always use the --exact flag, and pass in an exact match.

#### Ids

Every project and time record has an id which can also be used to match against. Running commands with the global --id flag will include ids in the output.
Time record ids are on a per-day basis, and begin again with an id of 1 on the next day.

## Commands

### project
#### Manage the Projects that timed tasks are assigned to

    tempo [global options] p [command options] "name of the project"

##### command options

    --add                  - Add a Project
    --delete=title         - Delete a Project
    --exact                - Exact Match
    --id                   - List by or perform command by project Id
    --list                 - List Projects
    --tag=tagword          - Tag a Project
    --untag=tagword        - Untag a Project


Manage the Projects that timed tasks are assigned to. By default, lists the current project, or with --list tag, lists all projects. The active project will be marked by an asterisk.

If supplied with arguments and no command options, a new project will be added.

##### examples:

    # list current project
    $ tempo project

    # list all projects
    $ tempo project --list

    # adding a new project titled 'star gazing'
    $ tempo project star gazing

    # adding a new project with a tag
    $ tempo project --add star gazing --tag cellar

    # untagging and tagging an existing project
    $ tempo project star gazing --untag cellar --tag stellar 

### checkout
#### Checkout a project to track time against

    tempo [global options] checkout [command options] "name of the project"

##### command options

    --add=title     - Add and Checkout a new project
    --exact                 - use an exact match for project title
    --id                    - checkout by project id

Only one project is active at a time, and this project will be assigned to all new time records.  You can checkout existing projects, or use this command to create a new active project

#### examples:

    # checking out an existing project titled 'star gazing' 
    $ tempo checkout star gazing

    # adding and checking out a new project titled 'star gazing' 
    $ tempo checkout --add star gazing 

### arrange
#### Arrange project hierarchy

    tempo [global options] arrange [command options] [parent project] : child project

##### command options

    --exact    - use an exact match for project title
    --id       - checkout by project id

Arrange projects into a parent/child hierarchy

New projects are added as root projects by default. Use arrange to arrange existing projects as child or root projects. If no parent project is supplied (to the left of the semicolon) the project will become a root project.

##### examples:

    # Arrange an existing project as a root project
    $ tempo arrange : aquascaping

    # Arrange an existing project as a child project
    # (aquascaping will be the parent of coral pruning)
    $ tempo arrange aquascaping : coral pruning 

### start
#### Start a time entry

    tempo [global options] start [command options] description

##### command options
    --at=time
    --end=time

    Starts a new time entry, and closes out any running time entries.

    You can also add a description of the time entry.

    To start a time entry at a time other than the current, pass it in as an argument to the --at flag. This will accept a number of human readable formats, multiple word time formats should be enclosed in quotes

##### examples:

    # start a new time record at the current time with no description
    $ tempo start

    # start and end a previous time record with a description
    $ tempo start learning how to do the Hustle --at 'yesterday at 8:00 in the evening' --end 'yesterday at 11:59pm'

### end
#### End a time entry

    tempo [global options] end [command options] time out, defaults to now

##### command options
    --at=time

    Closes out any running time entries.

    You can optionally add a description of the time entry, which will overwrite the current description.

    To end a time entry at a time other than the current, pass it in as an argument to the --at flag. This will accept a number of human readable formats, multiple word time formats should be enclosed in quotes.

##### examples:

    # creating an entry at 4:55pm, then ending it 5 minutes later and changing the description
    $ tempo start --at 16:55 practicing the human torch trick
    $ tempo end --at 'today at 5:00pm' learning how to stop, drop, and roll

### update
#### Update a time entry

    tempo [global options] update [command options] [description]

##### command options

    --delete            - Delete a Time Entry
    --end=time          - Update the End Time
    --id=number         - Select by Id
    --on=date           - Select On Date
    --project           - Update to the active project
    --start=time        - Update the Start Time

update the project, start time, or end time for a time entry.

Defaults to the current time entry, or most recently completed time entry if none are running. Optionally, you can supply an id for a time entry on the current day, or a day and id to update previous time entries. 

The description, if passed in, will be used to replace the existing description. You can also change the start or end time, or delete the entire time entry.

##### examples:

    # update description for the last time entry
    $ tempo update practicing banjo

    # update the description for yesterday's entry with id of 2
    $ tempo update --id 2 --on 'yesterday' practicing banjo

    # update the start time for the last time entry
    $ tempo update --start 7:00

    # update the end time and description
    $ tempo update --end '8:00pm' practicing banjo

    # delete the last time entry
    $ tempo update --delete 

    # update the description, start, and end time for a previous day's entry
    $ tempo update --on 1/17/14 --start "1/17/14 8am" --end "1/17/14 10am" practicing banjo

### report
#### Report time entries

    tempo [global options] report [command options] [day]

##### command options
 
    --from=time - begin time records on this date
    --to=time   - end time records on this date

    Reports time entries for a day or a period of days. By default, lists the last recorded day's entries. To list a different day, supply a day as the args. To list a series of records, include a --from and --to value

##### examples:

    # report current day's entries
    $ tempo report

    # report a different day
    $ tempo report 11/24/14

    # report the past week
    $ tempo report -f 'a week ago'

    # report a period of days
    $ tempo report -f 'last monday' -t 'last friday' 

## Assumptions and Limitations

Before you begin using tempo, you must have at least one project. Projects can be tagged, and organized as sub-projects.  See project in the commands section below, for more information. To view your projects file, look at  ~/tempo/tempo_projects.yaml

### Time periods

All records are rounded to the nearest minute.  Time records are organized by day, and close out on the day they were started.

Tempo uses [Chronic](https://github.com/mojombo/chronic) to parse time formats, which adds a lot of convenience functions such as "yesterday at 5:00".
Chronic does have some limitations and inconsistencies as well, please see the [https://github.com/mojombo/chronic/issues](list of known issues) if you find problems with time parsing.

### No overlapping projects

It is assumed only one time record can exist for any given time. Overlapping time entries will result in an error.  

### Only one running project

One entry can be running at any given time, and it must be the most recent entry.  Older entries will be closed out when a new one is started, and if the entry is running on a previous day, it will be closed out on the last minute of that day.

## Tempo Development

Project development is on-going and in my spare time.  Any error reporting, pull requests, and suggestions welcome. 

### Planned features

#### Files

  * add a config file with global options.
  * add an option to change the location of the tempo file structure (for syncing with Dropbox, for instance).

#### Projects

  * add an archive capability, which hides inactive projects from project lists. This can be handled with an tag keyword 'archived'.
  * allow adding a new project and listing all projects in the same command.

#### Start

  * Allow start to use a project other than the current one.

#### Resume

  * Add a command to start the last time entry running again.
  * Add a command to start a new time entry with the same details as a previous one.

#### Time format enhancements

  * Updating time record start or end time using `--on` should not need the full date repeated for `--start` or `--end`.
  * invalid times should be retried with the current (or most logical) date. Example: if '9:00' doesn't work, try 'today at 9:00'

#### Reporting

  * Recording output to file
  * Reporting by project
  * Composite view records (grouped time records by day or project), to allow nested list reporting
  * Total hours by project or day
  * Alternative formats: JSON, HTML

### Running in development

You need to use `bundle exec bin/tempo` to run in development

### Testing

rakes default behavior is to run unit tests and all cucumber features

#### run unit tests only
run `bundle exec rake test` to run unit tests only

#### run only some cucumber features

add @focus before specific features and run `bundle exec rake features:focus`

#### cleanup

Testing creates a test directory at ~/testing/

You can cleanup the testing directories with `bundle exec rake clean`

### Other command line time tracking apps:

This is a very opinionated time tracking app, you may find others that suit your working method better:

If you would prefer to keep your data in a database, or run independant time sheets by project, here is a utility that uses SQLite:

[timetrap](https://github.com/samg/timetrap)

Another one worth checking out for a lightweight time tracker:

[t_time_tracker](https://github.com/christiangenco/t_time_tracker)

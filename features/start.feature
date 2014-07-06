Feature: Start Command starts a new time record
  The start command starts a time record referencing the current project
  It records projects in log files by day. Only one time entry will be
  running at any given time; new entries close out the last running time record.

  Scenario: Attempting to add time before any projects exist
    Given a clean installation
    When I run `tempo start`
    Then the stderr should contain "no projects exist"
    And the project file should contain "#" at line 1

  Scenario: Adding a time record for the current time
    Given an existing project file
    When I run `tempo start`
    Then the stdout should contain "time record started"

  Scenario: Adding a time record for the current time with a description
    Given an existing project file
    When I run `tempo start my new project`
    Then the stdout should contain "time record started"
    And the stdout should contain "horticulture: my new project"

  Scenario: Attempting to add an invalid start time
    Given an existing project file
    When I run `tempo start --at "invalid time"`
    Then the stderr should contain "no valid timeframe matches the request: invalid time"

  Scenario: Adding a time record for a specific time
    Given an existing project file
    When I run `tempo start --at "15:00 today"`
    Then the stdout should contain "time record started"
    And the output should match /15:00 - \d{2}:\d{2}\*/

  Scenario: Adding a time record with an end time
    Given an existing project file
    When I run `tempo start --end "1 hour from now"`
    Then the stdout should contain "time record started"
    And the output should match /\d{2}:\d{2} - \d{2}:\d{2}/

@pending
  Scenario: Adding a time record with tags
    Given an existing project file

  Scenario: Attempting to add time that collides with an existing record
    Given an existing project file
    When I run `tempo start --at "1-1-2014 7:00"`
    And I run `tempo end --at "1-1-2014 10:00"`
    And I run `tempo start --at "1-1-2014 8:00"`
    Then the stderr should contain "error: time <08:00> conflicts with existing record: 07:00 - 10:00"

  Scenario: Adding a time record and closing out the last one
    Given an existing project file
    When I run `tempo start --at "1-1-2014 7:00"`
    And I run `tempo start --at "1-1-2014 8:00"`
    Then the stdout should contain "time record started"
    And the time record 20140101 should contain ":end_time: 2014-01-01 08:00:00" at line 5

  Scenario: Adding a time record and closing out the previous day
    Given an existing project file
    When I run `tempo start --at "1-1-2014 7:00"`
    And I run `tempo start --at "1-3-2014 10:00"`
    Then the stdout should contain "time record started"
    And the time record 20140101 should contain ":end_time: 2014-01-01 23:59" at line 5

  Scenario: Adding an earlier time record should immediately close out
    Given an existing project file
    When I run `tempo start --at "1-1-2014 10:00"`
    And I run `tempo start --at "1-1-2014 17:00"`
    And I run `tempo start --at "1-1-2014 6:00"`
    Then the stdout should contain "time record started"
    And the time record 20140101 should contain ":end_time: 2014-01-01 10:00" at line 5

  Scenario: Adding a future days time record should warn about complications
    Given an existing project file
    When I run `tempo start --at "1-1-2033 10:00"`
    Then the stdout should contain "WARNING"
    And the time record 20330101 should contain ":start_time: 2033-01-01 10:00" at line 4

  Scenario: Adding a record to a previous day works
    Given an existing project file
    When I run `tempo start --at "7/2/14 10:00" existing entry`
    And I run `tempo start --at "7/1/14 10:00" -e "7/1/2014 11:00" previous entry 1`
    And I run `tempo start --at "7/1/14 11:00" previous entry 2`
    Then the time record 20140701 should contain "previous entry 1" at line 3
    And the time record 20140701 should contain "11:00" at line 5
    And the time record 20140701 should contain "previous entry 2" at line 11
    And the time record 20140701 should contain "23:59" at line 13

  Scenario: Adding a record to a previous day works
    Given an existing project file
    When I run `tempo start --at "7/2/14 10:00" existing entry`
    And I run `tempo start --at "7/1/14 10:00" previous entry 1`
    And I run `tempo start --at "7/1/14 11:00" previous entry 2`
    Then the stderr should contain "error: time <11:00> conflicts with existing record"
    And the time record 20140701 should contain "previous entry 1" at line 3
    And the time record 20140701 should contain "23:59" at line 5

  Scenario: Adding a record to a future day works
    Given an existing project file
    When I run `tempo start --at "7/2/33 10:00" existing entry`
    And I run `tempo start --at "7/1/33 10:00" -e "7/1/2033 11:00" previous entry 1`
    And I run `tempo start --at "7/1/33 11:00" previous entry 2`
    Then the time record 20330701 should contain "previous entry 1" at line 3
    And the time record 20330701 should contain "11:00" at line 5
    And the time record 20330701 should contain "previous entry 2" at line 11
    And the time record 20330701 should contain "23:59" at line 13

  Scenario: Resuming the last time record
    Given an existing project file
    When I run `tempo start --at "1-1-2014 10:00" tweezing the cactus`
    And I run `tempo end --at "1-1-2014 12:00"`
    And I successfully run `tempo start --resume --at "1-1-2014 13:00"`
    Then the stdout should contain "time record started"
    And the time record 20140101 should contain ":description: tweezing the cactus" at line 11

  Scenario: Resuming the last time record with a different project checked out ignores current project
    Given an existing project file
    When I run `tempo start --at "1-1-2014 10:00" tweezing the cactus`
    And I run `tempo end --at "1-1-2014 12:00"`
    And I run `tempo checkout basement mushrooms`
    And I successfully run `tempo start --resume --at "1-1-2014 13:00"`
    Then the stdout should contain "time record started"
    And the time record 20140101 should contain ":project_title: horticulture" at line 10

  Scenario: Attempting to resume the last project when one is running
    Given an existing project file
    When I run `tempo start --at "1-1-2014 10:00"`
    And I run `tempo start --resume`
    Then the stderr should contain "error: cannot resume last time record when it is still running"

  Scenario: Adding an earlier day time record should immediately close out
    Given an existing project file
    When I run `tempo start --at "1-5-2014 7:00"`
    And I run `tempo start --at "1-1-2014 7:00"`
    Then the stdout should contain "time record started"
    And the time record 20140101 should contain ":end_time: 2014-01-01 23:59" at line 5

@pending
  Scenario: Adding an evening time record should compensate for local time
    # need to mock entering time in the evening, 21:26:46 -0400
    # make sure --at "5:00" is recorded for the local day, not GMC



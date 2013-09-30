Feature: Start Command starts a new time record
  The start command starts a time record referencing the current project
  It records projects in log files by day

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
    And the stdout should contain "description: my new project"

  Scenario: Attempting to add an invalid start time
    Given an existing project file
    When I run `tempo start --at "invalid time"`
    Then the stderr should contain "no valid timeframe matches the request: invalid time"

  Scenario: Adding a time record for a specific time
    Given an existing project file
    When I run `tempo start --at "15:00 today"`
    Then the stdout should contain "time record started"
    And the output should match /start time: \d{4}-\d{2}-\d{2} 15:00:00/

  Scenario: Adding a time record with an end time
    Given an existing project file
    When I run `tempo start --end "15:00 today"`
    Then the stdout should contain "time record started"
    And the output should match /end time: \d{4}-\d{2}-\d{2} 15:00:00/

  Scenario: Adding a time record with tags
    Given an existing project file

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
    When I run `tempo start --at "1-5-2014 7:00"`
    And I run `tempo start --at "1-1-2014 7:00"`
    Then the stdout should contain "time record started"
    And the time record 20140101 should contain ":end_time: 2014-01-01 23:59" at line 5




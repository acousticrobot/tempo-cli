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

  Scenario: Attempting to add an invalid start time
    Given an existing project file
    When I run `tempo start invalid time`
    Then the stderr should contain "no valid timeframe matches the request: invalid time"

  Scenario: Adding a time record for a specific time
    Given an existing project file

  Scenario: Adding a time record with an end time
    Given an existing project file

  Scenario: Adding a time record with a description
    Given an existing project file

  Scenario: Adding a time record with tags
    Given an existing project file

  Scenario: Adding a time record and closing out the last one
    Given an existing project file



Feature: End Command ends the current time record
  The end command ends the currenly running time record. It can be passed a value
  that will end the record at a given time

  Scenario: Attempting to add time before any projects exist
    Given a clean installation
    When I run `tempo end`
    Then the stderr should contain "no projects exist"
    And the project file should contain "#" at line 1

  Scenario: Attempting to end a time record when none are running
    Given an existing project file
    When I run `tempo end`
    Then the stderr should contain "no running time records exist"
@focus
  Scenario: Ending the current time record
    Given an existing project file
    When I run `tempo start`
    And I run `tempo end`
    Then the stdout should contain "time record ended"
    And the output should match /\d{2}:\d{2} - \d{2}:\d{2}[^\*]/

  Scenario: Ending the current time record and changing the description
    Given an existing project file
    When I run `tempo start old description`
    And I run `tempo end new description`
    Then the stdout should contain "time record ended"
    And the output should contain "new description"
    And the output should match /\d{2}:\d{2} - \d{2}:\d{2}[^\*]/

  Scenario: Attempting to add an invalid end time
    Given an existing project file
    When I run `tempo start`
    When I run `tempo end --at "invalid time"`
    Then the stderr should contain "no valid timeframe matches the request: invalid time"

  Scenario: Ending a time record for a specific time
    Given an existing project file
    When I run `tempo start --at "1-5-2014 7:00"`
    And I run `tempo end --at "1-5-2014 15:00"`
    Then the stdout should contain "time record ended"
    And the output should match /7:00 - 15:00/
@pending
  Scenario: Attempting to end after the beginning time
    Given an existing project file
    When I run `tempo start --at "1-5-2014 17:00"`
    And I run `tempo end --at "1-5-2014 6:00"`
    Then the stderr should contain "you cannot end a time record before the starting time"

@pending
  Scenario: Ending a time record with tags
    Given an existing project file
@pending
  Scenario: Ending a time record on a previous day
    Given an existing project file
    When I run `tempo start --at "1-1-2014 7:00"`
    And I run `tempo end --at "1-3-2014 10:00"`
    Then the stdout should contain "time record ended"
    And the time record 20140101 should contain ":end_time: 2014-01-01 23:59" at line 5
    And the time record 20140102 should contain ":end_time: 2014-01-01 23:59" at line 5
    And the time record 20140103 should contain ":end_time: 2014-01-01 10:00" at line 5





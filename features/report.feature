Feature: Report Command formats and outputs time records
  The report command echoes time records in an easy to view format.
@focus
  Scenario: Attempting to report time records before any projects exist
    Given a clean installation
    When I run `tempo report`
    Then the stderr should contain "no projects exist"
    And the project file should contain "#" at line 1
@focus
  Scenario: Attempting to report time records before any time records exist
    Given an existing project file
    When I run `tempo report`
    Then the stderr should contain "no time records exist"
@focus
  Scenario: Reporting the time entries on the current day
    Given an existing project file
    When I run `tempo start my new project`
    And I run `tempo end`
    And I run `tempo report`
    Then the output should match /\d{1-2}:\d{2} bonsai: /
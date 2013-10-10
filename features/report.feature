Feature: Report Command formats and outputs time records
  The report command echoes time records in an easy to view format.

  Scenario: Attempting to report time records before any projects exist
    Given a clean installation
    When I run `tempo report`
    Then the stderr should contain "no projects exist"
    And the project file should contain "#" at line 1

  Scenario: Attempting to report time records before any time records exist
    Given an existing project file
    When I run `tempo report`
    Then the stderr should contain "no time records exist"

  Scenario: Reporting the time entries on the current day
    Given an existing project file
    When I run `tempo start my new project`
    And I run `tempo end`
    And I run `tempo report`
    Then the output should match /\d{2}:\d{2} - \d{2}:\d{2}  \[\d{1,2}:\d{2}\] horticulture: my new project/

  Scenario: Reporting the time entries on a specific day
    Given an existing project file
    And an existing time record file
    When I run `tempo start --at "2014-01-02" this will add a newer record file`
    And I run `tempo report "2014-01-01"`
    Then the output should contain "Records for 01/01/2014:"
        And the output should not contain "Records for 01/02/2014:"
    And the output should contain "horticulture: putting on overalls and straw hat"

  Scenario: Reporting the time entries for multipe days
    Given an existing project file
    And an existing time record file
    When I run `tempo start --at "2014-01-02" this will add a newer record file`
    When I run `tempo start --at "2014-01-03" and an even newer record file`
    And I run `tempo report --from "2014-01-01" --to "2014-01-03"`
    Then the output should contain "Records for 01/01/2014:"
    And the output should contain "Records for 01/02/2014:"
    And the output should contain "Records for 01/03/2014:"

@pending
  Scenario: Reporting the time entries for multipe days
    Given an existing project file
    And an existing time record file
    When I run `tempo start --at "2014-01-02" this will add a newer record file`
    When I run `tempo start --at "2014-01-03" and an even newer record file`
    And I run `tempo report --from "20140101" --to "20140103"`
    Then the output should contain "Records for 01/01/2014:"
    And the output should contain "Records for 01/2/2014:"
    And the output should contain "Records for 01/03/2014:"

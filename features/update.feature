Feature: Update Command manages edits to the time records
  Time record start and end times, descriptions, and projects can be changed,
  or whole records can be deleted. Time records can be chosen by id and day

  Scenario: Attempting to update on a day with no records
    Given an existing project file
    And an existing time record file
    When I run `tempo update --on 1/1/2015 practicing banjo`
    Then the stderr should contain "no time records on 01/01/2015 exist"

  Scenario: Attempting to update by id with no matching records
    Given an existing project file
    And an existing time record file
    When I run `tempo update --id 22 practicing banjo`
    Then the stderr should contain "no time record on 01/01/2014 matches the request: id = 22"

  Scenario: Deleting the last record
    Given an existing project file
    And an existing time record file
    When I successfully run `tempo update --delete`
    Then the stdout should contain "time record deleted:\n13:32 - 16:46  [3:14] nano aquarium: trimming the coral"
    And the time record 20140101 should not contain ":project_title: nano aquarium"

  Scenario: Deleting the only record on a day
    Given an existing project file
    When I run `tempo start --at "12/1/2014 7:00" --end "12/1/2014 8:00" raking leaves`
    And I successfully run `tempo update --on "12/1/2014" --delete`
    Then the time record 20141201 should not exist

  Scenario: Updating the description for the last time record
    Given an existing project file
    And an existing time record file
    When I successfully run `tempo update anemone feeding`
    Then the stdout should contain "time record updated:\n13:32 - 16:46  [3:14] nano aquarium: anemone feeding"
    And the time record 20140101 should contain ":description: anemone feeding" at line 35

  Scenario: Updating the start time for the last time record
    Given an existing project file
    And an existing time record file
    When I successfully run `tempo update --start "2014-01-01 13:45"`
    Then the stdout should contain "time record updated:\n13:45 - 16:46  [3:01] nano aquarium: trimming the coral"
    And the time record 20140101 should contain ":start_time: 2014-01-01 13:45:00" at line 36

  Scenario: Updating the end time for the last time record
    Given an existing project file
    And an existing time record file
    When I successfully run `tempo update --end "2014-01-01 16:35"`
    Then the stdout should contain "time record updated:\n13:32 - 16:35  [3:03] nano aquarium: trimming the coral"
    And the time record 20140101 should contain ":end_time: 2014-01-01 16:35:00" at line 37

  Scenario: Updating to the project for the last time record
    Given an existing project file
    And an existing time record file
    When I successfully run `tempo update --project`
    Then the stdout should contain "time record updated:\n13:32 - 16:46  [3:14] horticulture: trimming the coral"
    And the time record 20140101 should contain ":description: trimming the coral" at line 35

  Scenario: Updating a time record on an earlier day
    Given an existing project file
    And an existing time record file
    When I run `tempo start --at "12/1/2013 7:00" --end "12/1/2013 8:00" raking leaves`
    And I run `tempo start --at "12/1/2013 8:00" --end "12/1/2013 9:00" counting rosebuds`
    When I successfully run `tempo update --on "12/1/2013" --id 1 feeding flytraps`
    Then the stdout should contain "time record updated:\n07:00 - 08:00  [1:00] horticulture: feeding flytraps"
    And the time record 20131201 should contain ":description: feeding flytraps" at line 3

  Scenario: Updating the end time on a time record on an earlier day
    Given an existing project file
    And an existing time record file
    When I run `tempo start --at "12/1/2013 7:00" --end "12/1/2013 8:00" raking leaves`
    And I run `tempo start --at "12/1/2013 9:00" --end "12/1/2013 10:00" counting rosebuds`
    When I successfully run `tempo update --on "12/1/2013" --id 1 --end "12/1/2013 8:35"`
    Then the stdout should contain "time record updated:\n07:00 - 08:35  [1:35] horticulture: raking leaves"
    And the time record 20131201 should contain ":end_time: 2013-12-01 08:35:00" at line 5


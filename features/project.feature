Feature: Project Command manages a list of projects
  The project command allows time to be tracked by project
  New projects can be added and deleted
  Projects can also be tagged as inactive or inactive

  Scenario: Listing the current projects
    When I successfully run `tempo project`
    Then the stdout should contain "a"

  Scenario: Listing all Projects
    When I successfully run `tempo project -l`
    Then the stdout should contain "* a"
    And the stdout should contain "  b"
    And the stdout should contain "  c"

  Scenario: Listing all Projects with extra arguments
    When I successfully run `tempo project -l "new project"`
    Then the stdout should contain "* a"
    And the stdout should contain "  b"
    And the stdout should contain "  c"
    And the stdout should not contain "  new project"

  Scenario: Adding a project

  Scenario: Deleting a project

  Scenario: Changing current project

  Scenario: Adding and changing to a new project
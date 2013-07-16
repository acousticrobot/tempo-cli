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
    And the stdout should not contain "  new project"

  Scenario: Adding a project
    When I successfully run `tempo project -a "new project"`
    Then the stdout should contain "added project 'new project'"

  Scenario: Adding a project without quotation marks
    When I successfully run `tempo project -a a new project name`
    Then the stdout should contain "added project 'a new project name'"

  Scenario: Adding a project and Listing projects
    When I successfully run `tempo project -al "new project"`
    Then the stdout should contain "* a"
    And the stdout should contain "  new project"

  Scenario: Deleting a project
    When I successfully run `tempo project -d "b"`
    Then the stdout should contain "deleted project 'b'"

  Scenario: Deleting a project and Listing projects
    When I successfully run `tempo project -dl "b"`
    Then the stdout should contain "* a"
    And the stdout should not contain "b"

  Scenario: Deleting the current project
    When I run `tempo project -d "a"`
    Then the stdout should not contain "deleted project"
    And the stderr should contain "error: cannot delete the active project"

  Scenario: Changing the current project
    When I successfully run `tempo project -c "b"`
    Then the stdout should contain "active project changed to 'b'"

  Scenario: Changing the current project and Listing projects
    When I successfully run `tempo project -cl "b"`
    Then the stdout should contain "* b"
    And the stdout should not contain "* a"

  Scenario: Trying to change to a non-existant project
    When I run `tempo project -c "new project"`
    Then the stderr should contain "error: no project 'new project' exists"
    And the stdout should not contain "changed"


  Scenario: Adding and changing to a new project
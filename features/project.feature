Feature: Project Command manages a list of projects
  The project command allows time to be tracked by project
  New projects can be added and deleted
  Projects can also be tagged as inactive or inactive

  Scenario: Listing projects before any projects exist
    Given no existing project file
    When I run `tempo project`
    Then the stderr should contain "error: no projects file exists"

  Scenario: Listing projects before any projects exist
    Given no existing project file
    When I run `tempo project --list`
    Then the stderr should contain "error: no projects file exists"

  Scenario: Adding the first project creates a file with a current project
    Given no existing project file
    When I successfully run `tempo project horticulture`
    Then the project file should contain ":title: horticulture" at line 5
    And the project file should contain "current" at line 7

  Scenario: Listing the active project by default
    Given an existing project file
    When I successfully run `tempo project`
    Then the stdout should contain "* horticulture"

  Scenario: Listing all Projects alphabetically with --list
    Given an existing project file
    When I successfully run `tempo project --list`
    Then the stdout should contain "  aquaculture"
    And the stdout should contain "    nano aquarium"
    And the stdout should contain "    reading aquaculture digest"
    And the stdout should contain "* horticulture"
    And the stdout should contain "    backyard bonsai"
    And the stdout should contain "    basement mushrooms"

  Scenario: Listing all Projects with --l
    Given an existing project file
    When I successfully run `tempo project -l`
    Then the stdout should contain "  aquaculture"
    And the stdout should contain "    nano aquarium"
    And the stdout should contain "    reading aquaculture digest"
    And the stdout should contain "* horticulture"
    And the stdout should contain "    backyard bonsai"
    And the stdout should contain "    basement mushrooms"

  Scenario: Listing all Projects with Ids displayed
    Given an existing project file
    When I successfully run `tempo project -li`
    Then the stdout should contain "[4]   aquaculture"
    And the stdout should contain "[5]     nano aquarium"
    And the stdout should contain "[6]     reading aquaculture digest"
    And the stdout should contain "[1] * horticulture"
    And the stdout should contain "[2]     backyard bonsai"
    And the stdout should contain "[3]     basement mushrooms"

  Scenario: Listing Projects by matching against arguments
    Given an existing project file
    When I successfully run `tempo project -l culture`
    Then the stdout should contain "  aquaculture"
    And the stdout should contain "    reading aquaculture digest"
    And the stdout should contain "* horticulture"
    And the stdout should not contain "    backyard bonsai"

  Scenario: Listing Projects by matching against regex
    Given an existing project file
    When I successfully run `tempo project -l ^aquaculture$`
    Then the stdout should not contain "    reading aquaculture digest"
    And the stdout should contain "  aquaculture"

  Scenario: Matching Projects with an exact match
    Given an existing project file
    And I successfully run `tempo project -le aquaculture`
    Then the stdout should not contain "    reading aquaculture digest"
    And the stdout should contain "  aquaculture"

  Scenario: Listing no Project when matching against arguments returns nothing
    Given an existing project file
    When I successfully run `tempo project -l "beekeeping"`
    Then the stdout should contain "no projects match 'beekeeping'"

  Scenario: Adding a project
    Given an existing project file
    When I successfully run `tempo project "hang gliding"`
    Then the stdout should contain "added project: hang gliding"
    And the project file should contain ":title: hang gliding"

  Scenario: Adding a project without quotation marks
    Given an existing project file
    When I successfully run `tempo project hang gliding`
    Then the stdout should contain "added project: hang gliding"
    And the project file should contain ":title: hang gliding"

  Scenario: Attempting to add an existing project
    Given an existing project file
    When I run `tempo project "basement mushrooms"`
    Then the stderr should contain "error: project 'basement mushrooms' already exists"

  Scenario: Deleting a project by full match
    Given an existing project file
    When I successfully run `tempo project -d "backyard bonsai"`
    Then the stdout should contain "deleted project 'backyard bonsai'"
    And the project file should not contain ":title: backyard bonsai"

  Scenario: Deleting a project by partial match
    Given an existing project file
    When I successfully run `tempo project -d "bonsai"`
    Then the stdout should contain "deleted project 'backyard bonsai'"
    And the project file should not contain ":title: backyard bonsai"

  Scenario: Deleting a project without quotation marks
    Given an existing project file
    When I successfully run `tempo project -d backyard bonsai`
    Then the stdout should contain "deleted project 'backyard bonsai'"
    And the project file should not contain ":title: backyard bonsai"

  Scenario: Deleting a project with list flag works even without quotes around a partial match
    Given an existing project file
    When I successfully run `tempo project -d backyard bonsai -l`
    Then the stdout should contain "  aquaculture"
    And the stdout should contain "    nano aquarium"
    And the stdout should contain "    reading aquaculture digest"
    And the stdout should contain "* horticulture"
    And the stdout should not contain "    backyard bonsai"
    And the stdout should contain "    basement mushrooms"

  Scenario: Deleting a project with combined '-ld' list flag also works
    Given an existing project file
    When I successfully run `tempo project -ld backyard bonsai`
    Then the stdout should contain "  aquaculture"
    And the stdout should contain "    nano aquarium"
    And the stdout should contain "    reading aquaculture digest"
    And the stdout should contain "* horticulture"
    And the stdout should not contain "    backyard bonsai"
    And the stdout should contain "    basement mushrooms"

  Scenario: Deleting a project by Id
    Given an existing project file
    When I successfully run `tempo project -id 3`
    Then the stdout should contain "deleted project 'basement mushrooms'"
    And the project file should not contain ":title: basement mushrooms"

  Scenario: Attempting to delete a non-existing project Fails
    Given an existing project file
    When I run `tempo project -d "sheep hearding - lanolin extraction"`
    Then the stderr should contain "error: no such project 'sheep hearding - lanolin extraction'"

  Scenario: Attempting to Delete the current project Fails
    Given an existing project file
    When I run `tempo project -d "horticulture"`
    Then the stdout should not contain "deleted project"
    And the stderr should contain "error: cannot delete the active project"

  Scenario: Attempting to Delete with ambiguous match Fails
    Given an existing project file
    When I run `tempo project -d aquaculture`
    Then the stdout should not contain "deleted project"
    And the stderr should contain "error: cannot delete multiple projects"

  Scenario: Tagging a project with a tag
    Given an existing project file
    When I successfully run `tempo project backyard bonsai -t patience`
    Then the stdout should contain "backyard bonsai"
    And the stdout should contain "tags: [ miniaturization, outdoors, patience ]"
    And the project file should contain "- patience"

  Scenario: Tagging a project by Id with a tag
    Given an existing project file
    When I successfully run `tempo project -i 3 -t patience`
    Then the stdout should contain "basement mushrooms"
    And the stdout should contain "tags: [ fungi, indoors, patience ]"
    And the project file should contain "- patience"

  Scenario: Tagging a project with tags
    Given an existing project file
    When I successfully run `tempo project backyard bonsai -t 'patience japanese'`
    Then the stdout should contain "backyard bonsai"
    And the stdout should contain "tags: [ japanese, miniaturization, outdoors, patience ]"
    And the project file should contain "- patience"
    And the project file should contain "- japanese"

  Scenario: Untagging a project with a tag
    Given an existing project file
    When I successfully run `tempo project mushrooms -u fungi`
    Then the stdout should contain "basement mushrooms"
    And the stdout should contain "tags: [ indoors ]"
    And the project file should not contain "- fungi"

  Scenario: Untagging a project by Id
    Given an existing project file
    When I successfully run `tempo project -i 3 -u fungi`
    Then the stdout should contain "basement mushrooms"
    And the stdout should contain "tags: [ indoors ]"
    And the project file should not contain "- fungi"

  Scenario: Untagging a project with tags
    Given an existing project file
    When I successfully run `tempo project mushrooms -u 'indoors fungi'`
    Then the stdout should contain "basement mushrooms"
    And the stdout should contain "tags: none"
    And the project file should not contain "- fungi"

  Scenario: Tagging and Untagging a project
    Given an existing project file
    When I successfully run `tempo project backyard bonsai -u miniaturization -t shrubs`
    Then the stdout should contain "backyard bonsai"
    And the stdout should contain "tags: [ outdoors, shrubs ]"
    And the project file should contain "- shrubs"

  Scenario: Adding a new project with tags
    Given an existing project file
    When I successfully run `tempo project -a fly fishing -t 'patience fish'`
    Then the stdout should contain "added project: fly fishing"
    And the stdout should contain "tags: [ fish, patience ]"
    And the project file should contain "- patience"
    And the project file should contain "- fish"

  Scenario: Attempting to tag a project with ambiguous match
    Given an existing project file
    When I run `tempo project 'aquaculture' -t japanese`
    Then the stdout should not contain "japanese"
    And the stderr should contain "error: cannot tag multiple projects"
    And the project file should not contain "- japanese"

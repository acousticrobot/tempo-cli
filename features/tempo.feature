Feature: GLI bootstrapping sets up cucumber
  GLI scaffold includes aruba and cucumber setup
  Running the tempo project for the first time sets up the folder stucture

  Scenario: App just runs
    When I get help for "tempo"
    Then the exit status should be 0

  Scenario: App initialization creates all necessary files
    Given a clean installation
    When I successfully run `tempo project new project`
    Then the exit status should be 0
    And the project file should contain ":title: new project"

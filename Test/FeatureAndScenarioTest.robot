*** Settings ***
Library    BDDLibrary
Library    Collections

Default Tags    Test-Feature-And-Scenario-Keyword

*** Test Cases ***
Feature: Feature and Scenario keyword
    [Documentation]    In BDDLibrary, Feature must be the first test element

Scenario: Scenario will be executed with Feature
    [Tags]    Test-Scenario-Execute-With-Feature
    Then The scenario should be execute

Scenario: Multiple Scenario will be executed with Feature
    [Tags]    Test-Scenario-Execute-With-Feature
    Then The scenario should be execute

*** Keywords ***
The scenario should be execute
    Pass Execution    pass
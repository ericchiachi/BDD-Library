*** Settings ***
Library    BDDLibrary
Library    Collections

Default Tags    Test-Background-Keyword

*** Test Cases ***
Feature: Background Keyword
    [Documentation]    An acceptance criteria of Background keyword
    
Background:
    Given I have a list that only contains Bob

Scenario: Keyword `Background` should execute before test case
    [Tags]    Test-Background-Execute-Before-Each-Test
    When I append Isaac into the list
    Then The list should contain Bob
    And The list should contain Isaac

Scenario: Keyword: `Background` should execute before each scenario
    [Tags]    Test-Background-Execute-Before-Each-Test
    Then The list should contain Bob
    But The list should not contain Isaac

Scenario: Keyword: `Background` should work with Setup and Teardown in test case
    [Documentation]    Background keyword should execute before each test cases, and after test setup
    [Tags]    Test-Background-With-Setup-And-Teardown
    [Setup]    I have a list that only contains Paul
    Then The list should contain Bob
    But The list should not contain Paul
    [Teardown]    I remove Bob from the list

Scenario Outline: Keyword: `Background` should work with `Scenario Outline`
    [Documentation]    Background keyword should execute before each Example
    [Tags]    Test-Background-With-Scenario-Outline
    When I append <name> into the list
    Then The list should contain Bob
    And The list should contain <name>
    But The list should not contain <not-exist-name>
    Examples:
    ...    | name | not-exist-name |
    ...    | Eric | John |
    ...    | John | Eric |

Scenario: Keyword: `Background` should work with `Embedding Table`
    [Documentation]    Background keyword should execute before Embedded data
    [Tags]    Test-Background-With-Embedded-Keyword
    When I add following names into the list
    ...    | name |
    ...    | Jack |
    ...    | Rose |
    Then Following names should exist in the list
    ...    | firstName | secondName |
    ...    | Bob | Jack |
    ...    | Bob | Rose |

*** Variables ***
@{list} =    ${EMPTY}

*** Keywords ***
I have an empty list
    FOR    ${elem}    IN    @{list}
        Remove Values From List    ${list}    ${elem}
    END

I have a list that only contains ${name}
    I have an empty list
    I append ${name} into the list

I append ${name} into the list
    Append To List    ${list}    ${name}
    
The list should not contain ${name}
    List Should Not Contain Value    ${list}    ${name}

I remove ${name} from the list
    Remove Values From List    ${list}    ${name}

The list should contain ${name}
    List Should Contain Value    ${list}    ${name}

I add following names into the list
    [Arguments]    ${embeddedArguments}    @{placeHolder}
    I append ${embeddedArguments}[name] into the list

Following names should exist in the list
    [Arguments]    ${embeddedArguments}    @{placeHolder}
    The list should contain ${embeddedArguments}[firstName]
    The list should contain ${embeddedArguments}[secondName]

Following names should not exist in the list
    [Arguments]    ${embeddedArguments}    @{placeHolder}
    The list should not contain ${embeddedArguments}[not-exist-name]
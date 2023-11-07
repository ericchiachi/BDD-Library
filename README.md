# BDD Library

## Introduction

BDD Library is a [Robot Framework](https://github.com/robotframework/robotframework) library that supports the use of [Gherkin syntax](https://cucumber.io/docs/gherkin/reference/), include `Feature`, `Scenario`, `Scenario Outline`(with `Example`), `Background`, and `Embedding table` style.

The BDD Library is written in python. It utilizes a Listener Interface to retrieve the original test script containing Gherkin syntax and parses it as an executable script.

## Usage

Robot Framework natively supports only the `Given`, `When`, `Then`, `And`, `But` keywords. By utilizing the BDD Library, you can use the entire Gherkin syntax for your testing scenarios.

## Setup

Below is an example of how to use the BDD Library. Simply include **BDDLibrary** in the **Settings** segment.

    *** Settings ***
    Library    BDDLibrary

## Example

In this section, we will provide a brief introduction to these keywords. For more examples, please refer to the examples located within the `./Test` directory.

For the definitions and purposes of these keywords, please refer to [Gherkin keywords](https://cucumber.io/docs/gherkin/reference/#keywords).

### 1. Feature

The `Feature` keyword is used to describe the scope of a software feature. A Feature typically encompasses multiple related scenarios.

In Robot Framework, the fundamental unit of a file is a `Suite`. According to its definition, a Suite should be capable of containing multiple features. However, when a suite contains multiple features, it can be confusing for readers as they would need to check the rows of a scenario to determine which feature it belongs to. To prevent this confusion, we limit a suite file to containing only one feature.

When using BDD Library, the `Feature` must be the first test element in Test Case section. The syntax is `Feature`, followed by a `:` , `space`, and a brief description of the feature.

If you need to descript the feature in more detail, you can use `[Documentation]` to provide additional information.

    *** Test Cases***
    Feature: Example of Feature and Scenario keyword
        [Documentation]    In BDDLibrary, Feature must be the first test element

    Scenario: Scenario will be executed with Feature
        Then The scenario should be execute

### 2. Scenario

In `Scenario` keyword, we use concrete example to descript feature, which consists of multiple steps.

When using BDD Library, the `Scenario` must come after `Feature`. The syntax is `Scenario`, followed by a `:` , a `space`, and a brief description of the scenario.

A Feature can contain multiple Scenarios.

    *** Test Cases***
    Feature: Example of Feature and Scenario keyword
        [Documentation]    In BDDLibrary, Feature must be the first test element

    Scenario: Scenario will be executed with Feature
        Then The scenario should be execute
    
    Scenario: Multiple Scenarios will be executed
        Then The scenario should be execute

### 3. Scenario Outline (with Examples)

To run a scenario multiple times with different combinations of data, you can utilize a `Scenario Outline`.

When using BDD Library, the `Scenario Outline` must come after `Feature`. The syntax is `Scenario Outline`, followed by a `:` , a `space`, and a brief description of the scenario. In your test script, you should mark the given data with `<` and `>`, indicating where different combinations of data will be inserted.

At the end of a Scenario Outline, you should include an `Examples` section, which consists of a `:` followed by a `Data table`. The data table typically includes the following components:

- The first line of Data Table specifies the `Name` of the datas.
- Subsequent lines contain `Values` of the datas.
- Each different datas seperated by `|` charactor.

Here is an example:

    Scenario Outline: Keyword: `Example` should work when multiple keys exist
    Given I have an empty list
    When I append <name> into the list
    Then The list should contain <name>
    But The list should not contain <notExistingName>
    Examples:
    ...    | name | notExistingName |
    ...    | Bob | Jackson |
    ...    | Alice | John |

### 4. Embedding Table

To execute a specified step in a Scenario multiple times with different values, you can utilize an `Embedding Table`. To do this, you can place a `Data Table` after a specified step, and the step will be executed multiple times within the scenario, with each execution using different `Values` from the data table as parameters.

    Scenario: Embedding keyword should repeat the keyword with table multi times
    Given There is a bank with following accounts
    ...    | name | balance |
    ...    | John | 10000 |
    ...    | Alice | 1000 |
    ...    | Bob | 100 |
    When Each person pick up 1000 from their account
    Then The balance should be same as following
    ...    | name | balance |
    ...    | John | 9000 |
    ...    | Alice | 0 |
    ...    | Bob | -900 |

When implementing a keyword with an Embedding Table, you should structure it as follows:

1. the first argument must be a [Scalar Variable](https://docs.robotframework.org/docs/variables). BDD Library will pass a dictionary into the argument, whos key is the `Names` of data table, and value is the `Values` of data table.

2. The second argument must be a [List Varaible](https://docs.robotframework.org/docs/variables) which is a placeholder, BDD Library will pass a None to it.

[//]: # (This use to end the list)

    There is a bank with following accounts
    [Arguments]    ${accountInfo}    @{placeHolder}
    Set To Dictionary    ${accounts}    ${accountInfo}[name]=${accountInfo}[balance]

Another benefit of using an Embedding Table is that it allows you to display complex data in a single step. This can enhance the readability and comprehensibility of your scenarios. Even if a step needs to be executed only once, if the provided data is important for the reader's understanding, it is recommended to use the Embedding Table to present that data. This can make your scenarios more informative and easier to follow.

Embedding Table can also use with Scenario Outline, in the previous example, if the values have no direct relationship, you can utilize a Scenario Outline to split the scenario into distinct parts.

    Scenario Outline: Embedding keyword could use with Scenario Outline
    Given There is a bank with following accounts
    ...    | name | balance |
    ...    | <Name> | <OriginBalance> |
    When Each person pick up 1000 from their account
    Then The balance should be same as following
    ...    | name | balance |
    ...    | <Name> | <NewBalance> |
    Examples:
    ...    | Name | OriginBalance | NewBalance |
    ...    | John | 10000 | 9000 |
    ...    | Alice | 1000 | 0 |
    ...    | Bob | 100 | -900 |

### 5. Background

When there is repeating Given step in a Feature, you can grouping them under Background section. The BDD Library will then automatically include these background steps before each Scenario.

When using BDD Library, the `Background` must be the second test element in Test Case section, there should be no Scenario placed before the Background. The syntax is `Background`, followed by a `:`, and the execatable step of background.

    Feature: Background Keyword
        [Documentation]    An acceptance criteria of Background keyword
        
    Background:
        Given I have a list that only contains Bob

    Scenario: Steps in `Background` should execute before Scenario
        When I append Isaac into the list
        Then The list should contain Bob
        And The list should contain Isaac

### 6. Tags

Robot Framework supports users in executing specified test cases by using tags. However, because there are no defined criteria for tagging the `Feature` and `Background` keywords, these keywords will not be processed by the BDD Library when users execute tests based on scenario tags. This will result in an exception.

To prevent exception, we recommend assigning a `Default Tags` to all test elements within the suite and using the `[Tags]` tag to override the default tag as needed.

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

In the example case, you can execute the case with a command as follows:

    robot -i Test-Background-Keyword -i Test-Background-Execute-Before-Each-Test

## Contributor

This library was developed by the individuals listed below. Please don't hesitate to contact us if you encounter any issues.

- [Paul](https://github.com/Paul0730)
- [Eric Chang](https://github.com/ericchiachi)

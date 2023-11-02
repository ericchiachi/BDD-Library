# BDD-Library

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

### 3. Scenario Outline (Examples)

### 4. Embedding Table

### 5. Background

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

- <xie57813@gmail.com>
- <ericchiachi@gmail.com>

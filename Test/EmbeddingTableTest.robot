*** Settings ***
Library    BDDLibrary
Library    Collections

Default Tags    Test-Embedding-Table

*** Variables ***
&{accounts} =    &{EMPTY}
${scalarVariable} =    test
@{listVariable} =    element0    element1    element2
&{dictionaryVariable} =     key0=value0

*** Test Cases ***
Feature: Embedding Keyword
    [Documentation]    An acceptance criteria of Embedding keyword

Scenario: Embedding keyword should repeat the keyword with table multi times
    [Tags]    Test-Embedding-Keyword-Execute-Multi-Times
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

Scenario: Embedding keyword should support different type of data
    [Tags]    Test-Embedding-Keyword-Support-Different-Data-Type
    Then Embedding keyword support scalar variable
    ...    | Variable | Content |
    ...    | ${scalarVariable} | test |
    Then Embedding keyword support numeric variable
    ...    | Variable | Content |
    ...    | ${123} | 123 |
    Then Embedding keyword support list variable
    ...    | Variable | Content |
    ...    | ${listVariable}[0] | element0 |
    Then Embedding keyword support dictionary variable
    ...    | Variable | Content |
    ...    | ${dictionaryVariable}[key0] | value0 |
    Then Embedding keyword support scalar type "EMPTY" built-in variable
    ...    | Variable |
    ...    | ${EMPTY} |
    Then Embedding keyword support list type "EMPTY" built-in variable
    ...    | Variable |
    ...    | @{EMPTY} |
    Then Embedding keyword support dictionary type "EMPTY" built-in variable
    ...    | Variable |
    ...    | &{EMPTY} |

Scenario Outline: Embedding keyword should work with Scenario Outline
    Given There is a bank with following accounts
    ...    | name | balance |
    ...    | <name> | <origin_balance> |
    When Each person pick up 1000 from their account
    Then The balance should be same as following
    ...    | name | balance |
    ...    | <name> | <new_balance> |
    Examples:
    ...    | name | origin_balance | new_balance |
    ...    | John | 10000 | 9000 |
    ...    | Alice | 1000 | 0 |
    ...    | Bob | 100 | -900 |
    

Scenario Outline: Embedding keyword should work with Scenario Outline who's data table contains variable
    Then Embedding keyword support different type of variable
    ...    | Variable | Content |
    ...    | <variable> | <content> |
    Examples:
    ...    | variable | content |
    ...    | ${scalarVariable} | test |
    ...    | ${123} | 123 |
    ...    | ${listVariable}[0] | element0 |
    ...    | ${dictionaryVariable}[key0] | value0 |

*** Keywords ***
There is a bank with following accounts
    [Arguments]    ${accountInfo}    @{placeHolder}
    Set To Dictionary    ${accounts}    ${accountInfo}[name]=${accountInfo}[balance]
    
Each person pick up 1000 from their account
    ${nameList} =    Get Dictionary Keys    ${accounts}
    FOR    ${name}    IN    @{nameList}
        ${balance} =    Get From Dictionary    ${accounts}    ${name}
        ${newBalance} =    Evaluate    ${balance}-1000
        Set To Dictionary    ${accounts}    ${name}=${newBalance}
    END

The balance should be same as following
    [Arguments]    ${accountInfo}    @{placeHolder}
    ${currentBalance} =    Get From Dictionary    ${accounts}    ${accountInfo}[name]
    Should Be Equal As Integers    ${accountInfo}[balance]    ${currentBalance}   

Embedding keyword support scalar variable
    [Arguments]    ${variable}    @{placeHolder}
    Should Be Equal    ${variable}[Variable]    ${variable}[Content]

Embedding keyword support numeric variable
    [Arguments]    ${variable}    @{placeHolder}
    Should Be Equal As Integers    ${variable}[Variable]    ${variable}[Content]

Embedding keyword support list variable
    [Arguments]    ${variable}    @{placeHolder}
    Should Be Equal    ${variable}[Variable]    ${variable}[Content]

Embedding keyword support dictionary variable
    [Arguments]    ${variable}    @{placeHolder}
    Should Be Equal    ${variable}[Variable]    ${variable}[Content]

Embedding keyword support scalar type "EMPTY" built-in variable
    [Arguments]    ${variable}    @{placeHolder}
    Should Be Empty    ${variable}[Variable]

Embedding keyword support list type "EMPTY" built-in variable
    [Arguments]    ${variable}    @{placeHolder}
    Should Be Empty    ${variable}[Variable]

Embedding keyword support dictionary type "EMPTY" built-in variable
    [Arguments]    ${variable}    @{placeHolder}
    Should Be Empty    ${variable}[Variable]

Embedding keyword support different type of variable
    [Arguments]    ${variable}    @{placeHolder}
    Log    ${variable}[Variable]
    Should Be Equal    ${variable}[Variable]    ${variable}[Content]
*** Settings ***
Library    BDDLibrary
Library    Collections

Default Tags    Test-Example-Keyword

*** Variables ***
@{list} =    ${EMPTY}
&{Bob} =    Name=Bob
&{Alice} =    Name=Alice
@{mainStringList} =    Syetem    Print    Hello    World    
@{subStringList} =    Syetem    Print
@{mainNumericList} =    0    1    999    -1
@{subNumericList} =     999    -1
@{BobAndAlice} =    Bob    Alice
@{JohnAndPaul} =    John    Paul
&{mainStringDict} =    key1=value1    key2=value2    key3=value3
&{subStringDict} =    key2=value2
&{dict} =    &{EMPTY}

*** Test Cases ***
Feature: Example Keyword
    [Documentation]    An acceptance criteria of Example keyword

Scenario Outline: Keyword: `Example` should execute test multi times, with different data
    [Tags]    Test-Background-Execute-Multi-Times
    Given I have an empty list
    When I append <name> into the list
    Then The list should contain <name>
    Examples:
    ...    | name |
    ...    | Bob |
    ...    | Alice |

Scenario Outline: Keyword: `Example` should work when multi keys exist
    [Tags]    Test-Background-Execute-Multi-Times
    Given I have an empty list
    When I append <name> into the list
    Then The list should contain <name>
    But The list should not contain <notExistingName>
    Examples:
    ...    | name | notExistingName |
    ...    | Bob | Jackson |
    ...    | Alice | John |

Scenario Outline: Keyword: `Example` should work with teardown
    [Tags]    Test-Background-Execute-With-Teardown
    Given I have an empty list
    When I append <name> into the list
    Then The list should contain <name>
    Examples:
    ...    | name |
    ...    | Bob |
    ...    | Alice |
    [Teardown]    Teardown for test    <name>
    
Scenario Outline: Keyword `Example` should work with dictionary type argument
    Given I have an empty list
    When I append <name> into the list who's argument is a dict type
    Then The list should contain <name> who's argument is a dict type
    Examples:
    ...    | name |
    ...    | ${Bob} |
    ...    | ${Alice} |

Scenario Outline: Keyword `Example` should work with list type argument
    Given I have an empty list
    When I append <names> into the list who's argument is a list type
    Then The list should contain <names> who's argument is a list type
    Examples:
    ...    | names |
    ...    | ${BobAndAlice} |
    ...    | ${JohnAndPaul} |

Scenario Outline: Keyword: `Example` should work with teardown even parameter is a list
    [Tags]    Test-Background-Execute-With-Teardown
    Given I have an list <mainList>
    When I remove all the elements of <subList> from the list
    Then The list should not contain any element of <subList>
    Examples:
    ...    | mainList | subList |
    ...    | ${mainStringList} | ${subStringList} |
    ...    | ${mainNumericList} | ${subNumericList} |
    [Teardown]    Remove all elements from list    <mainList>

Scenario Outline: Keyword: `Example` should work with teardown even parameter is a dictionary
    [Tags]    Test-Background-Execute-With-Teardown
    Given I have an main dict <mainDict>
    When I remove all the elements of <subDict> from the main dict
    Then The dict should not contain any element of <subDict>
    Examples:
    ...    | mainDict | subDict |
    ...    | ${mainStringDict} | ${subStringDict} |
    [Teardown]    Remove all elements from dict    <mainDict>

*** Keywords ***
I append ${name} into the list
    Append To List    ${list}    ${name}

I have an empty list
    FOR    ${elem}    IN    @{list}
        Remove Values From List    ${list}    ${elem}
    END

The order in the list should be ${firstName}, ${secondName}, and ${thirdName}
    Should Be Equal    ${firstName}    ${list}[0]
    Should Be Equal    ${secondName}    ${list}[1]
    Should Be Equal    ${thirdName}    ${list}[2]

I have a list which contains Bob
    I have an empty list
    I append Bob into the list

The list should be empty
    ${listLength} =    Get Length    ${list}
    Should Be Equal As Numbers    ${0}    ${listLength}

The list should contain ${name:\S+}
    Log    ${name}
    List Should Contain Value    ${list}    ${name}

The list should not contain ${notExistingName:\S+}
    List Should Not Contain Value    ${list}    ${notExistingName}

Teardown for test
    [Arguments]    @{names}
    FOR    ${name}    IN    @{names}
        Remove Values From List    ${list}    ${name}
    END
    The list should be empty

I have an list ${mainList}
    @{list} =    Set Variable     @{mainList}

I remove all the elements of ${subList} from the list
    Remove Values From List    ${list}    ${subList}
    
The list should not contain any element of ${subList}
    FOR    ${subListElement}    IN    @{subList}
        List Should Not Contain Value    ${list}    ${subListElement}
    END

Remove all elements from list
    [Arguments]    ${mainList}
    Remove Values From List    ${list}    ${mainList}

I append ${name} into the list who's argument is a dict type
    Append To List    ${list}    ${name}[Name]

The list should contain ${name} who's argument is a dict type
    List Should Contain Value    ${list}    ${name}[Name]

I append ${nameList} into the list who's argument is a list type
    FOR    ${name}    IN    @{nameList}
        Append To List    ${list}    ${name}
    END

The list should contain ${nameList} who's argument is a list type
    List Should Contain Sub List    ${list}    ${nameList}

I have an main dict ${mainDict}
    &{dict} =    Set Test Variable    &{mainDict}

I remove all the elements of ${subDict} from the main dict
    ${keys} =    Get Dictionary Keys    ${subDict}
    FOR    ${key}     IN    @{keys}
        Remove From Dictionary    ${dict}    ${key}
    END

The dict should not contain any element of ${subDict}
    ${keys} =    Get Dictionary Keys    ${subDict}
    FOR    ${key}     IN    @{keys}
        Dictionary Should Not Contain Key    ${dict}    ${key}
    END

Remove all elements from dict
    [Arguments]    ${mainDict}
    ${keys} =    Get Dictionary Keys    ${mainDict}
    FOR    ${key}     IN    @{keys}
        Remove From Dictionary    ${dict}    ${key}
    END
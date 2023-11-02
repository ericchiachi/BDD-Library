from robot.api.deco import keyword
from robot.model.testcase import TestCases
from robot.libraries.BuiltIn import BuiltIn
import copy
import re

class BDDLibrary:

    ROBOT_LISTENER_API_VERSION = 3
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.execute_target_suite = None
        self.__feature_parser__ = None
        self.__background_parser__ = None
        self.__scenario_parser__ = None
        self.__scenario_outline_parser__ = None
        self.__embedding_table_parser__ = None
        
    def _start_suite(self, suite, results):
        self.execute_target_suite = suite
        origin_test_cases = suite.tests # copy the original test cases
        self.execute_target_suite.tests = TestCases() # init with no test case
        
        self.__feature_parser__ = FeatureParser(self.execute_target_suite)
        self.__background_parser__ = BackgroundParser()
        self.__scenario_parser__ = ScenarioParser(self.execute_target_suite)
        self.__scenario_outline_parser__ = ScenarioOutlineParser(self.execute_target_suite)
        self.__embedding_table_parser__ = EmbeddingTableParser()
        
        self.__feature_parser__.parse(origin_test_cases)
        self.__feature_parser__.update_feature_name()
        self.__feature_parser__.update_feature_doc()

        if self.__background_parser__.contains_background(origin_test_cases):
            self.__background_parser__.parse(origin_test_cases[1])
            scenarios = origin_test_cases[2:]
        else:
            scenarios = origin_test_cases[1:]
        
        for scenario in scenarios:
            if(self.__scenario_outline_parser__.is_scenario_outline(scenario)):
                self.__scenario_outline_parser__.parse(scenario)
                self.__scenario_outline_parser__.addExamples()
            elif(self.__scenario_parser__.is_scenario(scenario)):
                self.__scenario_parser__.parse(scenario)
                self.__scenario_parser__.addScenario()
            else:
                raise Exception("Test name must start with `Scenario:` or `Scenario Outline:`")
        
        for index, scenario in enumerate(self.execute_target_suite.tests):
            if(self.__background_parser__.contains_background()):
                scenario = self.__background_parser__.add_background_step(scenario)
            
            if(self.__embedding_table_parser__.contains_embedding_table(scenario)):
                self.__embedding_table_parser__.parse(scenario)
                scenario = self.__embedding_table_parser__.add_embedding_step(scenario)
            
            self.execute_target_suite.tests[index] = scenario

    @keyword(name='Examples:')
    def examples(self, header, *datas):
        """
        This keywrod is a placeholder used to provide the usage of BDD data table.
        """


class FeatureParser:
    
    def __init__(self, execute_target_suite):
        self.__feature_name__ = None
        self.__feature_doc__ = None
        self.__execute_target_suite__ = execute_target_suite
    
    def parse(self, tests):
        number_of_feature = 0
        for test in tests:
            if self.__is_a_feature__(test):
                number_of_feature += 1
        
        if number_of_feature>1:
            raise Exception("A feature file should only contains one feature")
        
        feature_placed_in_first_place = self.__is_a_feature__(tests[0])
        if not feature_placed_in_first_place:
            raise Exception("First element in test cases must be a Feature")
        
        self.__feature_name__ = tests[0].name
        self.__feature_doc__ = tests[0].doc
        
        return number_of_feature==1 and feature_placed_in_first_place
    
    def update_feature_name(self):
        self.__execute_target_suite__.name = self.__feature_name__
    
    def update_feature_doc(self):
        self.__execute_target_suite__.doc = self.__feature_doc__ 

    def __is_a_feature__(self, test):
        if( not str(test.name).startswith("Feature:") ):
            return False
        elif( len(test.keywords) != 0 ):
            return False
        return True


class BackgroundParser:
    
    def __init__(self):
        self.__background_steps__ = None
        
    def contains_background(self, tests=None):
        if tests==None: # overload
            return self.__background_steps__!=None
        
        number_of_background_test = 0
        for test in tests:
            if self.__is_a_background_test__(test):
                number_of_background_test += 1
        
        if number_of_background_test>1: raise Exception("A feature file should only contains one background")
        
        background_placed_in_second_place = self.__is_a_background_test__(tests[1])
        return number_of_background_test==1 and background_placed_in_second_place

    def parse(self, test):
        self.__background_steps__ = test.keywords
    
    def add_background_step(self, test):
        insert_background_index = 0
        if(self.__contain_setup__(test)):
            insert_background_index = 1
        for background_keyword in self.__background_steps__ :
            test.keywords.insert(insert_background_index, background_keyword)
            insert_background_index += 1
        return test
    
    def __is_a_background_test__(self, test):
        if( not str(test.name).startswith("Background:") ):
            return False
        elif( len(test.keywords) == 0 ):
            return False
        return True
    
    def __contain_setup__(self, test):
        return test.keywords.setup!=None
    
        
class ScenarioParser:
    
    def __init__(self, execute_target_suite):
        self.__execute_target_suite__ = execute_target_suite
        self.__test__ = None
    
    def is_scenario(self, test):
        if( not str(test.name).startswith("Scenario:") ):
            return False
        elif( len(test.keywords) == 0 ):
            return False
        return True

    def parse(self, test):
        self.__test__ = test
    
    def addScenario(self):
        self.__execute_target_suite__.tests.append(self.__test__)


class ScenarioOutlineParser:
    
    def __init__(self, execute_target_suite):
        self.__example_data_table__ = None
        self.__test__ = None
        self.__execute_target_suite__ = execute_target_suite
    
    def is_scenario_outline(self, scenario):
        if( not str(scenario.name).startswith("Scenario Outline:") ):
            return False
        
        for keyword in scenario.keywords:
            if(keyword.name.lower() == "examples:"):
                return True
        
        return False
    
    def parse(self, test):
        self.__example_data_table__ = list()
        self.__test__ = test
        for keyword in test.keywords:
            if(keyword.name.lower() == "examples:"):
                self.__create_example_data_table__(keyword.args)
                break
        
    def addExamples(self):
        for serial_number, example_data in enumerate(self.__example_data_table__):
            self.__add_an_example_test_case__(self.__test__.name, self.__test__.tags, self.__test__.keywords, serial_number, example_data)
    
    def __create_example_data_table__(self, embedding_table):
        headers = list(map(lambda x: x.strip(),embedding_table[0].split('|')))
        for data in embedding_table[1:]:
            columns = list(map(lambda x: x.strip(),data.split('|')))
            data_dict = dict()
            for header, column in zip(headers, columns):
                if(header != ''):
                    data_dict[header] = column
            self.__example_data_table__.append(data_dict)
            
    def __add_an_example_test_case__(self, test_name, test_tag, test_keywords, serial_number, example_data):
        script_keywords = copy.deepcopy(test_keywords)
        example_test_case = self.__execute_target_suite__.tests.create(name=test_name + " - " + str(serial_number), tags=test_tag) 
        for script_keyword in script_keywords:
            if( script_keyword.name.lower() == "examples:" ):
                continue

            if( script_keyword.type == "setup" or script_keyword.type == "teardown" ):
                if(self.__keyword_name_contain_embedding_key__(script_keyword.name)):
                    raise Exception("embedding key is not allowed to use as embedding argument in test setup/teardown, use it as normal argument")
                if(self.__keyword_argument_contain_embedding_key__(script_keyword.args)):
                    script_keyword.args = self.__replace_keyword_argument_with_example_data__(script_keyword.args, example_data)
            
            else: # main script
                if(self.__keyword_name_contain_embedding_key__(script_keyword.name)):
                    script_keyword.name = self.__replace_keyword_name_with_example_data__(script_keyword.name, example_data)
                if(self.__keyword_argument_contain_embedding_key__(script_keyword.args)): # embedding table case
                    script_keyword.args = self.__replace_keyword_argument_with_example_data__(script_keyword.args, example_data)
            
            example_test_case.keywords.append(script_keyword)
    
    def __keyword_name_contain_embedding_key__(self, keyword_name):
        return True if ("<" in keyword_name and ">" in keyword_name) else False
    
    def __keyword_argument_contain_embedding_key__(self, keyword_argument):
        for argument in keyword_argument:
            if "<" in argument and ">" in argument: return True
        
        return False

    def __replace_keyword_argument_with_example_data__(self, arguments, example_data):
        replaced_arguments = []
        for argument in arguments:
            keys = re.findall(r'<(.*?)>', argument)
            for key in keys:
                if(key in example_data):
                    argument = argument.replace("<"+key+">",example_data[key])
                else:
                    raise Exception("given key:" + key + "not exist in examples data table")
            
            replaced_arguments.append(argument)

        return tuple(replaced_arguments)
    
    def __replace_keyword_name_with_example_data__(self, keyword_name, example_data):
        keys = re.findall(r'<(.*?)>', keyword_name)
        for key in keys:
            if(key in example_data):
                keyword_name = keyword_name.replace("<"+key+">",example_data[key])
            else:
                raise Exception("given key:" + key + "not exist in examples data table")
        
        return keyword_name


class EmbeddingTableParser:
    def init(self):
        self.__embedding_data_dictionay__ = None
    
    def contains_embedding_table(self, test):
        for keyword in test.keywords:
            if(self.__keyword_contains_embedding_table__(keyword)):
                return True
        
        return False
    
    def parse(self, test):
        self.__embedding_data_dictionay__ = dict()
        for keyword in test.keywords:
            if(self.__keyword_contains_embedding_table__(keyword)):
                self.__add_embedding_data_pairing__(keyword.name, keyword.args) # use keyword name as key to prevent duplicate key in different keyword
    
    def add_embedding_step(self, test):
        result = copy.deepcopy(test)
        for repeat_index, script_keyword in enumerate(result.keywords):
            if script_keyword.name in self.__embedding_data_dictionay__.keys(): # remove the origin one
                del result.keywords[repeat_index]

            while script_keyword.name in self.__embedding_data_dictionay__.keys():
                embedding_argument = dict()
                embedding_argument_keys = list(self.__embedding_data_dictionay__[script_keyword.name].keys())
                for embedding_argument_key in embedding_argument_keys:
                    embedding_argument_values = self.__embedding_data_dictionay__[script_keyword.name][embedding_argument_key]
                    embedding_argument[embedding_argument_key] = embedding_argument_values[0]
                    embedding_argument_values.pop(0)
                    if len(embedding_argument_values) == 0: # remove if no values in a key
                        del self.__embedding_data_dictionay__[script_keyword.name][embedding_argument_key]
                
                repeat_script_keyword = copy.deepcopy(script_keyword)
                repeat_script_keyword.args = [copy.deepcopy(embedding_argument), None]
                result.keywords.insert(repeat_index, repeat_script_keyword)
                if not any(self.__embedding_data_dictionay__[script_keyword.name]): # remove if no key in a keyword
                    del self.__embedding_data_dictionay__[script_keyword.name]
        
        return result

    def __keyword_contains_embedding_table__(self, keyword):
        if keyword.name.startswith("Examples:"): # example is a different type of data table
            return False
        if len(keyword.args) < 2: # at least contains header and body
            return False
        key = keyword.args[0]
        values = keyword.args[1:]
        if key.startswith("|") and map(lambda value: value.startswith("|"), values):
            return True
        return False
    
    def __add_embedding_data_pairing__(self, keyword_name, embedding_arguments):
        argument_header = embedding_arguments[0]
        argument_bodys = embedding_arguments[1:]
        embedding_keys = self.__parse_embedding_argument__(argument_header)
        embedding_values = list()
        embedding_data_dict = dict()
        for argument_body in argument_bodys:
            embedding_value = self.__parse_embedding_argument__(argument_body)
            for index in range(len(embedding_value)):
                embedding_value[index] = self.__get_value_of_variable__(embedding_value[index]) # when append into a dict, the varaible will be considered as a string
            embedding_values.append(embedding_value)
        
        for index, embedding_key in enumerate(embedding_keys):
            embedding_data_dict[embedding_key] = list(map(lambda x: embedding_values[x][index], range(len(embedding_values))))
        
        self.__embedding_data_dictionay__[keyword_name] = embedding_data_dict

    def __parse_embedding_argument__(self, embedding_argument):
        return list(map(lambda x: x.strip(), embedding_argument.strip('|').split('|')))
    
    def __get_value_of_variable__(self, variableName):
        if variableName == '${EMPTY}':
            return ''
        
        if variableName == '@{EMPTY}':
            return list()
        
        if variableName == '&{EMPTY}':
            return dict()
        
        if '[' in variableName and ']' in variableName: # for list or dict like variable
            variableKey, variableIndex = variableName.strip(']').split('[')
            variableIndex = int(variableIndex) if variableIndex.isnumeric() else variableIndex
            return BuiltIn().get_variable_value(variableKey)[variableIndex]
        
        if variableName.strip('${').strip('}').isnumeric(): # for numeric variable
            return int(variableName.strip('${').strip('}'))
        
        variableDict = BuiltIn().get_variables()
        if variableName in variableDict.keys():
            return BuiltIn().get_variable_value(variableName)
        else:
            return variableName
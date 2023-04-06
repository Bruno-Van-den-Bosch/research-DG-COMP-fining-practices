# This script is the translation of the R script used in the paper
# Bruno Van den Bosch and Friso Bostoen, "Opening the Black Box:
# Uncovering the European Commission’s Cartel Fining Formula through Computational Analysis", Working paper,
# for use for practitioners.
# call all dependencies
import re
import pypdf
import pandas as pd
import sklearn
from sklearn import model_selection
from sklearn import tree
import os




# Part I: create dataframe with all relevant fines and interim amounts of said fine, extracted from given fining decisons
# Dataframe also needs to have all relevent parties linked to each amount


# create all needed classes
class Variable:  # variable class to be used in the search function
    '''
    Class that bundels all information needed for a variable
    '''
    def __init__(self):
        self.name = str
        self.regex = []
        self.party = bool
        self.add_before = bool
        self.exclusion_check = str
        self.distance_party = 150


    def createVariable(self, name, regex, party=False, add_before=True, exclusion=None, distance_party=150):
        '''
        Creates the variables in the class
        '''
        self.name = name
        self.regex = regex
        self.party = party
        self.add_before = add_before
        self.exclusion_check = exclusion
        self.distance_party = distance_party

class Party:  # party to contain all relevant info to be used to predict
    '''
    contains all  information needed per party
    '''
    def __init__(self):
        self.name = str
        self.nominal_fine =  float
        self.base_amount = float
        self.additional_amount = float
        self.duration = float
        self.mitigating_amount = float
        self.aggravating_amount = float
        self.detterence_amount = float
        self.decreases_after_fine = float  # most common would be the Leniency decrease
        self.ability_to_pay = bool
        self.fine_perc_before = float
        self.fine_perc_final = float
        self.sales = float
        self.commissioner = str
        # variables which are created by the model
        self.coded_variables = {}  # structure is "variable_name:bool"


    def calculateFinePercentage(self):
        '''
        Calculates the fine as a percentage from the given amounts
        '''
        self.fine_perc_before = (((self.base_amount * self.duration) + self.additional_amount) * (1+((self.aggravating_amount) - (self.mitigating_amount)))) * (1+self.detterence_amount)
        self.fine_perc_final = self.fine_perc_before * (1-self.decreases_after_fine)


    def calculateSales(self):
        '''
        Calculates the approximated used sales and checks against range
        :return:
        '''
        self.calculateFinePercentage()
        if self.fine_perc_final > 0:
            self.sales = self.nominal_fine / self.fine_perc_final
        else:
            self.sales = 0


    def createParty(self, name,  nominal_fine, base_amount, additional_amount, duration, \
                    mitigating_amount, aggravating_amount, \
                    detterence_amount, decreases_after_fine, ability_to_pay, commissioner):
        '''
        fills in all the necessary steps of the object
        '''
        # create all steps that can be known
        self.name = name
        self.nominal_fine =  float(nominal_fine)
        self.base_amount = float(base_amount)
        self.additional_amount = float(additional_amount)
        self.duration = float(duration)
        self.mitigating_amount = float(mitigating_amount)
        self.aggravating_amount = float(aggravating_amount)
        self.detterence_amount = float(detterence_amount)
        self.decreases_after_fine = float(decreases_after_fine)  # most common would be the Leniency decrease
        self.ability_to_pay = float(ability_to_pay)
        self.commissioner = commissioner
        # calculate the other amounts
        self.calculateSales()


class Decision:
    '''
    Class that bundles information needed from a decision
    '''
    def __init__(self):
        self.decision_name = str
        self.case_number = int
        self.commissioner = str
        self.parties = {} # format as: "party name:party()"
        self.decision_text = str
        self.year = float


# create the used functions
def extractDecisionContent(file_location: str):
    '''
    Reads the decision content into a string
    >>> extractDecisionContent("test_pdf.pdf")
    'This test case PDF is read correctly.\\nThe different lines are checked correctly into one long string.This is the second page text, which is also extracted'
    '''
    assert file_location, "Please entire a location"
    # open file of the decision and read the lines, add lines to long string
    decision_content = ""
    reading_object = pypdf.PdfReader(file_location)
    for page in reading_object.pages:
        # extract all the text in each page
        decision_content += page.extract_text()
    return decision_content

# " TO BE ADDED LATER: Currently Manually"
def identifyDecisionInfo(decision_text: str, pattern_info):
    '''
    Identifies the correct commissioner, decision number and name, and relevant parties
    :param decision_text:
    :return:
    '''


def identifyDecisionParties(decision_text: str, pattern_info):
    '''
    Identify the parties to the decision
    :param decision_text:
    :param pattern_info:
    :return:
    '''


def identifyAmounts(decision_text, parties, interim=True):
    '''
    Identifies the interim amounts by default and the ultimate fine amount per party
    :param decision_text:
    :param parties:
    :param interim:
    :return:
    '''

# Part II: code variables for a given set of variables which can be freely entered
# If  a dataframe exists, read dataframe into all classes
def readInData(location: str, decision_name=None, case_number=None, party_name=None, commissioner=None, nominal_fine=None,
               base_amount=None, additional_amount=None, duration=None, mitigating_amount=None, aggravating_amount=None,
               detterence_amount=None, decreases_after_fine=None, ability_to_pay=None, year=None):
    '''
    Reads in the data from an excel file location. The optional paramater are used to indicate what the titles of the relevant colums are
    '''
    # read in the data
    dataframe = pd.read_excel(location)
    # start create the parties and decisions
    decisions = {}
    case_number_converter ={}
    for index, row in dataframe.iterrows():
        #create party per fine
        party = Party()
        party.createParty(row[party_name], row[nominal_fine], row[base_amount], row[additional_amount], row[duration],
                          row[mitigating_amount], row[aggravating_amount], row[detterence_amount], row[decreases_after_fine], row[ability_to_pay], row[commissioner])
        print("Party has been added: " + row[party_name])
        # check if decision already exists, otherwise create
        try:
            decisions[row[decision_name]].parties[row[party_name]] = party
            print("Party has been added: " + decisions[row[decision_name]].parties[row[party_name]].name)
        except:
            decisions[row[decision_name]] = Decision()
            print("decision has been added: " + row[decision_name])
            decisions[row[decision_name]].decision_name = row[decision_name]
            decisions[row[decision_name]].case_number = row[case_number]
            decisions[row[decision_name]].year = row[year]
            case_number_converter[str(row[case_number])] = row[decision_name]
            decisions[row[decision_name]].parties[row[party_name]] = party
            print("Party has been added: " + decisions[row[decision_name]].parties[row[party_name]].name)
    return decisions, case_number_converter

def addDecisionText(decisions, case_number_converter, main_folder:str):
    '''
    adds all the relevant decisions text to the decision class object, given the correct main folder
    Title  needs to be '[case number] [case name].pdf'
    '''
    for file in os.listdir(main_folder):
        title_content = file.split(' ')
        if title_content[0] in case_number_converter.keys():
            decisions[case_number_converter[title_content[0]]].decision_text = extractDecisionContent(os.path.join(main_folder, file))
            print("Decision text has been added")
        else:
            print("Decision could not be found in decision dictionary, case number: " + title_content[0])


def readVariables(location, name=None, regex=None, party=None, add_before=None, exclusion_check=None, distance_party=None):
    '''
    Reads in the variables from an excel sheet
    '''
    dataframe = pd.read_excel(location)
    variables = {}
    variable_names = []
    for index, row in dataframe.iterrows():
        variable_names.append(row[name])
        print("The following variable  is added: " + row[name])
        variable = Variable()
        variables[row[name]] = variable
        variables[row[name]].createVariable(row[name], row[regex], party=row[party], add_before=row[add_before], exclusion=row[exclusion_check], distance_party=row[distance_party])
        if variables[row[name]].exclusion_check in ('NA', '', ' ', 'Nan', 'NaN'):
            variables[row[name]].exclusion_check = None
    return variables, variable_names


# code variables
def checkVariablePresence(regex_expression, decision_text, party=None, add_before=True, distance_party=150, exclusion_check=None):
    '''
    Checks the presence of a regex expression with a decision text.
    With or without given party, and with or without exclusion check
    Returns Boolean
    :param regex_expression:
    :param decision_text:
    :return:
    '''
    # Compile the correct regex with party added if party is given
    if party != None:
        if add_before:
            search_pattern = re.compile(party + '.' + '{0,' + str(distance_party) + '}' + regex_expression)
        else:
            search_pattern = re.compile(regex_expression + '.' + '{0,' + str(distance_party) + '}' + party)
    else:
        search_pattern = re.compile(regex_expression)
    # Compile the list of potential matches
    result = bool(re.search(search_pattern, decision_text))
    # if exclusion criteria apply check list
    if party != None and exclusion_check != None:
        search_pattern = re.compile(exclusion_check + party + '.' + '{0,' + str(distance_party) + '}' + regex_expression)
        check = bool(re.search(re.compile(search_pattern),decision_text))
    elif exclusion_check != None:
        search_pattern = re.compile(exclusion_check + regex_expression)
        check = bool(re.search(re.compile(search_pattern), decision_text))
    else:
        check = False
    result = bool(not check and result)
    return result


def codeVariables(party: Party, decision: Decision, variables):
    '''
    codes all the variables given the decision text for a given party
    '''
    for variable in variables.values():
        if variable.party:
            name_added = party.name
        else:
            name_added = None
        presence = checkVariablePresence(variable.regex, decision.decision_text, party=name_added, add_before=variable.add_before, distance_party=variable.distance_party, exclusion_check=variable.exclusion_check)
        party.coded_variables[variable.name] = presence

def codeDecision(decision: Decision, variables):
    '''
    Code the variables for all parties in a decision
    '''
    for party in decision.parties.values():
        codeVariables(party, decision, variables)


def createMainDataFrame(decisions, variables):
    '''
    Codes all  the decisions and returns the list of lists with the necessary data contained in a dictionary
    :param decisions:
    :param variables:
    :return:
    '''
    # code all the necessary variables
    for decision in decisions.values():
        codeDecision(decision, variables)
    # create the main dataframe
    main_data_dict = {}
    # create the necessary lists
    for variable in variables.values():
        main_data_dict[variable.name] = []
    main_data_dict["Decision_name"] = []
    main_data_dict["Case_number"] = []
    main_data_dict["Party"] = []
    main_data_dict["Base_amount"] = []
    main_data_dict["Duration"] = []
    main_data_dict["Additional_amount"] = []
    main_data_dict["Aggravating_amount"] = []
    main_data_dict["Mitigating_amount"] = []
    main_data_dict["Detterence_amount"] = []
    main_data_dict["Additional_decreases"] = []
    main_data_dict["Sales"] = []
    main_data_dict["Fine_before_Leniency"] = []
    main_data_dict["Total_fine_percentage"] = []
    main_data_dict["Nominal_fine"] = []
    main_data_dict["Commissioner"] = []
    main_data_dict["Year"] = []
    for decision in decisions.values():
        for party in decision.parties.values():
            # add all the prefilled data
            main_data_dict["Decision_name"].append(decision.decision_name)
            main_data_dict["Case_number"].append(decision.case_number)
            main_data_dict["Year"].append(int(decision.year))
            main_data_dict["Party"].append(party.name)
            main_data_dict["Base_amount"].append(float(party.base_amount))
            main_data_dict["Duration"].append(float(party.duration))
            main_data_dict["Additional_amount"].append(float(party.additional_amount))
            main_data_dict["Aggravating_amount"].append(float(party.aggravating_amount))
            main_data_dict["Mitigating_amount"].append(float(party.mitigating_amount))
            main_data_dict["Detterence_amount"].append(float(party.detterence_amount))
            main_data_dict["Additional_decreases"].append(float(party.decreases_after_fine))
            main_data_dict["Sales"].append(float(party.sales))
            main_data_dict["Fine_before_Leniency"].append(float(party.fine_perc_before))
            main_data_dict["Total_fine_percentage"].append(float(party.fine_perc_final))
            main_data_dict["Nominal_fine"].append(float(party.nominal_fine))
            main_data_dict["Commissioner"].append(party.commissioner)
            # add all the variable data
            for key, val in party.coded_variables.items():
                main_data_dict[key].append(val)
    # create the dataframe
    main_data_frame = pd.DataFrame(data=main_data_dict)
    print("Created DataFrame")
    return main_data_frame, main_data_dict

# Part III: predict fines
def fitModel(dataFrame, variable_names: list or tuple, target: str, test_size=0.15, random_state=None):
    '''
    returns the model when given a dataframe and a target to  fit. DataFrame needs to be given as pandas dataframe
    '''
    # create the test train split
    train, test = model_selection.train_test_split(dataFrame, test_size=test_size, random_state=random_state)
    # initiate the model
    treeModel = tree.DecisionTreeRegressor()
    # create independent variable list
    independents  = train.loc[:, variable_names]
    # create features name list
    feature_names = list(independents.columns)
    dependents = train.loc[:, target]
    # fit the data
    treeModel = treeModel.fit(independents, dependents)
    # score model the model
    summary = {}
    # internal model score
    summary["R2_train_set"] = treeModel.score(independents, dependents)
    # test set score
    independents = test.loc[:, variable_names]
    dependents = test.loc[:, target]
    summary["R2_test_set"] = treeModel.score(independents, dependents)
    # predict test set
    predictions = treeModel.predict(independents)
    # return all info
    return treeModel, summary, predictions, feature_names


def predictFines(DataFrame, variable_names, test_size=0.15, random_state=1):
    '''
    Predicts the entire fine and all the interim amounts, returns a dictionary of dictionnary with all necessary data
    '''
    # predict all interim amounts
    all_models = {}
    for amount in ("Base_amount", "Additional_amount", "Aggravating_amount", "Mitigating_amount", "Detterence_amount"):
        all_models[amount] = fitModel(dataFrame=DataFrame, variable_names=variable_names, target=amount, test_size=test_size, random_state=random_state)
    # predict complete fines
    # create the same test_train split as in the models:
    train, test = model_selection.train_test_split(DataFrame, test_size=test_size, random_state=random_state)
    # locate steps
    base_amount = all_models["Base_amount"][2]
    duration = test.loc[:, "Duration"]
    additional_amount = all_models["Additional_amount"][2]
    aggravating_amount = all_models["Aggravating_amount"][2]
    mitigating_amount = all_models["Mitigating_amount"][2]
    detterence_amount = all_models["Detterence_amount"][2]
    decreases_after_fine = test.loc[:, "Additional_decreases"]
    # fines in percentage
    all_models["fine_before_leniency"] =  [None, None, (((base_amount * duration) + additional_amount) * (
                1 + ((aggravating_amount) - (mitigating_amount)))) * (1 + detterence_amount), all_models["Base_amount"][3]]
    all_models["fine_perc_final"] = [None, None, all_models["fine_before_leniency"][2] * (1 - decreases_after_fine), all_models["Base_amount"][3]]
    # complete fine
    all_models["total_fine"] = [None, None, all_models["fine_perc_final"][2] * test.loc[:, "Sales"], all_models["Base_amount"][3]]
    # resolve R2
    try:
        all_models["fine_before_leniency"][1] = sklearn.metrics.r2_score(test.loc[:, "Fine_before_Leniency"], all_models["fine_before_leniency"][2])
    except:
        all_models["fine_before_leniency"][1] = "try other seed"
    try:
        all_models["fine_perc_final"][1] = sklearn.metrics.r2_score(test.loc[:, "Total_fine_percentage"], all_models["fine_perc_final"][2])
    except:
        all_models["fine_perc_final"][1] = "try other seed"
    try:
        all_models["total_fine"][1] = sklearn.metrics.r2_score(test.loc[:, "Nominal_fine"], all_models["total_fine"][2])
    except:
        all_models["total_fine"][1] = "try other seed"
    # return results
    return all_models

def showDecisionTree(models, commissioner, target, file_location=""):
    '''
    prints the relevant decision tree
    '''
    fig = tree.export_text(models[commissioner][target][0], feature_names=models[commissioner][target][3])
    filename = "decision_tree_"+target+'_commissioner_'+commissioner+'.log'
    with open(os.path.join(file_location, filename), 'w') as document:
        document.write(fig)
        document.write("\nThe summary statistics for this model on "+ target +" by Commissioner "+commissioner +" is\n")
        for key, value in models[commissioner][target][1].items():
            document.write(key+" is :"+ str(value)+"\n")


def predictions(location_data: str, main_folder:str, location_variable:str, name='variable_name', regex='regex', party='party', add_before='add_before',
                exclusion_check='exclusion_check', distance_party='distance_party', decision_name='decision_name', case_number='case_number', year='year', party_name='party_name', commissioner='commissioner', nominal_fine='nominal_fine',
               base_amount='base_amount', additional_amount='additional_amount', duration='duration', mitigating_amount='mitigating_amount', aggravating_amount='aggravating_amount',
               detterence_amount='detterence_amount', decreases_after_fine='decreases_after_fine', ability_to_pay='ability_to_pay', filter_value="Commissioner" ,filter_on=(['Neelie Kroes', 'Joaquin Almunia', 'Margrethe Vestager']), random_state=12, test_size=0.10, file_output_folder="", extra_var_year=True, extra_var_sales=True):  # filter value needs to be value with capital  begin letter (from dataframe)
    '''
    container function to do the actual predictions
    '''
    decisions, case_number_converter = readInData(location_data,decision_name=decision_name,case_number=case_number, year=year, party_name=party_name,commissioner=commissioner,nominal_fine=nominal_fine,base_amount=base_amount,additional_amount=additional_amount,duration=duration,mitigating_amount=mitigating_amount,aggravating_amount=aggravating_amount,detterence_amount=detterence_amount,decreases_after_fine=decreases_after_fine,ability_to_pay=ability_to_pay)
    addDecisionText(decisions, case_number_converter, main_folder=main_folder)
    variables, variable_names = readVariables(location_variable, name=name, regex=regex, party=party, add_before=add_before, exclusion_check=exclusion_check, distance_party=distance_party)
    main_data_frame, main_data_dict = createMainDataFrame(decisions, variables)
    # add year and sales if asked
    if extra_var_year:
        variable_names.append('Year')
    if extra_var_sales:
        variable_names.append('Sales')
    # filter per commissioner
    models = {}
    for commis in filter_on:
        print("this is the filter value: " + commis)
        data_filtered = main_data_frame[main_data_frame[filter_value] == commis]
        print('the number of filtered fines are: ' + str(len(data_filtered.index)))
        models[commis] = predictFines(data_filtered, variable_names, test_size=test_size, random_state=random_state)
        for key, value in models[commis].items():
            print("The model predicts the following value: ")
            print(key)
            print("The model has following characteristics")
            print(value)
            if key not in ("fine_before_leniency", "fine_perc_final", "total_fine", 'Duration'):
                showDecisionTree(models, commis, key, file_location=file_output_folder)
    return models, variable_names


def predictNewFine(models, commissioner, variables, duration, post_fine_reductions, sales=1):  # sales and years are in the variable list
    '''
    predicts the fines in the correct format
    :param models:
    :param location_predict:
    :return:
    '''
    fine = Party()
    fine.base_amount = models[commissioner]["Base_amount"][0].predict(variables)
    fine.additional_amount = models[commissioner]["Additional_amount"][0].predict(variables)
    fine.aggravating_amount = models[commissioner]["Aggravating_amount"][0].predict(variables)
    fine.mitigating_amount = models[commissioner]["Mitigating_amount"][0].predict(variables)
    fine.detterence_amount = models[commissioner]["Detterence_amount"][0].predict(variables)
    fine.decreases_after_fine = post_fine_reductions
    fine.duration = duration
    fine.calculateFinePercentage()
    fine.nominal_fine = float(sales) * float(fine.fine_perc_final)
    return fine.base_amount, fine.additional_amount, fine.aggravating_amount, fine.mitigating_amount, fine.detterence_amount, fine.fine_perc_before, fine.fine_perc_final, fine.nominal_fine

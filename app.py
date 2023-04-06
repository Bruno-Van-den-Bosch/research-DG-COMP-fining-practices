# Script by Bruno Van den Bosch, 6 April 2023
# The following is the user screen for the python translation of the fine prediction model
import os.path

import PySimpleGUI as sg
import pandas as pd
import pickle
from compose_dataset import predictions, predictNewFine, showDecisionTree

def NewModelCreation():
    '''
    GUI for new model creation
    :return:
    '''
    # start opening window for file selection
    sg.theme('Light Blue 1')
    layout = [[sg.Text('Please enter the necessary files to train the model')],
          [sg.Text('Dataset of fines (excel template) :')],
            [sg.InputText(), sg.FileBrowse()],
          [sg.Text('Overview of (possible) variables (excel template) :')],
              [sg.InputText(), sg.FileBrowse()],
        [sg.Text("Folder EC Decisions (file name as: '[case number] [name].pdf', e.g. '123456 cartel.pdf' ")],
              [sg.InputText(), sg.FolderBrowse()],
          [sg.Text("Which Commissioners are in the dataset")],
              [sg.Checkbox('Neelie Kroes', default=True), sg.Checkbox('Joaquin Almunia', default=True), sg.Checkbox('Margrethe Vestager', default=True)],
        [sg.Text("what test set size (in float, e.g. 0.10)")],
              [sg.InputText()],
        [sg.Text("Enter the random integer for the random state")],
              [sg.InputText()],
        [sg.Text("Folder to put resulting decision trees into: ")],
        [sg.InputText(), sg.FolderBrowse()],
        [sg.Text("Use the following also as variable")],
              [sg.Checkbox('year of decision', default=True), sg.Checkbox('sales', default=True)],
          [sg.Submit(), sg.Cancel()]]
    window = sg.Window('EC fine prediction program: new model', layout)
    event, values = window.read()
    window.close()
    # create the correct values
    if event == 'Submit':
        location_data, location_variable, main_folder, Kroes, Almunia, Vestager, test_size, random_state, output_folder, extra_var_year, extra_var_sales = values[0], values[1], values[2], values[3], values[4], values[5], float(values[6]), int(values[7]), values[8], values[9], values[10]             # get the data from the values dictionary
        # start the program
        if Kroes == Almunia == Vestager == True:
            filters = ['Neelie Kroes', 'Joaquin Almunia', 'Margrethe Vestager']
        elif Almunia == Vestager == True:
            filters = ['Joaquin Almunia', 'Margrethe Vestager']
        elif Kroes == Almunia == True:
            filters = ['Neelie Kroes', 'Joaquin Almunia']
        elif Kroes == Vestager == True:
            filters = ['Neelie Kroes', 'Margrethe Vestager']
        elif Kroes == True:
            filters = ['Neelie Kroes']
        elif Almunia == True:
            filters = ['Joaquin Almunia']
        elif Vestager == True:
            filters = ['Margrethe Vestager']
        else:
            filters = ['Margrethe Vestager']
        sg.theme('Light Blue 1')
        if output_folder[-1] != '/':
            output_folder = output_folder + '/'
        sg.popup_quick_message('Model in progress. Given large datasets, this could take a while. Please wait.')
        # create the model and create the decision tree files
        models, variable_names = predictions(location_data, main_folder, location_variable, filter_on=(filters), filter_value="Commissioner", test_size=test_size, random_state=random_state, file_output_folder=output_folder, extra_var_year=extra_var_year, extra_var_sales=extra_var_sales)  # filter value needs to be value with capital  begin letter (from dataframe)
        return models, variable_names, extra_var_year, extra_var_sales

def loadLastModel():
    '''
    If the object exists load last model
    '''
    try:
        sg.theme('Light Blue 1')
        layout = [[sg.Text('select the binary file of the model (were you saved it last time: '), sg.InputText(), sg.FileBrowse()]
        ,[sg.Submit(), sg.Cancel()]]
        window = sg.Window('Choose previous model from file', layout)
        event, values = window.read()
        if event == 'Submit':
            fileObj = open(values[0], 'rb')
            first_return = pickle.load(fileObj)  #  models, variable_names, extra_var_year, extra_var_sales
            fileObj.close()
            window.close()
            # ask where to save the decision trees
            sg.theme('Light Blue 1')
            layout = [[sg.Text("Select the location to save the decision trees, otherwise just hit 'do not save': "), sg.InputText(),
                       sg.FolderBrowse()]
                , [sg.Submit(), sg.Button("do not save")]]
            window = sg.Window('Choose previous model from file', layout)
            event, values = window.read()
            window.close()
            # save all trees if asked
            if event == 'Submit':
                for commis, value in first_return[0].items():
                    for key, value in first_return[0][commis].items():
                        if key not in ("fine_before_leniency", "fine_perc_final", "total_fine", 'Duration'):
                            showDecisionTree(first_return[0], commis, key, file_location=values[0])
        else:
            first_return = False
    except:
        sg.popup_ok("there is no model to load")
        first_return = NewModelCreation()
    return first_return  # models, variable_names, extra_var_year, extra_var_sales

def welcomeScreen():
    sg.theme('Light Blue 1')
    layout = [[sg.Text("Welcome to the EC fine prediction application (interpret results with caution)")],
              [sg.Text("Do you want to load the previous model, or make a new one: ")],
              [sg.Button('new'), sg.Button('previous model')]]
    window = sg.Window('EC fine prediction program: welcome', layout)
    event, values = window.read()
    window.close()
    if event == 'new':
        first_return = NewModelCreation()  #models, variable_names, extra_var_year, extra_var_sales
    elif event == 'previous model':
        first_return = loadLastModel()
    else:
        first_return = False
    return first_return  # models, variable_names, extra_var_year, extra_var_sales

# start screen to predict fines
def finePredictionScreen(models, variable_names, extra_var_year, extra_var_sales):
    '''
    Program to predict fines after a model was created
    '''
    sg.theme('Light Blue 1')
    layout = [[sg.Text('please select the variables of the fine to predict')]]
    count = 0
    for name in variable_names[:-2]:
        layout.append([sg.Checkbox(name, default=False)])
        count += 1
    layout.append([sg.Text("duration: "), sg.InputText()])
    layout.append([sg.Text("post fine reduction e.g. leniency: "), sg.InputText()])
    layout.append([sg.Checkbox('EC Vestager', default=False)])
    layout.append([sg.Checkbox('EC Almunia', default=False)])
    layout.append([sg.Checkbox('EC Kroes', default=False)])
    layout.append([sg.Text("sales: "), sg.InputText()])
    layout.append([sg.Text("case year: "), sg.InputText()])
    layout.append([sg.Submit(), sg.Cancel()])
    window = sg.Window('New case prediction selection', layout)
    event, values = window.read()
    window.close()
    if event == 'Submit':
        if values[count+2]:
            commissioner = 'Margrethe Vestager'
        elif values[count+3]:
            commissioner = 'Joaquin Almunia'
        elif values[count + 3]:
            commissioner = 'Neelie Kroes'
        else:
            commissioner = 'Margrethe Vestager'
        variables = []
        for i in range(0, count):
            variables.append(values[i])
        input_vars = {}

        if extra_var_year == extra_var_sales == False:
            i = 0
            for var_name in variable_names:
                input_vars[var_name] = [variables[i]]
                i += 1
        elif extra_var_sales == False:
            i = 0
            for var_name in variable_names[:-1]:
                input_vars[var_name] = [variables[i]]
                i += 1
            input_vars["Sales"] = [float(values[count + 4])]
        elif extra_var_year == False:
            i = 0
            for var_name in variable_names[:-1]:
                input_vars[var_name] = [variables[i]]
                i += 1
            input_vars["Year"] = [int(values[count + 5])]
        else:
            i = 0
            for var_name in variable_names[:-2]:
                input_vars[var_name] = [variables[i]]
                i += 1
            input_vars["Year"] = [int(values[count + 5])]
            input_vars["Sales"] = [float(values[count + 4])]
        variables = pd.DataFrame(input_vars)
        prediction_fine = predictNewFine(models, commissioner, variables, float(values[count]), float(values[count+1]), sales=float(values[count + 4]))
    else:
        prediction_fine = False
    return prediction_fine

# function to save model
def saveModelObject(models, variable_names, extra_var_year, extra_var_sales):
    '''
    Saves the model
    '''

    sg.theme('Light Blue 1')
    layout = [[sg.Text('Give the model a name (name must be given): ')],
                [sg.InputText()],
        [sg.Text('Give a location to save the model (as binary): ')],
        [sg.InputText(), sg.FolderBrowse()],
        [sg.Submit()]]
    window = sg.Window('Save model: enter model name', layout)
    event, values = window.read()
    if event == 'Submit':
        model_name = values[0] + '.obj'
        window.close()
        full_dir = os.path.join(values[1])
        if not os.path.exists(full_dir):
            os.makedirs(full_dir)
        save_location = os.path.join(values[1], model_name)
        fileObj = open(save_location, 'wb')
        save_object = (models, variable_names, extra_var_year, extra_var_sales)
        pickle.dump(save_object, fileObj)
        fileObj.close()
        out = True
    else:
        out = False
    return out


# ask user if they want to predict a new case
def modelLoadedScreen(models):
    sg.theme('Light Blue 1')
    layout = [[sg.Text('EC fine prediction program')],
              [sg.Text('The model has been trained on the given data. The decision tree can be found in the output folder')],
        [sg.Text('The models accuracy on the fine is currently: ')]]
    for key, value in models.items():
        layout.append([sg.Text('fine before leniency in percentage for ' + key +' - ' + str(value["fine_before_leniency"][1]))])
        layout.append([sg.Text('fine as nominal amount for ' + key +' with leniency - ' + str(value["total_fine"][1]))])
    layout.append([sg.Text('Do you want to predict a new fine based on the variables of the case? click submit otherwise cancel or leave.')])
    layout.append([sg.Text('If you want to save the current model for later use, check the box: ')])
    layout.append([sg.Checkbox('Save current model', default=False)])
    layout.append([sg.Submit(), sg.Cancel()])
    window = sg.Window('Model has been created', layout)
    event, values = window.read()
    window.close()
    next_step = bool(event == 'Submit')
    # save the model if so asked
    if values[0]:
        next_step = saveModelObject(models, variable_names, extra_var_year, extra_var_sales)
    return next_step


def casePredictionsLoop(models, variable_names, extra_var_year, extra_var_sales):
    '''
    loops for as long as user submits new cases
    :return:
    '''
    # start fine predicition screen
    finepredictions = finePredictionScreen(models, variable_names, extra_var_year, extra_var_sales)
    # show results and ask to predict a new fine
    while finepredictions:
        if finepredictions != False:
            sg.theme('Light Blue 1')
            layout = [[sg.Text('The prediction of the current model for those variables is: ')],[sg.Text('(interpret with caution)')],
                      [sg.Text('Base amount: ' + str(finepredictions[0]))],
                      [sg.Text(" Additional amount: " +str(finepredictions[1]))],
                      [sg.Text(" Aggravating amount: " + str(finepredictions[2]))],
                      [sg.Text('Mitigating amount: '+str(finepredictions[3]))],
                      [sg.Text('Detterence amount: ' + str(finepredictions[4]))],
                      [sg.Text('Amount before leniency and exceptional reductions (percentage): '+ str(finepredictions[5]))],
                      [sg.Text('Total fine (percentage) amount with additional decreases: ' + str(finepredictions[6]))],
                      [sg.Text('These predictions are only as good as the model, please interpret with caution')],
                        [sg.Text('The models accuracy on the fines from the dataset is currently: ')]]
            for key, value in models.items():
                layout.append(
                    [sg.Text('Fine before leniency in percentage for ' + key + ' - ' + str(value["fine_before_leniency"][1]))])
                layout.append([sg.Text('Fine as nominal amount for ' + key + ' with leniency - ' + str(value["total_fine"][1]))])
            layout.append([sg.Text('Do you want to predict another new fine based on the variables of the case? click submit (otherwise leave)')])
            layout.append([sg.Submit(), sg.Button('Exit')])
            window = sg.Window('EC Fine Prediction Results', layout)
            event, values = window.read()
            if event == sg.WIN_CLOSED or event == 'Exit':
                break
            finepredictions = finePredictionScreen(models, variable_names, extra_var_year, extra_var_sales)
            window.close()


######## START ACTUAL PROGRAM ###########
# start the first screen
first_return = welcomeScreen()
# only continue if there is a first return
if first_return:
    models, variable_names, extra_var_year, extra_var_sales = first_return
    # check whether user wants to predict fines. Model will be saved if box is checked even when cancelling
    if modelLoadedScreen(models):
        # start loop
        casePredictionsLoop(models, variable_names, extra_var_year, extra_var_sales)

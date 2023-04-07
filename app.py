# This script is a 'EC cartel fine prediction app':
# the GUI for the script for translation of the R script used in the paper (note that this translation is not exact)
# Bruno Van den Bosch and Friso Bostoen, "Opening the Black Box:
# Uncovering the European Commission’s Cartel Fining Formula through Computational Analysis", Working paper.
# This script is made for use for practitioners.
# This script is distributed onder the GNU General Public license
import os.path
import PySimpleGUI as sg
import pandas as pd
import pickle
from compose_dataset import predictions, predictNewFine, showDecisionTree

def NewModelCreation():
    '''
    GUI for new model creation
    '''
    # start opening window for file selection
    sg.theme('Light Blue 1')
    col_layout = [[sg.Text('Please enter the necessary files to train the model')],
          [sg.Text('Dataset of fines (excel template) :')],
            [sg.InputText(), sg.FileBrowse()],
          [sg.Text('Overview of (possible) variables (excel template) :')],
              [sg.InputText(), sg.FileBrowse()],
        [sg.Text("Folder EC Decisions (file name as: '[case number] [name].pdf', e.g. '123456 cartel.pdf' ")],
              [sg.InputText(), sg.FolderBrowse()],
          [sg.Text("Filter dataset on (one option) WARNING enough cases need to be in each group: ")],
              [sg.Checkbox('Commissioner', default=True), sg.Checkbox('Year', default=False),sg.Text('Variable name: '),sg.InputText()],
        [sg.Text("what test set size (in float, e.g. 0.15)")],
              [sg.InputText(default_text=0.15)],
        [sg.Text("Enter the random integer for the random state")],
              [sg.InputText(default_text=12)],
        [sg.Text("Folder to put resulting decision trees into: ")],
        [sg.InputText(), sg.FolderBrowse()],
        [sg.Text("Use the following also as variable")],
              [sg.Checkbox('year of decision', default=True), sg.Checkbox('sales', default=True)],
        [sg.Text("What maximum depth for the decision tree: ")],
              [sg.InputText(default_text=6)],
          [sg.Submit(), sg.Cancel()]]
    layout = [[sg.Column(col_layout, scrollable=True, vertical_scroll_only=True, size_subsample_height=2)]]
    window = sg.Window('EC fine prediction program: new model', layout)
    event, values = window.read()
    window.close()
    # create the correct values
    if event == 'Submit':
        try:
            location_data, location_variable, main_folder, Commissioner, Year, Var_name, test_size, random_state, output_folder, extra_var_year, extra_var_sales, max_depth = values[0], values[1], values[2], values[3], values[4], values[5], float(values[6]), int(values[7]), values[8], values[9], values[10], int(values[11])             # get the data from the values dictionary
            # start the program
            if Commissioner:
                filter_value = "Commissioner"
            elif Year:
                filter_value = "Year"
            elif Var_name not in  (' ', '', '  ','   ',None):
                filter_value = Var_name
            else:
                filter_value = "Commissioner"
            sg.theme('Light Blue 1')
            sg.popup_quick_message('Model in progress. Given large datasets, this could take a while. Please wait.')
            # create the model and create the decision tree files
            models, variable_names = predictions(location_data, main_folder, location_variable, filter_value=filter_value, test_size=test_size, random_state=random_state, file_output_folder=output_folder, extra_var_year=extra_var_year, extra_var_sales=extra_var_sales, max_depth=max_depth)  # filter value needs to be value with capital  begin letter (from dataframe)
            output_values = (models, variable_names, extra_var_year, extra_var_sales)
        except:
            sg.popup_ok('Something went wrong with the entered values.\n Did you leave certain values blank and are all your values valid?\n Or, not enough cases featured in each group')
            output_values = False
        return output_values

def loadLastModel():
    '''
    If the object exists load last model
    '''
    try:
        sg.theme('Light Blue 1')
        layout = [[sg.Text('select the binary file of the model (.obj extension): '), sg.InputText(), sg.FileBrowse()]
        ,[sg.Submit(), sg.Cancel()]]
        window = sg.Window('Choose previous model from file', layout)
        event, values = window.read()
        window.close()
        if event == 'Submit':
            fileObj = open(values[0], 'rb')
            first_return = pickle.load(fileObj)  #  models, variable_names, extra_var_year, extra_var_sales
            fileObj.close()
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
              [sg.Text("Do you want to load an existing model, or make a new one: ")],
              [sg.Button('new'), sg.Button('existing model')]]
    window = sg.Window('EC fine prediction program: welcome', layout)
    event, values = window.read()
    window.close()
    if event == 'new':
        try:
            first_return = NewModelCreation()  #models, variable_names, extra_var_year, extra_var_sales
        except:
            sg.popup_ok('The model could not be created.\nA common error is leaving Commissioners checked when they do not feature in the dataset, or not using the correct template.\nPlease relaunch program.')
            first_return = False
    elif event == 'existing model':
        first_return = loadLastModel()
    else:
        first_return = False
    return first_return  # models, variable_names extra_var_year, extra_var_sales

# start screen to predict fines
def finePredictionScreen(models, variable_names, extra_var_year, extra_var_sales):
    '''
    Program to predict fines after a model was created
    '''
    sg.theme('Light Blue 1')
    layout = [[sg.Text('please select the variables of the fine to predict')]]
    count = 0
    for name in variable_names:
        if name not in ('Year', 'Sales'):
            layout.append([sg.Checkbox(name, default=False)])
            count += 1
    count -= 1  # count is now the values position of each variable
    layout.append([sg.Text("duration (in years, float accepted): "), sg.InputText(default_text=1)]) # count +1
    layout.append([sg.Text("post fine reduction e.g. leniency: "), sg.InputText(default_text=0)])  # count +2
    layout.append([sg.Text("sales: "), sg.InputText(default_text=10000)]) # count +3
    layout.append([sg.Text("case year: "), sg.InputText(default_text=2023)])  # count +4
    count_2 = 0
    layout.append([sg.Text("Select the group you want to predict on (filter values): ")])
    for commis in models.keys():
        layout.append([sg.Checkbox(commis, default=False)])
        count_2 += 1
    layout.append([sg.Submit(), sg.Cancel()])
    win_layout = [[sg.Column(layout, scrollable=True, vertical_scroll_only=True, size_subsample_height=2)]]
    window = sg.Window('New case prediction selection', win_layout)
    event, values = window.read()
    window.close()
    if event == 'Submit':
        try:
            commissioner = list(models.keys())[-1]
            for el in range(0, len(models.keys())):
                if values[count+4+1+el] is True:
                    commissioner = list(models.keys())[int(el)]
            variables = []
            for i in range(0, count+1):
                variables.append(values[i])
            input_vars = {}

            if extra_var_year is False and extra_var_sales is False:
                i = 0
                for var_name in variable_names:
                    input_vars[var_name] = [variables[i]]
                    i += 1
            elif extra_var_year is True and extra_var_sales is True:
                for i in range(0, count+1):
                    input_vars[variable_names[i]] = [variables[i]]
                input_vars["Year"] = [int(values[count + 4])]
                input_vars["Sales"] = [float(values[count + 3])]
            elif extra_var_sales is True:
                for i in range(0, count+1):
                    input_vars[variable_names[i]] = [variables[i]]
                input_vars["Sales"] = [float(values[count + 3])]
            elif extra_var_year is True:
                for i in range(0, count+1):
                    input_vars[variable_names[i]] = [variables[i]]
                input_vars["Year"] = [int(values[count + 4])]
            variables = pd.DataFrame(input_vars)
            if commissioner in models.keys():
                prediction_fine = predictNewFine(models, commissioner, variables, float(values[count+1]), float(values[count+2]), sales=float(values[count + 3]))
            else:
                sg.popup_ok('You opted to predict for a group which is not in the loaded model. \nplease restart program en load the correct model or create a new one')
                prediction_fine = False
        except:
            sg.popup_ok('Something went wrong with entering the variables.\n A common error is  leaving the fill in values blank, or selecting a filter on a value with to few cases.')
            prediction_fine = False
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
                [sg.InputText(default_text="My_new_model")],
        [sg.Text('Give a location to save the model (as binary): ')],
        [sg.InputText(), sg.FolderBrowse()],
        [sg.Submit()]]
    window = sg.Window('Save model: enter model name', layout)
    event, values = window.read()
    window.close()
    if event == 'Submit':
        model_name = values[0] + '.obj'
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
    layout.append([sg.Button('Predict case'), sg.Exit()])
    win_layout = [[sg.Column(layout, scrollable=True, vertical_scroll_only=True, size_subsample_height=2)]]
    window = sg.Window('Model has been created', win_layout)
    event, values = window.read()
    window.close()
    next_step = bool(event == 'Predict case')
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
                      [sg.Text('Total fine (nominally) with additional decreases: ' + str(finepredictions[7]))],
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
            window.close()
            if event == sg.WIN_CLOSED or event == 'Exit':
                break
            finepredictions = finePredictionScreen(models, variable_names, extra_var_year, extra_var_sales)


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

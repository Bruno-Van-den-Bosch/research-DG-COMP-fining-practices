# The following is the user screen for the python translation of the fine prediction model
import PySimpleGUI as sg
import pandas as pd
from compose_dataset import predictions, predictNewFine

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
window = sg.Window('EC fine prediction program', layout)
event, values = window.read()
window.close()
# create the correct values
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

# start screen to predict fines
def finePredictionScreen():
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
    return prediction_fine

# ask user if they want to predict a new case
sg.theme('Light Blue 1')
layout = [[sg.Text('EC fine prediction program')],
          [sg.Text('The model has been trained on the given data. The decision tree can be found in the output folder')],
    [sg.Text('The models accuracy on the fine is currently: ')]]
for key, value in models.items():
    layout.append([sg.Text('fine before leniency in percentage for ' + key +' - ' + str(value["fine_before_leniency"][1]))])
    layout.append([sg.Text('fine as nominal amount for ' + key +' with leniency - ' + str(value["total_fine"][1]))])
layout.append([sg.Text('Do you want to predict a new fine based on the variables of the case? click submit otherwise cancel or leave.')])
layout.append([sg.Submit(), sg.Cancel()])
window = sg.Window('Model has been created', layout)
event, values = window.read()
window.close()
# start fine predicition screen
finepredictions = finePredictionScreen()
# show results and ask to predict a new fine
while True:
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
    layout.append([sg.Submit()])
    window = sg.Window('EC Fine Prediction Results', layout)
    event, values = window.read()
    window.close()
    finepredictions = finePredictionScreen()


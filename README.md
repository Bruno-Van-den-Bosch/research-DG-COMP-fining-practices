# Research-DG-COMP-fining-practices

This repository bundles all code and files used in Bruno Van den Bosch and Friso Bostoen, "Opening the Black Box: Uncovering the European Commission’s Cartel Fining Formula through Computational Analysis" (SSRN: https://ssrn.com/abstract=4232335).

### Information on the branch

This branch contains the python files which can be used to create a fine prediction application. However, the "template" files need to be used instead of the Annex files.

The application produces a model to predict fines based on a (largely) similar method as in the R script from the paper. Next, the user can predict new cases by identifing the variables. The GUI shows the predicted interim amounts and the fine in percentage.

## Paper Abstract

While abuse of dominance fines have received plenty of attention, most of the European Commission’s fines target cartels. The Fining Guidelines, in particular their most recent version (2006), have increased the transparency of how the Commission calculates those fines. However, the precise factors determining the fine as well as the exact quantification remained unknown, which is why the fine-setting process has been likened to a ‘black box’. This article opens that black box by computationally and doctrinally assessing all cartel fines based on the Fining Guidelines from 2006 until 2020. In doing so, we also test the ‘protectionist hypothesis’, which holds that the Commission uses antitrust enforcement to disadvantage non-EU and in particular U.S. firms. For some steps of the fine calculation (the base amount and entry fee) and for some Commissioners (Almunia and Vestager), we find a remarkably consistent methodology. This methodology offers no evidence of the protectionist hypothesis and, to the extent that there is any indication of it, bias would be aimed at Asian rather than U.S. firms. In addition, the uncovered fining methodology reveals that the Commission plays it very safe when setting cartel fines, which is why we call for more boldness. At the same time, the General Court should subject the Commission’s fines to more scrutiny, especially when it comes to equal treatment over time (rather than between parties in the same decision).

## Content of Git

This repository contains the R script model which automatically codes the variables for each party given the prohibition decision using regex expressions. The second part of the same R script then uses the variables to predict European Commission fines in cartel cases using the RPart method.

The files are:

1. Annex 1: The overview of the cartel fines per party as used in the paper, with the interim amounts given. This excel was composed manually by the authors.

2. Annex 2: The overview of the Anova tests as descriped in the paper. These tests were run manually in libreOffice Calc.

3. Annex 3: The actual R script model which generates all the plots of the decision trees for each amount per Commissioner and the interim dataframes (containing the coded variables). The titles of the files contain the summary statistics of each output and the seed used to generate the output. 

4. Annex 4: The interim dataframe as generated by the first part of Annex 3. In case the user does not have all the prohibition decisions, the second part of the script can be run at the jumping-off point as indicated in the script when given the location of Annex 4. The output will be all the decision trees and plots as generated for the writing of the paper.

5. compose_dataset.py: This python script contains all the relevant functions for the application to work.

6. app.py: This script contains the GUI. When this script is run, the app starts.

7. template_fining_data.xlsx: this template needs to be fed into the python application (through the GUI). This template can be extended or shortened (for faster run time).

8. template_variables.xlsx: this template contains all current variables with the relevant regex expressions. This template needs to be fed to  the application (through the GUI). This template can be extended or changed, yet top row needs to stay the same. 

9. Complete_cartel_model_saved.obj: this is the saved object created out of the template files and all the relevant EC decisions. This obj can be loaded into the app and used to predict fines. The decision trees can also be saved to a folder of the users choosing. 

## Using the application

To  use the application the following dependencies need to be installed:

- PySimpleGUI
- pandas
- re
- pypdf
- sklearn
- scikit-learn
- openpyxl
- os

This  can be done through 'pip install 'dependencies_name''.

Next, the app.py app needs to be launched (in terminal (app.py and compose-dataset need to be in the same folder): python3 'app.py'). When launched the app will give the choice between creating a new model or load an existing one.

#### new model:

The app will ask for the location of the template excels, the location of the relevant fining decisions (in the same format as below, meaning '[case number] [name].pdf', e.g. '12345 cartel.pdf'), which commissioners feature in the dataset, a location to save the resulting decision trees, a seed to ensure reproducibility, the largeness of the test set, and whether to include sales and/or the decision year as a variable.

After hitting submit, the script will start running and a message will be displayed while the script runs. Be aware that large dataset will take considerable time. Next, the relevant files will be saved in the given location and the summary statistics will be given. The summary statistic per interim amount can be found below the decision tree.

#### loading existing model:

The app will let you browse your files to select the model you want to use. The app will then ask if you want to save the relevant decision trees, and if so at what location. You can make prediction using the loaded model on the next screen.

### predicting the fines

Lastly, new cases can be predicted. After hitting submit a selection menu will open. Users need to fill in all free values (sales, duration, year), ticking a box means the variable is present, leaving it unticked means not present in the case.

The app will show the predictions based on the trained model and ask whether a new fine needs to be predicted. To close the app, close the window, then close the selection menu. This is a known issue, yet the program will have stopped.

This app.py script can be made into an application using the standard methods (e.g. pyinstaller: user manual - https://pyinstaller.org/en/stable/). Make sure all dependencies are installed. This can be checked by launching the .py file in terminal, running through the app and check terminal if any missing module errors are given.

final remarks: the run time can be considerable with very large datasets. To reduce wait time, run the script per Commissioner. This can be done by copying the template file, deleting the other EC's fines and only leaving the box for the relevant Commissioner checked. 

When predicting new cases, if multple Commissioners are checked, only the fine according to the most recent Commissioner is predicted.

## Using the ANNEX script

To use the script the following input needs to be added at the top of the script as indicated:

1. The location of Annex 1.

2. The location of the folder containing all the relevant prohibition decisions (in English, or translated in English) in pdf format with the name of the pdf files as '[case number (only numeral)] [case name].pdf' (e.g. '38121 Fittings.pdf'). 

3. A location to save the output of the script.

### Extending the current dataset for ANNEX script

To model new fines:

1. Annex 1 needs to be extended manually.

2. In case of a new Commissioner, lines 433 till 437 of the script need to be extended.

3. Beware that the current dataset contains too few cases with interim amounts for certain Commissioners. These amounts cannot be predicted. Therefore the model has an 'if else' structure excluding certain steps in the model for certain Commissioners. The list of Commissioners on line 437 thus needs to  be maintained.

4. When using a completely different dataset, the headers in the excel need to  be the same for the script to work. The previous comment needs to be taken into account and if the concern does not apply the 'if else' structure needs to be adapted.

5. To add new variables or change the coding of the variables lines 172 till 205 of the script can be extended. The variable name of new lists needs to be added to the list on line 208 till 211. Depending on whether the name of the party needs to be added to the regex and depending on whether an extra check (e.g. 'commission does not') needs to be added, the variable has to be added in one of the lists. Check the code itself to decide. The variables are in the order they appear in the list from line 208 till 211. 

## License

Since this code was made for academic purposes, the code is distributed under the GNU General Public license (as found here). Users (generally) thus have the right to Run, Study, Share, and Modify the code.

## Questions and problems

This repository is used for the transparancy of the research. Issues can be raised yet the main branch will generally not be updated since we already analysed the results. Researchers are free to branch this project and adapt to their needs, in accordance with the license. 

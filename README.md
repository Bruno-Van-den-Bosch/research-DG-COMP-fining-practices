DISLAIMER: THIS APPLICATION IS NO SUBSTITUTE FOR A SOUND LEGAL ANALYSIS. THE AUDIENCE OF THIS APPLICATION IS ACADEMICS AND LEGAL PRACTITIONERS AS A TOOL AND STARTING POINT TO ASSESS AND EVALUATE FINES. IN THAT VEIN I WANT TO DRAW ATTENTION TO THE FINING GUIDELINES WHICH CLEARLY STATES THE EC HAS THE RIGHT TO DEVIATE FROM THE METHODOLOGY SET FORTH IN THE GUIDELINES IF THEY SEE FIT. ADDITIONAL THE MODELS AS PRESENTED HERE ARE NOT LAW NOR SOFT LAW BUT A REVERSE ENGINEER EXCERCISE OF PAST POLICY DECISIONS. USE THESE MODELS AT YOUR OWN RISK.  
# Research-DG-COMP-fining-practices

This repository bundles all code and files used in Bruno Van den Bosch and Friso Bostoen, "Opening the Black Box: Uncovering the European Commission’s Cartel Fining Formula through Computational Analysis" (SSRN: https://ssrn.com/abstract=4232335).

### Information on the branch

This branch contains the python files which can be used to create a fine prediction application. However, the "template" files need to be used instead of the Annex files.

The application produces a model to predict fines based on a (largely) similar method as in the R script from the paper. Next, the user can predict new cases by identifing the variables. The GUI shows the predicted interim amounts and the fine in percentage.

There are premade models (generated from the template files with different settings). When launching the python application these models can be loaded into the model. The fine amount decision trees from these models can be saved and new cases can be predicted with the interactive menu.

The dataset of fines in the template from the python application extents to the end of 2022 (the dataset for the paper is up to 2020).

## Paper Abstract

While abuse of dominance fines have received plenty of attention, most of the European Commission’s fines target cartels. The Fining Guidelines, in particular their most recent version (2006), have increased the transparency of how the Commission calculates those fines. However, the precise factors determining the fine as well as the exact quantification remained unknown, which is why the fine-setting process has been likened to a ‘black box’. This article opens that black box by computationally and doctrinally assessing all cartel fines based on the Fining Guidelines from 2006 until 2020. In doing so, we also test the ‘protectionist hypothesis’, which holds that the Commission uses antitrust enforcement to disadvantage non-EU and in particular U.S. firms. For some steps of the fine calculation (the base amount and entry fee) and for some Commissioners (Almunia and Vestager), we find a remarkably consistent methodology. This methodology offers no evidence of the protectionist hypothesis and, to the extent that there is any indication of it, bias would be aimed at Asian rather than U.S. firms. In addition, the uncovered fining methodology reveals that the Commission plays it very safe when setting cartel fines, which is why we call for more boldness. At the same time, the General Court should subject the Commission’s fines to more scrutiny, especially when it comes to equal treatment over time (rather than between parties in the same decision).

## Content of Git

This repository contains the R script model which automatically codes the variables for each party given the prohibition decision using regex expressions. The second part of the same R script then uses the variables to predict European Commission fines in cartel cases using the RPart method.

The files are:

1. Annex 1: The overview of the cartel fines per party as used in the paper, with the interim amounts given. This excel was composed manually by the authors.

2. Annex 2: The overview of the Anova tests as descriped in the paper. These tests were run manually in libreOffice Calc.

3. Annex 3: The actual R script model which generates all the plots of the decision trees for each amount per Commissioner and the interim dataframes (containing the coded variables). The titles of the files contain the summary statistics of each output and the seed used to generate the output. 

4. Annex 4: The interim dataframe as generated by the first part of Annex 3. In case the user does not have all the prohibition decisions, the second part of the script can be run at the jumping-off point as indicated in the script when given the location of Annex 4. The output will be all the decision trees and plots as generated for the writing of the paper.

5. The python application folder contains:

5.1. the python script files being:
  
5.1.a compose_dataset.py: This python script contains all the relevant functions for the application to work.
  
5.1.b app.py: This script contains the GUI. When this script is run, the app starts.

5.3 the template files needed for the python application being:
    
5.3.a template_fining_data.xlsx: this template needs to be fed into the python application (through the GUI). This template can be extended or shortened (for faster run time).
    
5.3.b template_variables.xlsx: this template contains all current variables with the relevant regex expressions. This template needs to be fed to  the application (through the GUI). This template can be extended or changed, yet top row needs to stay the same. 

5.5 pre_made_py_models folder: this folder contains saved objects created out of the template files and all the relevant EC decisions. These files can be loaded into the app and used to predict fines. The decision trees can also be saved to a folder after loading the model. Be warned: These models are all made using the template files but differ in settings (indicated in their titles). This means their accuracy is different. For example the unlimited depth model has a R2 of 1. in the training set but a bad score on the test sets. The models with fewer depth (meaning less decision tree levels) are more accurate on the test sets since there is fewer overfitting. the file titles (and settings) are:
    
5.5.a model_depth_4_seed_21_test_005.obj
    
5.5.b model_depth_4_seed_21_test_015.obj
    
5.5.c model_depth_6_seed_12_test_005.obj
    
5.5.d model_depth_6_seed_12_test_015.obj

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

This  can be done through in terminal, linux: 'pip install 'dependencies_name' or windows (in cmd): py -m pip install 'dependencies_name'. Of course python needs to be installed already.

This app.py script can be made into an application using the standard methods (e.g. pyinstaller: user manual - https://pyinstaller.org/en/stable/). Make sure all dependencies are installed. This can be checked by launching the .py file in terminal, running through the app and check terminal if any missing module errors are given. On linux the exe can be created by going to the directory of the application (cd 'file path') in terminal, then entering ' pyinstaller --onefile app.py ' (exclude '' ). You will find the application in the newly created 'dist' folder at the folder location. In windows also change directory to that of the app.py and compose_dataset.py script, then run ' py -m PyInstaller --onefile --windowed app.py ' (exclude '' ). The application will also be found in the newly created dist folder.

DISCLAIMER: this information is given only as a guide, please use other resources especially the pyinstaller manual when encountering problems

When not creating an exe program with pyinstaller, the app.py app needs to be launched (in terminal: python3 'app.py')(app.py and compose-dataset need to be in the same folder). When launched the app will give the choice between creating a new model or load an existing one.


#### new model:

The app will ask for the location of the template excels, the location of the relevant fining decisions (in the same format as below, meaning '[case number] [name].pdf', e.g. '12345 cartel.pdf'), on which value the data needs to be filtered into groups (make sure enough fines are in each group. If only one group, e.g. one commissioner, just filter on that label, in e.g. this  would be Commissioner), a location to save the resulting decision trees, a seed to ensure reproducibility, the largeness of the test set, and whether to include sales and/or the decision year as a variable.

After hitting submit, the script will start running and a message will be displayed while the script runs. Be aware that large dataset will take considerable time. Next, the relevant files will be saved in the given location and the summary statistics will be given. The summary statistic per interim amount can be found below the decision tree.

final remarks: the run time can be considerable with very large datasets. To reduce wait time, run the script per Commissioner or group. This can be done by copying the template file, deleting the other EC's fines and only leaving the box for the relevant Commissioner checked. Limiting depth can often reduce over fitting. Run multiple models with different seeds and depth to fine tune the best decision tree and prediction model.

#### loading existing model:

The app will let you browse your files to select the model you want to use. The app will then ask if you want to save the relevant decision trees, and if so at what location. You can make prediction using the loaded model on the next screen.

### predicting the fines

Lastly, new cases can be predicted. After hitting submit a selection menu will open. Users need to fill in all free values (sales, duration, year), ticking a box means the variable is present, leaving it unticked means not present in the case.

The app will show the predictions based on the trained model and ask whether a new fine needs to be predicted. To close the app, close the window, then close the selection menu. This is a known issue, yet the program will have stopped.

When predicting new cases, if multple groups are checked, only the fine according to the last first checked value is predicted. If none is checked, the last group is checked by default.

DISCLAIMER: these predictions are only as good as the model and is no substitute for a legal analysis. The predictions can thus not be relied on as legal advice. The model and app are made with academic intent. The application is meant as a tool for practitioners to be interpreted at their discretion.

### updating the Templates

The rows of the templated can be modified and extended as long as the follow template is followed (do not change the top row). This means new variables can be added, variable regex patterns can be changed, new training fines can be added, new commissioners can be added etc.

The open_category column title as all other titles need to remain exactly the same. However this column can be filled in with categories of the users choosing. fill in 'open_category' in the filter input on the model creation screen to group according to the categories. Make sure enough cases exist for each category. If an error is given, try reducing the testset. However, testset cannot be zero!

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

Since this code was made for academic purposes, the code is distributed under the GNU General Public license (as found here). Users (generally) thus have the right to Run, Study, Share, and Modify the code. The application and model are given as is and are no substitute for a thorough legal analysis.

## Questions and problems

The main repository is used for the transparancy of the research. Issues can be raised yet the main branch will generally not be updated since we already analysed the results. Researchers are free to branch this project and adapt to their needs, in accordance with the license. 

This repository branch is explicitly open for comments, feedback and adaptations in according with the license. General github practices apply.

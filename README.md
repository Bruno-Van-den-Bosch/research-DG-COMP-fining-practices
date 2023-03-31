# Research-DG-COMP-fining-practices

This repository bundels all code and files used in the (currently working) paper of Bruno Van den Bosch and Friso Bostoen, "Opening the Black Box: Uncovering the European Commission’s Cartel Fining Formula through Computational Analysis" (ssrn: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4232335).

## Paper Abstract
The abstract of the paper is as follows:

While abuse of dominance fines have received plenty of attention, most of the European Commission’s fines target cartels. The Fining Guidelines, in particular their most recent version (2006), have increased the transparency of how the Commission calculates those fines. However, the precise factors determining the fine as well as the exact quantification remained unknown, which is why the fine-setting process has been likened to a ‘black box’. This article opens that black box by computationally and doctrinally assessing all cartel fines based on the Fining Guidelines from 2006 until 2020. In doing so, we also test the ‘protectionist hypothesis’, which holds that the Commission uses antitrust enforcement to disadvantage non-EU and in particular U.S. firms. For some steps of the fine calculation (the base amount and entry fee) and for some Commissioners (Almunia and Vestager), we find a remarkably consistent methodology. This methodology offers no evidence of the protectionist hypothesis and, to the extent that there is any indication of it, bias would be aimed at Asian rather than U.S. firms. In addition, the uncovered fining methodology reveals that the Commission plays it very safe when setting cartel fines, which is why we call for more boldness. At the same time, the General Court should subject the Commission’s fines to more scrutiny, especially when it comes to equal treatment over time (rather than between parties in the same decision).

## Content of Git

This repository thus contains the R script model which automatically codes the variables for each party given the prohibition decision using regex expressions. The second part of the same R script then uses the variables to predict EU Competition fines in cartel cases using the RPart method.

The files are:

1. Annex 1: the overview of the cartel fines per party as used in the paper, with the interim amounts given. This excel was composed manually by the authors;

2. Annex 2: the overview of the Anova tests as descriped in the paper. These tests were run manually in libreOffice Calc;

3. Annex 3: the actual R script model which generates all the plots of the decision trees for each amount per Commissioner and the interim dataframes (containing the coded variables). The titles of the files contain the summary statistics of each output and the seed used to generate the output. 

4. Annex 4: The interim dataframe as generated by the first part of Annex 3. In case the user does not have all the prohibition decisions, the second part of the script can be run at the jumping of point as indicated in the script when given the location of Annex 4. The output will be all the decision trees and plots as generated for the writing of the paper.

## Using the script

To use the script the following input needs to be added at the top of the script as indicated:

1. The location of Annex 1;

2. The location of the folder containing all the relevant prohibition decisions (in English, or translated in English) in Pdf format with the name of the pdf files as '[case number (only numeral) ] [case name].pdf' (e.g. '38121 Fittings.pdf'); 

3. A location to save the output of the script.

### Extending the current dataset

To model new fines:

1. Annex 1 needs to be extended manually;

2. In case of a new Commissioner, lines 433 till 437 of the script need to be extended;

3. Beware that the current dataset contains too few cases with interim amounts for certain Commissioners. These amounts cannot be predicted. Therefore the model has an 'if else' structure excluding certain steps in the model for certain Commissioners. The list of Commissioners on line 437 thus needs to  be maintained.

4. When using a completely different dataset, the headers in the excel need to  be the same for the script to work. The previous comment needs to be taken into account and if the concern does not apply the 'if else' structure needs to be adapted.

5. To add new variables or change the coding of the variables lines 172 till 205 of the script can be extended. The variable name of new lists needs to be added to the list on line 208 till 211. Depending on whether the name of the party needs to be added to the regex and depending on whether an extra check (e.g. 'commission does not') needs to be added the variable has to be added in one of the lists. Check the code itself to decide. The variables are in the order they appear in the list from line 208 till 2011. 

## License

Since this code was made for academic purposes, the code is distributed under the GNU General Public license (as found here). Users (generally) thus have the right to Run, Study, Share, and Modify the code.

## Questions and problems

This repository is used for the transparancy of the research. Issues can be raised yet the main branch will generally not be updated since we already analysed the results. Researchers are free to branch this project and adapt to their needs, in accordance with the license. 

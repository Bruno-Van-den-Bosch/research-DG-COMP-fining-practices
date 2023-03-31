#########################################################################################
######COMPLETE REVERSE ENGINEERING SCRIPT OF COMMISSION FINING FORMULAS SINCE 2006#######
#########################################################################################
#########################################################################################
######PRE-SCRIPT: MANUALLY COLLECTED ALL EU CARTEL FINING DECISIONS SINCE 2006###########
##PRE-SCRIPT: FILLED IN EXCEL SHEET FOR ALL FINES, INCLUDING THE INCREASE AND DECREASE PERCENTAGE STEPS##
##PRE-SCRIPT: COLLECTED ALL NAMES FROM ALL PARTIES ADDRESSED TO 1 SPECIFIC FINE##
##PRE-SCRIPT: IDENTIFIED IN THE FINING GUIDELINES, DECISIONS THEMSELVES AND THE DISCUSSIONS AROUND EU FINING PRACTICES POSSIBLE RELEVANT FACTORS ##
##IDENTIFIED (WITH HELP OF EXTERNAL SCRIPT) POSSIBLE REGEX EXPRESSIONS (PHRASINGS THAT ARE USED AS A PROXY)####
#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################
#########################AFTER THIS SCRIPT###############################################
#### A) IDENTIFIED ALL FORMULAS WITHIN THE TIME SPAN#####################################
#### B) APPROXIMATED ALL FORMULAS########################################################
#### C) SAVED ALL DATASETS MADE AND SUBSEQUENTLY USED####################################
#### D) SAVED ALL IMAGES (fitting plots and trees)#######################################
#########################################################################################

#############################################################################################################################################################
install.packages("pdftools")
install.packages("stringr")
install.packages("stringi")
install.packages("sjmisc")
install.packages("writexl")
install.packages("readxl")
install.packages("tm")
install.packages("memisc")
install.packages("tidyverse")
install.packages("caret")
install.packages("readxl")
install.packages("randomForest")
install.packages("xgboost")
install.packages("ggplot2")
install.packages("magrittr")
install.packages("rpart.plot")
install.packages("e1071")
library(rpart.plot)
library(writexl)
library(tidyverse)
library(caret)
library(readxl)
library(randomForest)
library(xgboost)
library(ggplot2)
library(pdftools)
library(stringr)
library(stringi)
library(sjmisc)
library(writexl)
library(readxl)
library(tm)
library(memisc)
library(magrittr)
library(e1071)
#############################################################################################################################################################


#################         SCRIPT STARTS HERE      #################


#############################################################################################################################################################
########################FILL IN NEXT LINE DIRECTORY TO STORE ALL PLOTS AND TABLES#########################################
mainfolder <- "[FILL IN WITH DIR]/output/"
dir.create(mainfolder)
########################FILL IN NEXT LINE DIRECTORY TO PRE-SCRIPT XLSX#########################################
relevantxlsxfile <- "[FILL IN WITH DIR]/Annex 1 - overview cartel fines.xlsx"
########################FILL IN NEXT LINE DIRECTORY TO PDFS OF FINING (PROHIBITION) DECISIONS (in eng)#########################################
decisionsfolder <- "[FILL IN WITH DIR]/pdfsprobit"
##########################################################################################################################################################
###############################################################################################################################

##PART 1: MAKE DATASET##
namesdf <- read_xlsx(relevantxlsxfile)
head(namesdf)
#Identify the parties in the base-excel sheet
indivnamematr <- matrix(nrow=nrow(namesdf), ncol=1)
for (i in 1:nrow(namesdf)) {
     namesindivid <- namesdf[i,1]
     namesindivid <- gsub(" corp[.](\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" [(]in liquidation[)]"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" co[.][,] ltd(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("[.]","",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)UK([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)Europe([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)china([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)hong kong([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)Schweiz([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)shanghai([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)nederland([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ([(]|)h(|[.])k(|[.])([)]|)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" solely (in the light of the deterrence multiplier applied):"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("& "," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" a/s(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" AS(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ASA(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("/","",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" kgaa(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" NV(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" sc(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" Sro(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" BV(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" ltd(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" inc(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" société anonyme"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" corporation"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" co(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" SA(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" industries(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" holding(|s)(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" SpA(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" plc(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" gmbh(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" g(|es)mbh(|&)(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" KG(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" S(|a)rl(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("[^(,|and |;)] SAS(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" PSC(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" SL(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" AG(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" AB(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" oy(|j)(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" corp(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" and company(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" bvba(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" limited(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" limited(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" oHG(\\W|$)"," ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("Procter   Gamble","procter & gamble",namesindivid, ignore.case=TRUE)
     namesindivid <- str_squish(namesindivid)
     namesindivid <- gsub("[(][[:space:]][)]","",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("([(]|[)])","|",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("(( |[(])formerly|as an economic successor of|former name| jointly and severally (with|liable:|liable with)|for the behaviour of )", " | ",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub(" and ", "|",namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("(:|,|;)", "|", namesindivid, ignore.case=TRUE)
     namesindivid <- str_squish(namesindivid)
     namesindivid <- gsub("[|]{2,}", "|", namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("[|](| )$", "|", namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("^(| )[|]", "|", namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("[[:space:]]$", "", namesindivid, ignore.case=TRUE)
     namesindivid <- str_squish(namesindivid)
     namesindivid <- gsub("[|][[:space:]]*[|]", "", namesindivid, ignore.case=TRUE)
     namesindivid <- gsub("[|]formerly", "|", namesindivid, ignore.case=TRUE)
     namesindividoutselect <- namesindivid
     namesindividoutselect <- paste0("(",namesindividoutselect,")")
     namesindividoutselect <- gsub("[)][|][(]", "|", namesindividoutselect, ignore.case=TRUE)
     namesindividoutselect <- gsub("[|][)]", ")", namesindividoutselect, ignore.case=TRUE)
     namesindividoutselect <- gsub("[(][|]", "(", namesindividoutselect, ignore.case=TRUE)
     indivnamematr[i,1] <-  namesindividoutselect }

files <- list.files(decisionsfolder, pattern=".pdf", full.names=TRUE)
textlist <- c()
for (i in 1:nrow(namesdf)){
    regf <- paste0(decisionsfolder,"/",namesdf$CASENUM[[i]],".*.pdf")
    relevpath <- str_extract(files,regf)
    relevpath <- na.omit(relevpath)
    rpdfr <- readPDF(control= list(text = "-layout"))
    text <- Corpus(URISource(relevpath), readerControl=list(reader=rpdfr))
    thetext <- text[[1]]$content
    thetext <- gsub("\n", "", thetext)
    thetext <- gsub("\n\n", "", thetext)
     thetext <- gsub("[?.,;:-]", "", thetext)
    thetext <- trimws(thetext)
    thetext <- lapply(thetext, str_squish)
    textlist[[i]] <- thetext
}

#variabele
#define all the identfiers of the variable, already in regex form

settlement <- list("32 of the settlement notice.{0,80}? settlement.{0,60}?
reduction")
MSCOL <- list("(whose|have).{0,20}? combined.{0,5}? market.{0,3}?
share","market.{0,3}? share.{0,20}? combined") #2
RECIDCOL <- list("The decision of relevance to","aggrevating circumstance for recidivism","increase.{0,20} recidivism","previous decision.? finding", "(finding.{0,10}?|) similar.{0,10}? infringement", "previous decision.?", "repeat(.|ed).{0,10}? similar.{0,10}? infringement", "(commission|competition authority).{0,80}? made.{0,10}? finding.{0,10}?", "recidivist")
RECIDCOLxl <- list("The decisions of relevance to","repeated infringement", "repeated multiple infringement", "infringed multiple times")
LEADCOL <- list("lead.{0,10}? [ ^.]{0,80} (coordinat|cartel|arrangement)", "(lead|coordinat.{0,20}).{0,40} meetings", "(whose|).{0,100}? \"coordinator\"", "cartel leader", "leader of the cartel", "took the lead", " the role of coordinator", "show(|ed) the direction to others", "coordinated the (cartel|arrangement|collusion)", "was the coordinator", "instigated.{0,40} the (infringement|collusion|agreement|arrangement|cartel)", "cartel instigator", "the instigator of")
ENDINCOL <- list("ended.{0,90}? after.{0,60} intervention", "after.{0,200}intervention.{0,255}ended","ended.{0,100}? at the very latest.{0,300} commission","ended.{0,95} (infringement|involvement).{0,300} commission", "after.{0,90} commission (|.{0,60}intervention) .{0,450} [^(continued the)]","ended.{0,50} involvement.{0,120} no later than.{0,90} Commission", "ended.{0,120}? at the very latest on.{0,90} when")
EFFCOPCOL <- list("exceptional.{0,30}? circumstance.{0,30}? present.{0,30}? case justify.{0,150}?", "cooperation outside the leniency notice")
CRISISSITUATION <- list("(sector|industry).{0,30} in.{0,30}? (crisis|poor|trouble)", "poor financial state of the (sector|industry)")
regulatory_sec <- list("(sector|industry).{0,50} subject to a .{0,80} (regulatory|legislative|administrative) regime")
#NATCOLeffecttrademember <- list("(cartel|arrangement(|s)|agreement(|s))(were|had|did|did have).{0,20}? (.{0,20}?|capable.{0,15}?) (appreciable| ) effect upon.{0,15}? trade.{0,50}? member states", "did.{0,60}? affect.{0,10}? trade.{0,50}? member states"," had.{0,60}? effect.{0,10}? trade.{0,50}? member states", "impacted.{0,50} trade.{0,50}? member states")
NATCOLmarketvalue <- list("market shares (|in terms of volume and value) covered (|approximately )[9876].\\% of the market","market.{0,15}? total value.{0,70}? (around|exceeds|of)", "total market.{0,50} value (around|exceeds|of)")
#NATCOLanticomp <- list("clearly anti.{0,4}?competitive","commission considers.{0,7}? th .{0,80}? anti.{0,4}?competitive","is clear.{0,90}? anti.{0,4}?competitive","anti.{0,4}?competitive nature.{0,40}? (meeting|agreement|exchange.{0,4}?(.{0,5}?|commercially sensitive|sensitive) information)", "anti.{0,4}?competitive nature.{0,15}? (discussed|discussion)", "(discussed|discussion) anti.{0,4}?competitive nature.{0,15}?")
IMPCOL <- list("was.{0,30}? implemented(.{0,100}?|by.{0,250})","did.{0,30} implement.{0,100} (for|during)","implement.{0,35}? purpose.{0,20}? restricting competition", "price increase.{0,30}? implement", "implement.{0,30}? price increase.?","agreed.{0,50}? (implementation|to implement)","(implementation|to implement).{0,40}? agreed", "subsequent.{0,60} implement", "implement.{0,50}? subsequent")
PRICCOLandinfo <- list("exchange(|s|d).{0,70}? (|commercially) sensitive information.{0,200}? (fix|set) pric.{0,5}?", "(fix|set) pric.{0,5}? exchang.{0,70}? commercially sensitive information")
EXCHANGinfo <- list("exchange(|s|d).{0,70}? (|commercially) sensitive.{0,40}?
information")#changed the buffers from 0,30 and 0,25
PRICCOL <- list("prices .{0,50}? fixed by", "the price of.?", "coordinated price(|s)","followed.{0,50}? price(|s)","price.{0,55}? simultaniously","(discus|agreed|meeting|implement).{0,100}? to (fix|set|coordinat.{0,40}) price(s|)","(discus|agreed|meeting|implement).{0,100}? price (|increase)", "took place.{0,100}? pric.{0,5}?", "discuss.{0,100} pric.{0,4}?", "argue.{0,100}? pric.{0,4}?", "common objective.{0,150} price.?", "meetings.{0,100} pric.{1,4}?", "new price")
MARSHACOL <- list("allocated market( ||-)share", "(discus|agreed|meeting|implement).{0,150}? ((shar.{0,20}? mark.{0,10}?|mark.{0,20}? shar.{0,10}?)|.{0,10}allocat.{0,5}?)", "took place.{0,100} ((shar.{0,20}? mark.{0,10}?|mark.{0,20}? shar.{0,10}?)|allocat.{0,5}?)", "discuss.{0,20} ((shar.{0,20}? mark.{0,10}?|mark.{0,20}? shar.{0,10}?)|allocat.{0,5}?)", "argue.{0,20}? ((shar.{0,20}? mark.{0,10}?|mark.{0,20}? shar.{0,10}?)|allocat.{0,5}?)", "common objective.{0,50} ((shar.{0,20}? mark.{0,10}?|mark.{0,20}? shar.{0,10}?)|allocat.{0,5}?)", "to allocat.{0,20}? market")
long_proceed <- c("total period of investigation .{0,90}more than") #NEW,dubbele spaties weg
GEOCOLentireEEA <- list("covered.{0,6}? (entire|whole).{0,10}? (EEA|EU|union)", "covered.{0,5}? all.{0,9}? member states", "took place.{0,13}? (europe|EU|EEA)", "geographical scope.{0,30} EEA")
GEOCOLglobe <- list("(broader|wider|beyond) (EEA.?|EU.?|.{0,40} union)","scope.{0,35}? wider than the (EEA.?|EU.?)", "took place.{0,90} outside the (EU.?|EEA.?)", "(implemented|place.{0,80}?.?) (beyond|outside).{0,40} (EU.?|EEA.?)", "scope cartel world(| |-)wide")
GEOCOLlocalimp <- list("locally important", "(significant|important).{0,90} local(|ly)", "local infringement", "infringment.{0,200} for the local", "impact on the local", "distorted local")
GEOCOLnational <- list("covered.{0,20}? (Belgium|Luxembourg|Italy|the Netherlands|Germany|France|Ireland|Denmark|UK|united kingdom|greece|spain|portugal|Austria|Sweden|Finland|Lithuania|Latvia|Estonia|Poland|the Czech Republic|Slovakia|Hungary|Slovenia|Malta|Cyprus|Romania|Bulgaria|croatia)", "took place.{0,30}? (Belgium|Luxembourg|Italy|the Netherlands|Germany|France|Ireland|Denmark|UK|united kingdom|greece|spain|portugal|Austria|Sweden|Finland|Lithuania|Latvia|Estonia|Poland|the Czech Republic|Slovakia|Hungary|Slovenia|Malta|Cyprus|Romania|Bulgaria|croatia)", "territory.{0,20}? (Belgium|Luxembourg|Italy|the Netherlands|Germany|France|Ireland|Denmark|UK|united kingdom|greece|spain|portugal|Austria|Sweden|Finland|Lithuania|Latvia|Estonia|Poland|the Czech Republic|Slovakia|Hungary|Slovenia|Malta|Cyprus|Romania|Bulgaria|croatia)", "(Belgium|Luxembourg|Italy|the Netherlands|Germany|France|Ireland|Denmark|UK|united kingdom|greece|spain|portugal|Austria|Sweden|Finland|Lithuania|Latvia|Estonia|Poland|the Czech Republic|Slovakia|Hungary|Slovenia|Malta|Cyprus|Romania|Bulgaria|croatia).{0,20}? territory" )
novelty <- c("new type", "novel(|ty)", "no previous decision on", "alleged is novel", "is allegedly novel")
AVOIDCOL <- list("oppos.{0,9}? .{0,100}? (cartel|agreement|arrangement)", "actually.{0,30}? avoided.{0,40}? .{0,100} (conduct|agreement|arrangement)")
NEGLCOLunaw_unlawf <- c("lack of awareness","unaware.{0,240} unlawful","not aware.{0,240} unlawful","unaware.{0,240} prohibited", "not aware.{0,240} prohibited", "unaware.{0,240} illegal", "not aware.{0,240} illegal", "not aware that their conduct constituted an infringement")
NEGLCOL <- list("meetings.{0,100} negligen","claim.{0,100} negligen", "negligen.{0,100} meetings", "negligen.{0,20} participation")
LIMINVCOL <- list("follow-my-leader","minor role", "passive role", "follow my leader", "less contracts", "fewer number of contracts", "not aware.{0,240}? restricted competition", "unaware.{0,240}? restricted competition", "were not aware of the infringement", "were unaware of the infringement", "was not aware of the.{0,80}? (conduct|arrangement|agreement|initative)", "not aware of certain.{0,30}? (conduct|arrangement|agreement|initative)", "did not participate in", "not aware of the.{0,80}? anti(|-)competitive", "not aware of the.{0,50}? scheme","not aware of any.{0,40}? (initiative(|s)|conduct|arrangement|agreement)", "its involvement was limited", "contributed to a lesser extent to.{0,110}? (infringement|conduct|cartel|arrangement)")
US <- c("United States", "U.S.(|A)", "usa")
notcoop <- c("failed to.{0,130} information", "failed to cooperate", "did not cooperate", "refused to cooperate", "refusal to cooperate","did not comply","failed to comply", "failed to comply.{0,170} Commission.{0,50} request", "failed to provide information regarding", "failed to comply with.{0,110} Commission.{0,15}","did not comply with.{0,150} commission.{0,30}", "obstruction of the.{0,60} commission.{0,15}", "obstructed the.{0,60} commission.{0,50}") #,"commission.{0,80} was obstructed by")
LARTURNCOL <- list("considerably larger undertaking than","turnover.{0,150}? is considerably (higher|larger) than","particularly large turnover beyond", "turnover is a multiple", "has a particularly large turnover", "whose turnover exceeds", "turnover is larger")
EU <- c("(Belgium|Bulgaria|Croatia|Czech Republic|Denmark|Germany|Estonia|Greece|Spain|France|Ireland|Italy|Cyprus|Latvia|Lithuania|Luxembourg|Hungary|Malta|The Netherlands|Austria|Poland|Portugal|Romania|Slovenia|Slovakia|Finland|Sweden|United Kingdom)")

#maak volledige lijst van factoren zoektermen
Searchitall <- list(settlement, MSCOL, RECIDCOL,RECIDCOLxl, LEADCOL, ENDINCOL, EFFCOPCOL)
SearchitallB <- list(CRISISSITUATION, regulatory_sec, NATCOLmarketvalue, IMPCOL, PRICCOLandinfo, EXCHANGinfo, PRICCOL, MARSHACOL, long_proceed)
SearchitallC <- list(GEOCOLentireEEA , GEOCOLglobe, GEOCOLlocalimp, GEOCOLnational, novelty)
SearchitallD <- list(AVOIDCOL, NEGLCOLunaw_unlawf, NEGLCOL, LIMINVCOL, US, notcoop, LARTURNCOL)
mop <- length(Searchitall)+length(SearchitallB)+length(SearchitallC)+length(SearchitallD)+1
setofvaresult <- matrix(nrow=nrow(namesdf), ncol=(mop))

finalcodedforvar <- list()
for(i in 1:nrow(namesdf)){
    drukhet <- paste0("________________________________FOR PARTY ", i,"__Van de",nrow(namesdf),"__________________________" )
    print(drukhet)
    for(f in 1:length(Searchitall)){
            drukhet2 <- paste0("______________VARIABELE _", f, "van de",length(Searchitall), ":__VOOR PARTY_",i ,"_____________________")
            print(drukhet2)
            resulthits <- list()
            hits <- list()
            hits2 <- list()
            hits3 <- list()
            hits4 <- list()
            name <- indivnamematr[i,1]
            reltext <- textlist[[i]]
            codedvar_inf <- list()
            codedvar_inf2 <- list()
            for (j in 1:length(Searchitall[[f]])){
                zoekervoor <- paste0(name,".{0,150}",Searchitall[[f]][j]) #ervoor was het 1500
                hits <- str_detect(reltext, regex(zoekervoor, ignore_case=TRUE))
                zoekerna <- paste0(Searchitall[[f]][j],".{0,180}?",name) #bij slecht resultaat mogelijks terugzetten naar
                hits2 <- str_detect(reltext, regex(zoekerna, ignore_case=TRUE))
                    for(l in 1:length(hits)){
                        resulthits[[l]] <- hits[[l]]}
                    for(p in 1:length(hits2)){
                        otoi <- length(hits)+p
                        resulthits[[otoi]] <- hits2[[p]] }
                codedvar_inf[[j]] <- str_contains(resulthits, TRUE)
                zoekcommiss1 <- paste0("Commission.{0,40}? not.{0,700}",name,".{0,90}",Searchitall[[f]][j])
                zoekcommiss2 <- paste0(name,".{0,400}","Commission.{0,40}? not.{0,90}",Searchitall[[f]][j])
                hits3 <- str_detect(reltext, regex(zoekcommiss1, ignore_case=TRUE))
                hits4 <- str_detect(reltext, regex(zoekcommiss2, ignore_case=TRUE))
                tlink <-  length(hits3)+length(hits4)
                resulthits2 <- matrix(ncol=1, nrow=tlink)
                for(l in 1:length(hits3)){
                    resulthits2[l,1] <- hits3[[l]]}
                for(p in 1:length(hits4)){
                    otoi <- length(hits3)+p
                    resulthits2[otoi,1] <- hits4[[p]]}
                codedvar_inf2[[j]] <- str_contains(resulthits2, TRUE)
        }
        forcodedfin <- str_contains(codedvar_inf, TRUE)
        forcodedfin2 <- str_contains(codedvar_inf2, TRUE)
        if (forcodedfin2) {finalcodedforvar[[f]] <- FALSE}else{finalcodedforvar[[f]] <- forcodedfin}
        voerhetin <- finalcodedforvar[[f]]
        if (voerhetin) {finv <- 1}else{finv <- 0}
        setofvaresult[i,f] <- finv
        }

        finalcodedforvarB <- list()
        for(f in 1:length(SearchitallB)){
        drukhet3 <- paste0("__________VARIABELE_TWEEDE_GROEP _", f,"van de", length(SearchitallB), ":__VOOR PARTY_",i ,"_____________________")
            print(drukhet3)
            resulthitsB <- list()
            reltextB <- textlist[[i]]
            codedvar_infB <- list()
            for (j in 1:length(SearchitallB[[f]])){
                zoeker <- paste0(SearchitallB[[f]][j])
                hits <- str_detect(reltextB, regex(zoeker, ignore_case=TRUE))
                    for(l in 1:length(hits)){
                        resulthitsB[[l]] <- hits[[l]]}
                codedvar_infB[[j]] <- str_contains(resulthitsB, TRUE)
        }
        forcodedfinB <- str_contains(codedvar_infB, TRUE)
        finalcodedforvarB[[f]] <- forcodedfinB
        tgutb <- (length(Searchitall))+f
        voerhetin <- finalcodedforvarB[[f]]
        voerhetin
        if (voerhetin) {finv <- 1}else{finv <- 0}
        setofvaresult[i,tgutb] <- finv
        setofvaresult[i,tgutb]
        }
        finalcodedforvarC <- list()
        for(f in 1:length(SearchitallC)){
        drukhet4 <- paste0("__________VARIABELE_DERDE_GROEP _", f,"van de", length(SearchitallC), ":__VOOR PARTY_",i ,"_____________________")
            print(drukhet4)
            resulthitsC <- list()
            reltextC <- textlist[[i]]
            codedvar_infC <- list()
            for (j in 1:length(SearchitallC[[f]])){
                zoekerA <- paste0(SearchitallC[[f]][j],".{0,170}(infringement|collusion|agreement|arrangement|cartel)")
                zoekerB <- paste0("(infringement|collusion|agreement|arrangement|cartel).{0,180}",SearchitallC[[f]][j])
                Zoekhet <- paste0("(",zoekerA,")|(",zoekerB,")")
                hitsC <- str_detect(reltextC, regex(Zoekhet, ignore_case=TRUE))
                    for(l in 1:length(hitsC)){
                        resulthitsC[[l]] <- hitsC[[l]]}
                codedvar_infC[[j]] <- str_contains(resulthitsC, TRUE)
        }
        forcodedfinC <- str_contains(codedvar_infC, TRUE)
        finalcodedforvarC[[f]] <- forcodedfinC
        tgutb2 <- (length(Searchitall)+length(SearchitallB)+f)
        voerhetin <- finalcodedforvarC[[f]]
        voerhetin
        if (voerhetin) {finv <- 1}else{finv <- 0}
        setofvaresult[i,tgutb2] <- finv
        setofvaresult[i,tgutb2]
        }

        finalcodedforvarD <- list()
        for(f in 1:length(SearchitallD)){
        drukhet4 <- paste0("__________VARIABELE_VIERDE_GROEP _", f,"van de", length(SearchitallD), ":__VOOR PARTY_",i ,"_____________________")
            print(drukhet4)
            resulthitsD <- list()
            reltextD <- textlist[[i]]
            codedvar_infD <- list()
            for (j in 1:length(SearchitallD[[f]])){
                Zoekhet <- paste0(name,".{0,120}?",SearchitallD[[f]][j])
                hitsD <- str_detect(reltextD, regex(Zoekhet, ignore_case=TRUE))
                    for(l in 1:length(hitsD)){
                        resulthitsD[[l]] <- hitsD[[l]]}
                codedvar_infD[[j]] <- str_contains(resulthitsD, TRUE)
        }
        forcodedfinD <- str_contains(codedvar_infD, TRUE)
        finalcodedforvarD[[f]] <- forcodedfinD
        tgutb2 <- (length(Searchitall)+length(SearchitallB)+length(SearchitallC)+f)
        voerhetin <- finalcodedforvarD[[f]]
        voerhetin
        if (voerhetin) {finv <- 1}else{finv <- 0}
        setofvaresult[i,tgutb2] <- finv
        setofvaresult[i,tgutb2]
        }

        drukhet5 <- paste0("__________AANWEZIGHEID VAN EU? :__VOOR PARTY_",i ,"_____________________")
        print(drukhet5)
        name2 <- indivnamematr[i,1]
        ZOEKNIETEU <- paste0("article 4.{0,30}?decision is addressed to.*", name2, ".{0,150}?", EU, ".*this decision shall be enforceable")
        hitsnoneu <- str_detect(reltext, regex(ZOEKNIETEU, ignore_case=TRUE))
        bomin <- length(Searchitall)+length(SearchitallB)+length(SearchitallC)+length(SearchitallD)+1
        setofvaresult[[i,bomin]] <- str_contains(hitsnoneu, TRUE)

        }
ncol(setofvaresult)
nrow(setofvaresult)
outcolum <- ncol(setofvaresult)
out <- matrix(ncol=(ncol(setofvaresult)),nrow=nrow(setofvaresult))
for (i in 1:nrow(namesdf)) {
    for (w in 1:ncol(setofvaresult)){
        outinput <- as.numeric(setofvaresult[i,w])
        out[i,w] <- outinput
    }
}
out[1,18]
finaldf <- as.data.frame(out)

autoformedDF <- cbind(namesdf$Party_name, namesdf$sector,namesdf$CASENUM,namesdf$nr,finaldf, namesdf$ability_pay, namesdf$oldfinguid, namesdf$Sales, namesdf$Base, namesdf$old_dete, namesdf$additional, namesdf$duration, namesdf$aggrav, namesdf$mitig, namesdf$dete, namesdf$legal_max, namesdf$total_am, namesdf$LA, namesdf$utfperc, namesdf$ultfineNOM, namesdf$ultfiCALCZTN, namesdf$"which_commissionar")
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$CASENUM"] <- "CASENUM"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$nr"] <- "nr"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$ability_pay"] <- "ability_pay"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$Sales"] <- "Sales"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$Base"] <- "Base"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$old_dete"] <- "old_dete"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$additional"] <- "additional"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$duration"] <- "duration"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$aggrav"] <- "aggrav"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$mitig"] <- "mitig"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$dete"] <- "dete"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$legal_max"] <- "legal_max"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$total_am"] <- "total_am"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$LA"] <- "LA"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$utfperc"] <- "utfperc"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$ultfineNOM"] <- "ultfineNOM"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$ultfiCALCZTN"] <- "ultfiCALCZTN"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$which_commissionar"] <- "which_commissionar"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$Party_name"] <- "Party_name"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$sector"] <- "sector"
colnames(autoformedDF)[colnames(autoformedDF) == "namesdf$oldfinguid"] <- "oldfinguid"
autoformedDFfolderpath <- paste0(mainfolder,"datasets/")
dir.create(autoformedDFfolderpath)
autoformedDFdoc <- paste0(autoformedDFfolderpath,"autoformedDF_final.xlsx")
write_xlsx(autoformedDF, autoformedDFdoc)
################################################################################################################################################################################################################################################################################################
#######SECOND PART: MACHINE LEARNING (RPART) TO SEEK THE ACTUAL FORMULA########################################################################################################################################

###################################################IN CASE OF JUMPING IN###########################################################################
##my_datafirst <- read_xlsx("C:/Users/u0140749/Desktop/paper fining formula/researchsresults/sector-included/datasets/autoformedDF_final.xlsx")##
##my_datafirst <- my_datafirst[,1:which(colnames(my_datafirst)== "which_commissionar")]###
######################################################################################################################################################################

my_datafirst <- autoformedDF[,1:which(colnames(autoformedDF)== "which_commissionar")]

my_data1 <- my_datafirst #na.omit()
listindepend <- list()
for(k in 1:((which(colnames(my_data1)=="ability_pay")-which(colnames(my_data1)=="nr"))-1)){
listindepend[[k]] <- paste0("V",k)
}
independents <- paste0(listindepend, collapse="+")
independents

nrow(my_data1)
my_data1 <- filter(my_data1, my_data1$oldfinguid == 0)


folderpath0 <- paste0(mainfolder,"fitnessplots/")
dir.create(folderpath0)
folderpath02 <- paste0(folderpath0,"nominal/")
dir.create(folderpath02)
folderpath03 <- paste0(folderpath0,"percentage/")
dir.create(folderpath03)
for (l in 1:4){
if(l==1){folderpath <- paste0(mainfolder,"fitnessplots/percentage/NK/")}else{if(l==2){folderpath <- paste0(mainfolder,"fitnessplots/percentage/JA/")}else{if(l==3){folderpath <- paste0(mainfolder,"fitnessplots/percentage/MV/")}else{folderpath <- paste0(mainfolder,"fitnessplots/percentage/combiJA_MV/")}}}
dir.create(folderpath)
if (l==1){folderpath <- paste0(mainfolder,"fitnessplots/percentage/NK/last/")}else{if(l==2){folderpath <- paste0(mainfolder,"fitnessplots/percentage/JA/last/")}else{if(l==3){folderpath <- paste0(mainfolder,"fitnessplots/percentage/MV/last/")}else{folderpath <- paste0(mainfolder,"fitnessplots/percentage/combiJA_MV/last/")}}}
dir.create(folderpath)
}
for (l in 1:4){
if(l==1){folderpath <- paste0(mainfolder,"fitnessplots/nominal/NK/")}else{if(l==2){folderpath <- paste0(mainfolder,"fitnessplots/nominal/JA/")}else{if(l==3){folderpath <- paste0(mainfolder,"fitnessplots/nominal/MV/")}else{folderpath <- paste0(mainfolder,"fitnessplots/nominal/combiJA_MV/")}}}
dir.create(folderpath)
if (l==1){folderpath <- paste0(mainfolder,"fitnessplots/nominal/NK/last/")}else{if(l==2){folderpath <- paste0(mainfolder,"fitnessplots/nominal/JA/last/")}else{if(l==3){folderpath <- paste0(mainfolder,"fitnessplots/nominal/MV/last/")}else{folderpath <- paste0(mainfolder,"fitnessplots/nominal/combiJA_MV/last/")}}}
dir.create(folderpath)
}
folderpath0 <- paste0(mainfolder,"treeplots/")
dir.create(folderpath0)
for (l in 1:4){
if(l==1){folderpath <- paste0(mainfolder,"treeplots/NK/")}else{if(l==2){folderpath <- paste0(mainfolder,"treeplots/JA/")}else{if(l==3){folderpath <- paste0(mainfolder,"treeplots/MV/")}else{folderpath <- paste0(mainfolder,"treeplots/combiJA_MV/")}}}
dir.create(folderpath)
if (l==1){folderpath <- paste0(mainfolder,"treeplots/NK/last/")}else{if(l==2){folderpath <- paste0(mainfolder,"treeplots/JA/last/")}else{if(l==3){folderpath <- paste0(mainfolder,"treeplots/MV/last/")}else{folderpath <- paste0(mainfolder,"treeplots/combiJA_MV/last/")}}}
dir.create(folderpath)
}

commis1 <- as.logical(my_data1[["which_commissionar"]] == "Neelie Kroes")
commis2 <- as.logical(my_data1[["which_commissionar"]] == "Joaquin Almunia")
commis3 <- as.logical(my_data1[["which_commissionar"]] == "Margrethe Vestager")
commis4 <- as.logical(my_data1[["which_commissionar"]] != "Neelie Kroes")
commissionars <- list(commis1, commis2, commis3, commis4)
output_list <- list()
forseeds_outs <- list()
setseeddepo <- c(101, 1010, 10011, 10201,9098, 912, 109, 913, 584, 610, 67887, 2234, 9098, 3461, 2365, 9856, 1298, 8734, 4563, 23143, 0967, 54, 981, 102, 104, 89, 63, 38, 65, 334778, 1940, 34567,289, 9009, 82234, 14378, 123, 3210, 6789,986, 445, 26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,22,5, 33)
oldgold <- c()
finalmodels_all <- list()
outmatrix <- matrix(nrow=17, ncol=length(commissionars))
bundelthebuildslistseeds <- list()
bundelthebuildslist <- list()
bundelthebuildslistseeds <- matrix(nrow=12, ncol=1)
namem <- matrix(nrow=12, ncol=1)
RMSEbundelthebuildslistseeds <- list()
RMSEbundelthebuildslist <- list()
RMSEbundelthebuildslistseeds <- matrix(nrow=12, ncol=1)
RMSEnamem <- matrix(nrow=12, ncol=1)
for (q in 1:length(setseeddepo)){
finalmodels_all[[q]] <- list()
print(q)
#create blanco set
RMSEbundelthebuilds <- matrix(nrow=12, ncol=4)
for(l in 1:nrow(RMSEbundelthebuilds)){
for(y in 1:ncol(RMSEbundelthebuilds)){
RMSEbundelthebuilds[l,y] <- 1000000000
}}
bundelthebuilds <- matrix(nrow=12, ncol=4)
for(l in 1:nrow(bundelthebuilds)){
for(y in 1:ncol(bundelthebuilds)){
bundelthebuilds[l,y] <- 0
}}
for(i in 1:length(commissionars)){

finalmodels_all[[q]][[i]] <- list()
commislogical <- commissionars[[i]]
my_data <- filter(my_data1, commislogical)
nrow(my_data)

for(c in 1:length(listindepend)){
pastloc <- paste0("my_data$",listindepend[[c]])
pastloc <- as.numeric(pastloc)
print(listindepend[[c]])
}

nrow(my_data)

my_data$total_am <- as.numeric(my_data$total_am)
my_data$utfperc <- as.numeric(my_data$utfperc)
my_data$ultfiCALCZTN <- as.numeric(my_data$ultfiCALCZTN)
my_data$Party_name <- as.factor(my_data$Party_name)
my_data$sector <- as.factor(my_data$sector)
my_data[["which_commissionar"]] <- as.factor(my_data[["which_commissionar"]])
my_data$ultfiCALCZTN <- as.numeric(my_data$ultfiCALCZTN)

my_data <- na.omit(my_data)

nrow(my_data)

length(my_datafirst)
length(my_data[[1]])
#define the dataset to predict whether an amount was imposed
INITmatrix <- matrix(nrow=nrow(my_data), ncol=7)
for(n in 1:nrow(my_data)){
    if(my_data$ultfineNOM[[n]] > 0){INITmatrix[n,1] <- 1}else{INITmatrix[n,1] <- 0}
    if(my_data$Base[[n]] > 0){INITmatrix[n,2] <- 1}else{INITmatrix[n,2] <- 0}
    if(my_data$additional[[n]] > 0){INITmatrix[n,3] <- 1}else{INITmatrix[n,3] <- 0}
    if(my_data$aggrav[[n]] > 0){INITmatrix[n,4] <- 1}else{INITmatrix[n,4] <- 0}
    if(my_data$mitig[[n]] > 0){INITmatrix[n,5] <- 1}else{INITmatrix[n,5] <- 0}
    if(my_data$dete[[n]] > 0){INITmatrix[n,6] <- 1}else{INITmatrix[n,6] <- 0}
    if(my_data$old_dete[[n]] > 0){INITmatrix[n,7] <- 1}else{INITmatrix[n,7] <- 0}
}
INITdf <- as.data.frame(INITmatrix)

colnames(INITdf) <- c("ultfineNOMINIT", "BaseINIT", "additionalINIT", "aggravINIT", "mitigINIT", "deteINIT", "old_deteINIT")
my_data <- cbind(INITdf, my_data)
#to make sure tree is towards binary values
my_data$ultfineNOMINIT <- as.factor(my_data$ultfineNOMINIT)
my_data$BaseINIT <- as.factor(my_data$BaseINIT)
my_data$additionalINIT <- as.factor(my_data$additionalINIT)
my_data$aggravINIT <- as.factor(my_data$aggravINIT)
my_data$mitigINIT <- as.factor(my_data$mitigINIT)
my_data$deteINIT <- as.factor(my_data$deteINIT)
my_data$old_deteINIT <- as.factor(my_data$old_deteINIT)

#splits in training en test data
theme_set(theme_bw())
setit <- setseeddepo[[q]]
set.seed(setit)
training.samples <- my_data$ultfineNOM %>%
  createDataPartition(p=0.85, list = FALSE)
train.data <- my_data[training.samples, ]
test.data <- my_data[-training.samples,]

train.data$total_am <- gsub("TURNOVERLIMIT","",train.data$total_am)
train.data$utfperc <- gsub("TURNOVERLIMIT","", train.data$utfperc)
train.data$ultfiCALCZTN <- gsub("TURNOVERLIMIT","",train.data$ultfiCALCZTN)
train.data$ultfiCALCZTN <- as.numeric(train.data$ultfiCALCZTN)
train.data$total_am <- as.numeric(train.data$total_am)
train.data$utfperc <- as.numeric(train.data$utfperc)

train.dataY <- na.omit(train.data)
train.data <- cbind(train.data[,1:which(colnames(train.data)=="legal_max")],train.data[,which(colnames(train.data)=="ultfineNOM")])
colnames(train.data)[colnames(train.data) == 'train.data[, which(colnames(train.data) == "ultfineNOM")]'] <- "ultfineNOM"
train.data <- na.omit(train.data)

independents


#define the formula to determine whether an amount was imposed
INITY <- as.formula(paste0("ultfineNOMINIT ~ ability_pay+Sales+nr+duration+oldfinguid+",independents))
INITYBA <- as.formula(paste0("BaseINIT ~ Sales+nr+oldfinguid+",independents))
INITYAA <- as.formula(paste0("additionalINIT ~ Sales+nr+oldfinguid+", independents))
INITYaggrav <- as.formula(paste0("aggravINIT ~ Sales+nr+oldfinguid+", independents))
INITYmitig <- as.formula(paste0("mitigINIT ~ Sales+nr+oldfinguid+", independents))
INITYdete <- as.formula(paste0("deteINIT ~ Sales+nr+oldfinguid+", independents))

#determine whether the amounts are given:
#INITBTmodelY <- train(INITY, data=train.data, method="rpart", trControl=trainControl("cv", number=15))
#INITBTmodelYBA <- train(INITYBA, data=train.data, method="rpart", trControl=trainControl("cv", number=15)) #  , tuneLength=4)
if(i == 2){INITBTmodelYAA <- train(INITYAA, data=train.data, method="rpart", trControl=trainControl("cv", number=15))}else{print("always AA")} #, tuneLength=4)
if(i != 1){print("skipJA-agr")}else{
if(nrow(filter(train.data, train.data[["aggravINIT"]] == 1)) < 3){next}else{
INITBTmodelYaggrav <-train(INITYaggrav, data=train.data, method="rpart", trControl=trainControl("cv", number=15))} #, tuneLength=4)
}
INITBTmodelYmitig <-train(INITYmitig, data=train.data, method="rpart", trControl=trainControl("cv", number=15)) #, tuneLength=4)
INITBTmodelYdete <-train(INITYdete, data=train.data, method="rpart", trControl=trainControl("cv", number=15))

#define the formula for the rpart training
Y <- as.formula(paste0("ultfineNOM ~ ability_pay+Sales+nr+oldfinguid+",independents))
YBA <- as.formula(paste0("Base ~ Sales+nr+oldfinguid+",independents))
YAA <- as.formula(paste0("additional ~ Sales+nr+oldfinguid+", independents))
Yaggrav <- as.formula(paste0("aggrav ~ Sales+nr+oldfinguid+", independents))
Ymitig <- as.formula(paste0("mitig ~ Sales+nr+oldfinguid+", independents))
Ydete <- as.formula(paste0("dete ~ Sales+nr+oldfinguid+", independents))


#select cases only if Initial showed an amount
train.dataY <- filter(train.dataY, train.data$ultfineNOMINIT == 1)
if(nrow(train.dataY) < 3){next}else{
BTmodelY <- train(Y, data=train.dataY, method="rpart", trControl=trainControl("cv", number=15))} #  , tuneLength=4)
train.dataYBA <- filter(train.data, train.data$BaseINIT == 1)
if(nrow(train.dataYBA) < 3){next}else{
BTmodelYBA <- train(YBA, data=train.dataYBA, method="rpart", trControl=trainControl("cv", number=15))} #  , tuneLength=4)
train.dataYAA <- filter(train.data, train.data$additionalINIT == 1)
if(nrow(train.dataYAA) < 3){next}else{
BTmodelYAA <- train(YAA, data=train.dataYAA, method="rpart", trControl=trainControl("cv", number=5))} #, tuneLength=4)

if(i != 1){print("skipJA-agr")}else{
train.dataYaggrav <- filter(train.data, train.data$aggravINIT == 1)
if(nrow(train.dataYaggrav) < 3){next}else{
mtry <- try(BTmodelYaggrav <-train(Yaggrav, data=train.dataYaggrav, method="rpart", trControl=trainControl("cv", number=5)))
if(inherits(mtry, "try-error")){next}else{BTmodelYaggrav <-train(Yaggrav, data=train.dataYaggrav, method="rpart", trControl=trainControl("cv", number=5))}} #, tuneLength=4)
}
train.dataYmitig <- filter(train.data, train.data$mitigINIT == 1)
if(nrow(train.dataYmitig) < 3){next}else{
BTmodelYmitig <-train(Ymitig, data=train.dataYmitig, method="rpart", trControl=trainControl("cv", number=5))} #, tuneLength=4)
train.dataYdete <- filter(train.data, train.data$deteINIT == 1)
if(nrow(train.dataYdete) < 3){next}else{
BTmodelYdete <-train(Ydete, data=train.dataYdete, method="rpart", trControl=trainControl("cv", number=5))} #, tuneLength=4)there are very few deterrence instances
print("i is::::")
print(i)
print("DONE WITH TRAINING on test")

#save tree models for:
 #the actual fine amounts
if(i == 1){
finalmodels_all[[q]][[i]][[1]] <- list(BTmodelY[["finalModel"]],BTmodelYBA[["finalModel"]], BTmodelYAA[["finalModel"]], BTmodelYaggrav[["finalModel"]], BTmodelYmitig[["finalModel"]], BTmodelYdete[["finalModel"]])
}else{if(i == 2){finalmodels_all[[q]][[i]][[1]] <- list(BTmodelY[["finalModel"]],BTmodelYBA[["finalModel"]], BTmodelYAA[["finalModel"]], BTmodelYAA[["finalModel"]], BTmodelYmitig[["finalModel"]], BTmodelYdete[["finalModel"]])
}else{finalmodels_all[[q]][[i]][[1]] <- list(BTmodelY[["finalModel"]],BTmodelYBA[["finalModel"]], BTmodelYAA[["finalModel"]], BTmodelYAA[["finalModel"]], BTmodelYmitig[["finalModel"]], BTmodelYdete[["finalModel"]])
}}

BTmodelYAA[["xlevels"]] <- levels(my_data[["sector"]]) #union(BTmodelYAA[["xlevels"]], extralevels)
if(i != 1){print("skipagrja")}else{
BTmodelYaggrav[["xlevels"]] <- levels(my_data[["sector"]])
}
BTmodelYmitig[["xlevels"]] <- levels(my_data[["sector"]]) #union(BTmodelYmitig[["xlevels"]], levels(my_data[["sector"]]))
BTmodelYdete[["xlevels"]] <- levels(my_data[["sector"]] )#union(BTmodelYdete[["xlevels"]], levels(my_data[["sector"]]))
INITBTmodelYaggrav[["xlevels"]] <- levels(my_data[["sector"]]) #union(INITBTmodelYaggrav[["xlevels"]], levels(my_data[["sector"]]))
INITBTmodelYmitig[["xlevels"]] <- levels(my_data[["sector"]]) #union(INITBTmodelYmitig[["xlevels"]], levels(my_data[["sector"]]))
INITBTmodelYdete[["xlevels"]] <- levels(my_data[["sector"]]) #union(INITBTmodelYdete[["xlevels"]], levels(my_data[["sector"]]))

#make predictions for R2 and RMSE of builds
    #for the INIT amounts
#INITAllpredicted <- INITBTmodelY %>% predict(test.data)
#R2testAll <- R2(Allpredicted, test.data$ultfineNOM)
#RMSEtestAll <- RMSE(Allpredicted, test.data$ultfineNOM)
#INITBApredicted <- INITBTmodelYBA %>% predict(test.data)
#R2testBA <- R2(BApredicted, test.data[["Base"]])
#RMSEtestBA <- RMSE(BApredicted, test.data[["Base"]])
if(i == 2){
INITAApredicted <- INITBTmodelYAA %>% predict(test.data)
INITAApredicted <- as.numeric(as.character(INITAApredicted))
R2testINITAA <- R2(as.numeric(as.character(INITAApredicted)), as.numeric(as.character(test.data[["additionalINIT"]])))
INITAApredictedall <- INITBTmodelYAA %>% predict(my_data)
R2allINITAA <- R2(as.numeric(as.character(INITAApredictedall)), as.numeric(as.character(my_data[["additionalINIT"]])))
}else{INITAApredicted <- 1}
#RMSEtestAA <- RMSE(AApredicted, test.data[["additional"]])
if(i != 1){INITAggravpredicted <- 0}else{
INITAggravpredicted <- INITBTmodelYaggrav %>% predict(test.data)
INITAggravpredicted <- as.numeric(as.character(INITAggravpredicted))

R2testINITAggrav <- R2(INITAggravpredicted, as.numeric(as.character(test.data[["aggravINIT"]])))
INITAggravpredictedall <- INITBTmodelYaggrav %>% predict(my_data)
R2allINITAggrav <- R2(as.numeric(as.character(INITAggravpredictedall)), as.numeric(as.character(my_data[["aggravINIT"]])))
}
INITMitigpredicted <- INITBTmodelYmitig %>% predict(test.data)
INITMitigpredicted <- as.numeric(as.character(INITMitigpredicted))

R2testINITMitig <- R2(INITMitigpredicted, as.numeric(as.character(test.data[["mitigINIT"]])))
INITMitigpredictedall <- INITBTmodelYmitig %>% predict(my_data)
R2allINITMitig <- R2(as.numeric(as.character(INITMitigpredictedall)), as.numeric(as.character(my_data[["mitigINIT"]])))

INITDetepredicted <- INITBTmodelYdete %>% predict(test.data)
INITDetepredicted <- as.numeric(as.character(INITDetepredicted))

R2testINITDete <- R2(INITDetepredicted, as.numeric(as.character(test.data[["deteINIT"]])))
INITDetepredictedall <- INITBTmodelYdete %>% predict(my_data)
R2allINITDete <- R2(as.numeric(as.character(INITDetepredictedall)), as.numeric(as.character(my_data[["deteINIT"]])))

   #for the amounts itself
Allpredicted <- BTmodelY %>% predict(test.data)
Allpredicted <- Allpredicted
R2testAll <- R2(Allpredicted, test.data$ultfineNOM)
RMSEtestAll <- RMSE(Allpredicted, test.data$ultfineNOM)

BApredicted <- BTmodelYBA %>% predict(test.data)
BApredicted <- BApredicted
R2testBA <- R2(BApredicted, test.data[["Base"]])
RMSEtestBA <- RMSE(BApredicted, test.data[["Base"]])

AApredicted <- BTmodelYAA %>% predict(test.data)
AApredicted <- AApredicted
R2testAA <- R2((as.numeric(as.character(INITAApredicted))*as.numeric(AApredicted)), test.data[["additional"]])
RMSEtestAA <- RMSE((as.numeric(as.character(INITAApredicted))*as.numeric(AApredicted)), test.data[["additional"]])

if(i != 1){Aggravpredicted <- 0
R2testaggrav <- 0
RMSEtestaggrav <- 1
}else{
Aggravpredicted <- BTmodelYaggrav %>% predict(test.data)
Aggravpredicted <- Aggravpredicted
R2testaggrav <- R2((INITAggravpredicted*Aggravpredicted), test.data[["aggrav"]])
RMSEtestaggrav <- RMSE((INITAggravpredicted*Aggravpredicted), test.data[["aggrav"]])}

Mitigpredicted <- BTmodelYmitig %>% predict(test.data)
Mitigpredicted <- Mitigpredicted
R2testmitig <- R2((INITMitigpredicted*Mitigpredicted), test.data[["mitig"]])
RMSEtestmitig <- RMSE((INITMitigpredicted*Mitigpredicted), test.data[["mitig"]])

Detepredicted <- BTmodelYdete %>% predict(test.data)
Detepredicted <- Detepredicted
R2testdete <- R2((INITDetepredicted*Detepredicted), test.data[["dete"]])
RMSEtestdete <- RMSE((INITDetepredicted*Detepredicted), test.data[["dete"]])


if(i == 1){
predictedvalueswithbuild <- (1-test.data[["ability_pay"]])*(test.data[["Sales"]]*((((((BApredicted)*(test.data[["duration"]]))+(AApredicted*INITAApredicted))*(1+((Aggravpredicted*INITAggravpredicted)-(Mitigpredicted*INITMitigpredicted))))*(1+(Detepredicted*INITDetepredicted)))*(1-test.data[["LA"]])))
}else{predictedvalueswithbuild <- (1-test.data[["ability_pay"]])*(test.data[["Sales"]]*((((((BApredicted*(1+0))*(test.data[["duration"]]))+(AApredicted*INITAApredicted))*(1+((Aggravpredicted*INITAggravpredicted)-(Mitigpredicted*INITMitigpredicted))))*(1+(Detepredicted*INITDetepredicted)))*(1-test.data[["LA"]])))
}

Allpredicted <- Allpredicted
var0 <- RMSE(Allpredicted, test.data$ultfineNOM)
var02 <- R2(Allpredicted, test.data$ultfineNOM)
varout1 <- RMSE(predictedvalueswithbuild,  test.data$ultfiCALCZTN)
varout2 <- R2(predictedvalueswithbuild, test.data$ultfiCALCZTN)


test2.data <- filter(test.data, test.data$legal_max==0)
#INITBApredictedB <- INITBTmodelYBA %>% predict(test2.data)
if(i == 2){INITAApredictedB <- INITBTmodelYAA %>% predict(test2.data)
INITAApredictedB <- as.numeric(as.character(INITAApredictedB ))
}else{INITAApredictedB <- 1}
if(i != 1){print(INITAggravpredictedB <- 0)}else{
INITAggravpredictedB <- INITBTmodelYaggrav %>% predict(test2.data) #hier is de fout
INITAggravpredictedB <- as.numeric(as.character(INITAggravpredictedB))}
INITMitigpredictedB <- INITBTmodelYmitig %>% predict(test2.data)
INITMitigpredictedB <- as.numeric(as.character(INITMitigpredictedB))
INITDetepredictedB <- INITBTmodelYdete %>% predict(test2.data)
INITDetepredictedB <- as.numeric(as.character(INITDetepredictedB))

BApredictedB <- BTmodelYBA %>% predict(test2.data)
BApredictedB <- BApredictedB
R2(BApredictedB, test2.data[["Base"]])
AApredictedB <- BTmodelYAA %>% predict(test2.data)
AApredictedB <- AApredictedB
R2((INITAApredictedB*AApredictedB), test2.data[["additional"]])
if(i != 1){AggravpredictedB <- 0}else{
AggravpredictedB <- BTmodelYaggrav %>% predict(test2.data)
AggravpredictedB <- AggravpredictedB
R2((INITAggravpredictedB*AggravpredictedB), test2.data[["aggrav"]])}
MitigpredictedB <- BTmodelYmitig %>% predict(test2.data)
MitigpredictedB <- MitigpredictedB
R2((INITMitigpredictedB*MitigpredictedB), test2.data[["mitig"]])
DetepredictedB <- BTmodelYdete %>% predict(test2.data)
DetepredictedB <- DetepredictedB
R2((INITDetepredictedB*DetepredictedB), test2.data[["dete"]])

print("i is::::")
print(i)
if(i == 1){
predictedvalueswithbuildB <- (1-test2.data[["ability_pay"]])*(test2.data[["Sales"]]*((((((BApredictedB)*(1+test2.data[["duration"]]))+(INITAApredictedB*AApredictedB))*(1+((INITAggravpredictedB*AggravpredictedB)-(INITMitigpredictedB*MitigpredictedB))))*(1+(INITDetepredictedB*DetepredictedB)))*(1-test2.data[["LA"]])))
}else{predictedvalueswithbuildB <- (1-test2.data[["ability_pay"]])*(test2.data[["Sales"]]*((((((BApredictedB*(1+0))*(1+test2.data[["duration"]]))+(INITAApredictedB*AApredictedB))*(1+((INITAggravpredictedB*AggravpredictedB)-(INITMitigpredictedB*MitigpredictedB))))*(1+(INITDetepredictedB*DetepredictedB)))*(1-test2.data[["LA"]])))
}

varout3 <- RMSE(predictedvalueswithbuildB,  test2.data$ultfineNOM)
varout4 <- R2(predictedvalueswithbuildB, test2.data$ultfineNOM)

my2_data <- filter(my_data, my_data$legal_max==0)
Ypredicted2 <- BTmodelY %>% predict(my2_data)
Ypredicted2 <- Ypredicted2
BApredicted2 <- BTmodelYBA %>% predict(my2_data)
BApredicted2 <- BApredicted2
AApredicted2 <- BTmodelYAA %>% predict(my2_data)
AApredicted2 <- AApredicted2
if(i != 1){Aggravpredicted2 <- 0}else{
Aggravpredicted2 <- BTmodelYaggrav %>% predict(my2_data)
Aggravpredicted2 <- Aggravpredicted2
}
Mitigpredicted2 <- BTmodelYmitig %>% predict(my2_data)
Mitigpredicted2 <- Mitigpredicted2
Detepredicted2 <- BTmodelYdete %>% predict(my2_data)
Detepredicted2 <- Detepredicted2

#INITYpredicted2 <- INITBTmodelY %>% predict(my2_data)
R2allY <- R2(Ypredicted2, my2_data$ultfineNOM)
RMSEallY <- RMSE(Ypredicted2, my2_data$ultfineNOM)
#INITBApredicted2 <- INITBTmodelYBA %>% predict(my2_data)
R2allBA <- R2(BApredicted2, my2_data[["Base"]])
RMSEallBA <- RMSE(BApredicted2, my2_data[["Base"]])
if(i == 2){
INITAApredicted2 <- INITBTmodelYAA %>% predict(my2_data)}else{INITAApredicted2 <- 1}
INITAApredicted2 <- as.numeric(as.character(INITAApredicted2))
R2allAA <- R2((AApredicted2*INITAApredicted2), my2_data[["additional"]])
RMSEallAA <- RMSE((AApredicted2*INITAApredicted2), my2_data[["additional"]])
if(i != 1){INITAggravpredicted2 <- 0}else{
INITAggravpredicted2 <- INITBTmodelYaggrav %>% predict(my2_data)
INITAggravpredicted2 <- as.numeric(as.character(INITAggravpredicted2))
R2allaggrav <- R2((Aggravpredicted2*INITAggravpredicted2), my2_data[["aggrav"]])
RMSEallaggrav <- RMSE((Aggravpredicted2*INITAggravpredicted2), my2_data[["aggrav"]])}
INITMitigpredicted2 <- INITBTmodelYmitig %>% predict(my2_data)
INITMitigpredicted2 <- as.numeric(as.character(INITMitigpredicted2))
R2allmitig <- R2((Mitigpredicted2*INITMitigpredicted2), my2_data[["mitig"]])
RMSEallmitig <- RMSE((Mitigpredicted2*INITMitigpredicted2), my2_data[["mitig"]])
INITDetepredicted2 <- INITBTmodelYdete %>% predict(my2_data)
INITDetepredicted2 <- as.numeric(as.character(INITDetepredicted2))
R2alldete <- R2((Detepredicted2*INITDetepredicted2), my2_data[["dete"]])
RMSEalldete <- RMSE((Detepredicted2*INITDetepredicted2), my2_data[["dete"]])
#plot and save trees
if(i==1){folderpath <- paste0(mainfolder,"treeplots/NK/")}else{if(i==2){folderpath <- paste0(mainfolder,"treeplots/JA/")}else{if(i==3){folderpath <- paste0(mainfolder,"treeplots/MV/")}else{folderpath <- paste0(mainfolder,"treeplots/combiJA_MV/")}}}

folderpath2 <- paste0(folderpath, "last/Y/")

dir.create(folderpath2)
folderpath2 <- paste0(folderpath, "last/Y/AMOUNT/")
dir.create(folderpath2)

finalpath <- paste0(folderpath2, "seed_",setit,"BTmodelY_train_R2test_",R2testAll,"_R2all_",R2allY,".jpeg")

jpeg(finalpath)
rpart.plot(BTmodelY[["finalModel"]])
dev.off()

folderpath2 <- paste0(folderpath, "last/BA/")
dir.create(folderpath2)
folderpath2 <- paste0(folderpath, "last/BA/AMOUNT/")
dir.create(folderpath2)

finalpath <- paste0(folderpath2,"seed_",setit,"BTmodelYBA_train_R2test_",R2testBA,"_R2all_",R2allBA,".jpeg")
jpeg(finalpath)
rpart.plot(BTmodelYBA[["finalModel"]])
dev.off()

folderpath2 <- paste0(folderpath, "last/AA/")
dir.create(folderpath2)
folderpath2 <- paste0(folderpath, "last/AA/AMOUNT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"BTmodelYAA_train_R2test_",R2testAA,"_R2all_",R2allAA,".jpeg")
jpeg(finalpath)
rpart.plot(BTmodelYAA[["finalModel"]])
dev.off()
if( i != 2){print("skipskip")}else{
folderpath2 <- paste0(folderpath, "last/AA/INIT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"INITBTmodelYAA_train_R2test_",R2testINITAA,"_R2all_",R2allINITAA,".jpeg")
jpeg(finalpath)
rpart.plot(INITBTmodelYAA[["finalModel"]])
dev.off()
}

folderpath2 <- paste0(folderpath, "last/aggrav/")
dir.create(folderpath2)
folderpath2 <- paste0(folderpath, "last/aggrav/AMOUNT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"BTmodelYaggrav_train_R2test_",R2testaggrav,"_R2all_",R2allaggrav,".jpeg")
if(i != 1){print("skip tree png")}else{
jpeg(finalpath)
rpart.plot(BTmodelYaggrav[["finalModel"]])
dev.off()
}
folderpath2 <- paste0(folderpath, "last/aggrav/INIT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"INITBTmodelYaggrav_train_R2test_",R2testINITAggrav,"_R2all_",R2allINITAggrav,".jpeg")
if(i != 1){print("skip tree png")}else{
jpeg(finalpath)
rpart.plot(INITBTmodelYaggrav[["finalModel"]])
dev.off()
}
folderpath2 <- paste0(folderpath, "last/mitig/")
dir.create(folderpath2)
folderpath2 <- paste0(folderpath, "last/mitig/AMOUNT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"BTmodelYmitig_train_R2test_",R2testmitig,"_R2all_",R2allmitig,".jpeg")
jpeg(finalpath)
rpart.plot(BTmodelYmitig[["finalModel"]])
dev.off()

folderpath2 <- paste0(folderpath, "last/mitig/INIT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"INITBTmodelYmitig_train_R2test_",R2testINITMitig,"_R2all_",R2allINITMitig,".jpeg")
jpeg(finalpath)
rpart.plot(INITBTmodelYmitig[["finalModel"]])
dev.off()

folderpath2 <- paste0(folderpath, "last/dete/")
dir.create(folderpath2)
folderpath2 <- paste0(folderpath, "last/dete/AMOUNT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"commis_","INITBTmodelYdete_train_R2test_",R2testdete,"_R2all_",R2alldete,".jpeg")
jpeg(finalpath)
rpart.plot(BTmodelYdete[["finalModel"]])
dev.off()
folderpath2 <- paste0(folderpath, "last/dete/INIT/")
dir.create(folderpath2)
finalpath <- paste0(folderpath2,"seed_",setit,"commis_","BTmodelYdete_train_R2test_",R2testINITDete,"_R2all_",R2allINITDete,".jpeg")
jpeg(finalpath)
rpart.plot(INITBTmodelYdete[["finalModel"]])
dev.off()

print("DONE WITH JPEGS")
#bundelthebuilds <- matrix(ncol=1, nrow=14)
bundelthebuilds[1,i] <- R2testAll
bundelthebuilds[2,i] <- R2allY
bundelthebuilds[3,i] <- R2testBA
bundelthebuilds[4,i] <- R2allBA
bundelthebuilds[5,i] <- R2testAA
bundelthebuilds[6,i] <- R2allAA
bundelthebuilds[7,i] <- R2testaggrav
bundelthebuilds[8,i] <- R2allaggrav
bundelthebuilds[9,i] <- R2testmitig
bundelthebuilds[10,i] <- R2allmitig
bundelthebuilds[11,i] <- R2testdete
bundelthebuilds[12,i] <- R2alldete

#RMSEbundelthebuilds <- matrix(ncol=1, nrow=14)
RMSEbundelthebuilds[1,i] <- RMSEtestAll
RMSEbundelthebuilds[2,i] <- RMSEallY
RMSEbundelthebuilds[3,i] <- RMSEtestBA
RMSEbundelthebuilds[4,i] <- RMSEallBA
RMSEbundelthebuilds[5,i] <- RMSEtestAA
RMSEbundelthebuilds[6,i] <- RMSEallAA
RMSEbundelthebuilds[7,i] <- RMSEtestaggrav
RMSEbundelthebuilds[8,i] <- RMSEallaggrav
RMSEbundelthebuilds[9,i] <- RMSEtestmitig
RMSEbundelthebuilds[10,i] <- RMSEallmitig
RMSEbundelthebuilds[11,i] <- RMSEtestdete
RMSEbundelthebuilds[12,i] <- RMSEalldete

if(i==1){
predictedvalueswithbuild2 <- (1-my2_data[["ability_pay"]])*(my2_data[["Sales"]]*((((((BApredicted2)*(my2_data[["duration"]]))+(as.numeric(as.character(INITAApredicted2))*AApredicted2))*(1+((as.numeric(as.character(INITAggravpredicted2))*Aggravpredicted2)-(as.numeric(as.character(INITMitigpredicted2))*Mitigpredicted2))))*(1+(as.numeric(as.character(INITDetepredicted2))*Detepredicted2)))*(1-my2_data[["LA"]])))
}else{
predictedvalueswithbuild2 <- (1-my2_data[["ability_pay"]])*(my2_data[["Sales"]]*((((((BApredicted2*(1+0))*(my2_data[["duration"]]))+(as.numeric(as.character(INITAApredicted2))*AApredicted2))*(1+(as.numeric(as.character(INITAggravpredicted2))*Aggravpredicted2)-(as.numeric(as.character(INITMitigpredicted2))*Mitigpredicted2)))*(1+(as.numeric(as.character(INITDetepredicted2))*Detepredicted2)))*(1-my2_data[["LA"]])))
}

varout5 <-  RMSE(predictedvalueswithbuild2,  my2_data$ultfineNOM)
varout6 <- R2(predictedvalueswithbuild2, my2_data$ultfineNOM)
if(i==1){
predictedvalueswithbuildQQ <- ((((((BApredicted2)*(my2_data[["duration"]]))+(as.numeric(as.character(INITAApredicted2))*AApredicted2))*(1+((as.numeric(as.character(INITAggravpredicted2))*Aggravpredicted2)-(as.numeric(as.character(INITMitigpredicted2))*Mitigpredicted2))))*(1+(as.numeric(as.character(INITDetepredicted2))*Detepredicted2)))*(1-my2_data[["LA"]]))
}else{
predictedvalueswithbuildQQ <- ((((((BApredicted2*(1+0))*(my2_data[["duration"]]))+(as.numeric(as.character(INITAApredicted2))*AApredicted2))*(1+((as.numeric(as.character(INITAggravpredicted2))*Aggravpredicted2)-(as.numeric(as.character(INITMitigpredicted2))*Mitigpredicted2))))*(1+(as.numeric(as.character(INITDetepredicted2))*Detepredicted2)))*(1-my2_data[["LA"]]))
}

varout5Q <-  RMSE(predictedvalueswithbuildQQ,  my2_data$utfperc)
varout6Q <- R2(predictedvalueswithbuildQQ, my2_data$utfperc)

if(i==1){folderpath <- paste0(mainfolder,"fitnessplots/nominal/NK/")}else{if(i==2){folderpath <- paste0(mainfolder,"fitnessplots/nominal/JA/")}else{if(i==3){folderpath <- paste0(mainfolder,"fitnessplots/nominal/MV/")}else{folderpath <- paste0(mainfolder,"fitnessplots/nominal/combiJA_MV/")}}}

folderpath2 <- paste0(folderpath, "last/")

finalpathX <- paste0(folderpath2,"seed_",setit,"R2_",varout6,"RMSE_",varout5,".png")
jpeg(finalpathX)
x <- predictedvalueswithbuild2
y <- my2_data$ultfineNOM
datf <- data.frame(x,y)
fitnessplot <- ggplot(datf,aes(x=x,y=y)) +
    geom_point()+
    stat_smooth()
print(fitnessplot)
dev.off()



if(i==1){folderpath <- paste0(mainfolder,"fitnessplots/percentage/NK/")}else{if(i==2){folderpath <- paste0(mainfolder,"fitnessplots/percentage/JA/")}else{if(i==3){folderpath <- paste0(mainfolder,"fitnessplots/percentage/MV/")}else{folderpath <- paste0(mainfolder,"fitnessplots/percentage/combiJA_MV/")}}}


folderpath2 <- paste0(folderpath, "last/")
finalpathX <- paste0(folderpath2,"seed_",setit,"R2_",varout6Q,"RMSE_",varout5Q,".png")
jpeg(finalpathX)
x <- predictedvalueswithbuildQQ
y <- my2_data$utfperc
datf <- data.frame(x,y)
fitnessplot <- ggplot(datf,aes(x=x,y=y)) +
    geom_point()+
    stat_smooth()
print(fitnessplot)
dev.off()
print("fitnessplots ook done")

print("DONE FOR I")
}
print("DONE FOR Q")
}

print("###################COMPLETELY FINISHED########################")

library(camtrapR)
library(tidyverse)

# generate record table
#records_raw <- recordTable(inDir = "S3_pickout_073020",
#                       IDfrom = "directory",
#                       removeDuplicateRecords = FALSE)

records_raw <- recordTable(inDir = "S3_pickout_soft_iter_081120",
                           IDfrom = "directory",
                           removeDuplicateRecords = FALSE)

# select columns of interest
records <- records_raw %>% 
    select(Species, FileName) %>% 
    rename(CorrectID = Species)

# fix file names
records$FileName <- gsub(":::", "///", records$FileName)

# add columns for correct/incorrect
records$Status <- "NA"
for (i in 1:nrow(records)) {
    if(records$CorrectID[i] == "Correct") {
        records$Status[i] <- "Correct"
        records$CorrectID[i] <- "NA"
    } else if (records$CorrectID[i] %in% c("Waterbuck_but_also_correct", 
                                           "Impala_but_also_correct", 
                                           "Baboon_but_also_correct",
                                           "Mongoose_banded_but_also_correct",
                                           "Warthog_but_also_correct",
                                           "Waterbuck_but_also_correct")) {
        records$Status[i] <- "Additional_species"
    }
    else {records$Status[i] <- "Incorrect"}
}

# reorder columns
records <- records %>% 
    select(Status, FileName, CorrectID) %>% 
    arrange(Status, CorrectID)

# export
write.csv(records, "S3_pickout_soft_iter_081120/validated_records.csv", row.names=F)

# load libraries used in script
library(data.table)
library(reshape2)
library(dplyr)
library(magrittr)

# ---------------------------------------------------------------------------
# SET CONSTANTS FOR DATA FILES' REMOTE & LOCAL PATHS
# ---------------------------------------------------------------------------
ZIP_DATA_URL = "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
ZIP_DATA_LOCAL_PATH = "course-project-data.zip"
# directory paths
DIR_EXTRACT = "./" # current working directory
DIR_TRAIN_DATA = paste0(DIR_EXTRACT,"UCI HAR Dataset/train/")
DIR_TEST_DATA = paste0(DIR_EXTRACT,"UCI HAR Dataset/test/")
# metadata file w/ definitions of feature columns
FILE_META_FEATURES =          paste0(DIR_EXTRACT,"UCI HAR Dataset/features.txt")
# metadata file w/ activity labels
FILE_META_ACTIVITIES =        paste0(DIR_EXTRACT,"UCI HAR Dataset/activity_labels.txt")
# train data file names
FILE_TRAIN_SUBJECT_DATA =     paste0(DIR_TRAIN_DATA,"subject_train.txt")
FILE_TRAIN_X_DATA =           paste0(DIR_TRAIN_DATA,"X_train.txt")
FILE_TRAIN_Y_DATA =           paste0(DIR_TRAIN_DATA,"y_train.txt")
# test data file names
FILE_TEST_SUBJECT_DATA =      paste0(DIR_TEST_DATA,"subject_test.txt")
FILE_TEST_X_DATA =            paste0(DIR_TEST_DATA,"X_test.txt")
FILE_TEST_Y_DATA =            paste0(DIR_TEST_DATA,"y_test.txt")
# summary data file name (file to write at end)
FILE_SUMMARY_DATA =           "subject_activity_measurement_means.txt"

# ---------------------------------------------------------------------------
# GET DATA FILES LOCALLY
# 1) check whether project data files exist in expected location
# 2) if not, downloads zip file (if missing) and unzips it
# ---------------------------------------------------------------------------
#confirm data files are present; if not, download and unzip
if (!all(
     file.exists(
          c(FILE_TRAIN_SUBJECT_DATA, FILE_TRAIN_X_DATA, FILE_TRAIN_Y_DATA,
            FILE_TEST_SUBJECT_DATA, FILE_TEST_X_DATA, FILE_TEST_Y_DATA,
            FILE_META_FEATURES, FILE_META_ACTIVITIES)
          )
     )
)
{ # -- FILES ARE MISSING IF CODE HITS HERE -- 
     #download zip file from web if not already saved
     if (!file.exists(ZIP_DATA_LOCAL_PATH)) {
          dlSuccess <- download.file(ZIP_DATA_URL,ZIP_DATA_LOCAL_PATH)
          if (!dlSuccess == 0)
               stop(
                    sprintf("Download attempt data zip file at %s failed. Stopping...",
                            ZIP_DATA_URL)
               )
     }
     
     # extract data files
     extracted_files <-
          unzip(ZIP_DATA_LOCAL_PATH,
                exdir=DIR_EXTRACT,
                overwrite=TRUE,
                list=FALSE,
                unzip="internal"
          )
     if (length(extracted_files) > 0) {
          message(
               sprintf(
                    "The following data files were extracted to '%s':",
                    DIR_EXTRACT)
          )
          cat(extracted_files, sep="\n")
     }
     else
          stop("Data file extraction FAILED! Stopping...")
}


# ---------------------------------------------------------------------------
# DETERMINE SUBSET X (FEATURE) COLUMNS TO USE BASED ON FEATURES METADATA FILE
# ---------------------------------------------------------------------------
# use features metadata file to find columns of interest & their descriptive names
meta_features <- fread(FILE_META_FEATURES)
# get vector of feature names
feature_names <- meta_features$V2
# find indices of mean & std variables
mean_var_indices <- grep("-mean()", feature_names, fixed=TRUE)
std_var_indices <- grep("-std()", feature_names, fixed=TRUE)
# combine and sort indices for mean & std columns
mean_std_var_indices <- sort(c(mean_var_indices, std_var_indices))
# get names of mean & std variables
mean_std_var_names <- feature_names[mean_std_var_indices]


# ---------------------------------------------------------------------------
# LOAD X data files into single data.table with only mean/std features
# 1) load into data.tables
# 2) subset each w/ only mean/std feature columns
# 3) union rows together
# ---------------------------------------------------------------------------
#  ** NOTE: bug with fread() causes crash when used with X data files, 
#    so using read.table() instead **
train_x_data <- as.data.table(
     read.table(FILE_TRAIN_X_DATA,
          header=FALSE,
          nrows = 7500,
          colClass = "numeric", # all columns are numeric
          comment.char = ""
     )
)
test_x_data <- as.data.table(
     read.table(FILE_TEST_X_DATA,
                header=FALSE,
                nrows = 3000,
                colClass = "numeric", # all columns are numeric
                comment.char = ""
     )
)
# store only subset with features of interest
train_x_data <- train_x_data[,mean_std_var_indices,with=FALSE]
test_x_data <- test_x_data[,mean_std_var_indices,with=FALSE]
# store old feature variable names to overwrite them later
old_feature_col_names <- copy(names(train_x_data))
# add identification columns before unioning/merging
train_x_data[,`:=`(test_flag=FALSE,sub_row_id=1:.N)]
test_x_data[,`:=`(test_flag=TRUE,sub_row_id=1:.N)]
# union X data together between training and test files
x_data <- rbind(train_x_data, test_x_data)             
# remove separated X data sets from memory
rm(train_x_data, test_x_data)
# rename columns using feature names from meta file, 
#  but converted to syntactically valid names
valid_mean_std_var_names <- make.names(gsub("([()])", "", mean_std_var_names))
setnames(x_data, old_feature_col_names, valid_mean_std_var_names)
# add overall row identified (train first, then test rows)
x_data[,row_id:=1:.N]
# reorder columns so that identifier columns are at the beginning
setcolorder(x_data, c("row_id", "test_flag", "sub_row_id", valid_mean_std_var_names))
# view x data's structure & first few rows
str(x_data)
head(x_data)

# ---------------------------------------------------------------------------
# LOAD Y data files
# 1) load into data.tables
# 2) union into single table
# 3) convert activity variable from int to factor
# ---------------------------------------------------------------------------
train_y_data <- fread(FILE_TRAIN_Y_DATA, header=FALSE)
test_y_data <- fread(FILE_TEST_Y_DATA, header=FALSE)
# add identification columns before unioning/merging
train_y_data[,`:=`(test_flag=FALSE,sub_row_id=1:.N)]
test_y_data[,`:=`(test_flag=TRUE,sub_row_id=1:.N)]
# union Y data together between training and test files
y_data <- rbind(train_y_data, test_y_data)
# remove separated Y data sets from memory
rm(train_y_data, test_y_data)
# add overall row identified (train first, then test rows)
y_data[,row_id:=1:.N]


# ---------------------------------------------------------------------------
# RENAME & CONVERT Y TO FACTOR w/ LEVELS FROM ACTIVITY LABEL METADATA
# ---------------------------------------------------------------------------
meta_activity_data <- fread(FILE_META_ACTIVITIES, header=FALSE)
# rename single data set variable to "activity"
setnames(y_data, "V1", "activity")
# store activity column as factor with level names from metadata file
f_activity <- as.factor(y_data$activity)
levels(f_activity) <- meta_activity_data$V2 # activity labels
y_data$activity <- f_activity
# reorder columns so that identifier columns are at the beginning
setcolorder(y_data, c("row_id", "test_flag", "sub_row_id", "activity"))
# view Y data's structure & first few rows
str(y_data)
head(y_data)

# ---------------------------------------------------------------------------
# LOAD SUBJECT data files into data.tables
# ---------------------------------------------------------------------------
train_subject_data <- fread(FILE_TRAIN_SUBJECT_DATA, header=FALSE)
test_subject_data <- fread(FILE_TEST_SUBJECT_DATA, header=FALSE)
# add identification columns before unioning/merging
train_subject_data[,`:=`(test_flag=FALSE,sub_row_id=1:.N)]
test_subject_data[,`:=`(test_flag=TRUE,sub_row_id=1:.N)]
# union SUBJECT data together between training and test files
subject_data <- rbind(train_subject_data, test_subject_data)
# remove separated SUBJECT data sets from memory
rm(train_subject_data, test_subject_data)
# give subject variable a descriptive name
setnames(subject_data, "V1", "subject_num")
# add overall row identified (train first, then test rows)
subject_data[,row_id:=1:.N]
# reorder columns so that identifier columns are at the beginning
setcolorder(subject_data, c("row_id", "test_flag", "sub_row_id", "subject_num"))
# view subject data's structure & first few rows
str(subject_data)
head(subject_data)

# ---------------------------------------------------------------------------
# MERGE X, Y, and SUBJECT data sets together on row identifier
# 1) set row_id as key for each data set
# 2) merge Y & subject data
# 3) merge Y+subject data & X data
# ---------------------------------------------------------------------------
# 1) set keys
setkey(x_data, row_id, test_flag, sub_row_id)
setkey(y_data, row_id, test_flag, sub_row_id)
setkey(subject_data, row_id, test_flag, sub_row_id)
# 2) merge Y & subject
ysubj_data <- merge(y_data, subject_data)
rm(y_data, subject_data)
# 3) merge in X data
combined_data <- merge(ysubj_data, x_data)
rm(ysubj_data, x_data)
# view combined data's structure & first few rows
str(combined_data)
head(combined_data)

# ---------------------------------------------------------------------------
# AVERAGE measurements by activity and subject
# ---------------------------------------------------------------------------
# 1) melt the data such that we see 1 row per subject X activity X measurement
melted_data <-
     melt(combined_data,
          id.vars = c("subject_num", "activity"),
          measure.vars = valid_mean_std_var_names,
          variable.name = "measurement"
     )
# remove combined low-level data from memory since we're done with it
rm(combined_data)
# view melted data's structure & first few rows
str(melted_data)
head(melted_data)

# 2) summarize & order data by subject X activity X measurement 
summary_data <- 
     melted_data %>%
     dplyr::group_by(subject_num, activity, measurement) %>%
     dplyr::summarize(mean.value = mean(value, na.rm=TRUE)) %>%
     dplyr::arrange(subject_num, activity, measurement)
# remove melted data from memory since we're done with it
rm(melted_data)
# view summary data's structure & first few rows
str(summary_data)
head(summary_data)


# ---------------------------------------------------------------------------
# WRITE summary data set to txt file without row names
# --------------------------------------------------------------------------- 
write.table(
     summary_data,
     file=FILE_SUMMARY_DATA,
     col.names=TRUE,
     row.names=FALSE
)
# also, write out numbered measurement variables to facilitate codebook listing
write.table(
     data.frame(
          as.integer(unique(summary_data$measurement)),
          levels(unique(summary_data$measurement))
     ),
     "measurements.txt",
     row.names=FALSE,
     col.names=FALSE,
     sep = " = ",
     quote=FALSE
)

# JHU & Coursera's Getting & Cleaning Data: Course Project  
### *Author:* James Morse  

## About
This document explains how the accompanying script (run_analysis.R) works to 
accomplish the following tasks on top of the [UC Irvine Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones):  

1) Merges the training and the test sets to create one data set.  
2) Extracts only the measurements on the mean and standard deviation for each 
measurement.   
3) Name the data set's activity values using descriptive names.  
4) Label the data set's variables with descriptive names.  
5) Summarize the merged data by storing the mean for every combination of subject, activity, and measurement. *[I chose a narrow data structure for easier summarization as well as future data exploration. My summarized data set could be easily transformed to wide structure using the `dcast()` function.]*  

## Requirements
1) You must have already stored the UC Irvine Data Set files with the expected names and directory locations under your working directory *(see section on constants for details)*
**OR**
you must have a working internet connection with access to allow the script to save the files to your working directory.  

2) You must have the following R packages installed:  
```
library(data.table) # high performance data sets
library(reshape2)   # easy data structure transformation from wide to narrow
library(dplyr)      # easy data summarization / filtering / ordering
library(magrittr)   # enables piping syntax
```

## High-Level Script Steps
1) Set constants used for referencing data files locally and remotely. *[You may change the values of variables in this top section if you prefer different locations/names.]*  

2) Ensure data files are stored locally in expected places.  If not, the script will 
attempt to download the zip file from the URL set in the constants section.  

3) Determine the subset of X feature columns to use based on the features metadata file. *[Note: I interpret these measurements to be the features containing `-mean()` or `-std()` in the feature listing metadata file.]*  

4) For each train/test set of X, Y, and subject data files, load them into `data.table`s, add row identifier columns, and union the train and test rows together. 
For the X data, we subset the data tables down to the desired mean and standard deviations columns before unioning.  After the union, the partitioned 
`data.table`s are removed from memory to conserve memory consumption.  
     
     + New columns called `row_id`, `test_flag`, and `sub_group_id` are added 
     along the way to keep track of individual files as well as to serve as the
     join keys when merging the X, Y, and subject data into a single `data.table`.  
     
     + The X data was loaded using `read.table()` instead of the faster 
     `fread()` due to a bug manifested by the data format. All other files are
     loaded using `fread()`.  
     
     + The Y data's activity variable is converted to a labeled factor using the 
     definitions provided in the activity labels metadata file and then renamed 
     appropriately to `activity`.  
     
     + The subject data's variable is named as `subject_num`.  

5) Merge the X, Y, and subject `data.table` objects into a single `data.table`.  

     + First, each object sets its keys to the combination fo the `row_id`, 
     `test_flag`, and `sub_group_id` columns.  
     
     + The Y and subject data columns are merged first since they are smaller 
     and because we want them to appear before the X columns in the resulting 
     `data.table`.  
     
6) Melt the combined data into a longer, narrower structure with the subject and 
activity columns pivoting each measurement column name into a new generalized 
`measurement` column with the corresponding value in a new `value` column.  

7) Grouping by the subject, activity, and measurement columns, summarize the 
melted data's mean values.  

8) Write the resulting summary data.table to a text file. *[Note that factor columns are written as strings from the defined levels. Doing so takes up a little more space,
but eases the future usability considerably since the data won't need to be 
re-coded.]*  
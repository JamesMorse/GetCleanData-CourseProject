# JHU & Coursera's Getting & Cleaning Data: Course Project  
## Codebook for Subject Activity Measurement Means Data Set  
### *Author:* James Morse  

  
**Data File:** `subject_activity_measurement_means.txt`  
  
**Source:** Data sourced and processed from [UC Irvine Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)  
  
**Column Variables**  
* **`subject_num`** (`integer`): identifier of the person/subject being measured   
* **`activity`** (`factor`): activity occurring during observed measurement  
* **`measurement`** (`factor`): 1 of 66 mean and standard deviation measurements 
(see listing of measurement values below)  
* **`mean.value`** (`numeric`): mean of all observations for corresponding measurement 
for the given `subject_num` and `activity`  
  
**Listing of Measurements w/ Factor Integer Values**  
1 = tBodyAcc.mean.X   
2 = tBodyAcc.mean.Y   
3 = tBodyAcc.mean.Z   
4 = tBodyAcc.std.X   
5 = tBodyAcc.std.Y   
6 = tBodyAcc.std.Z   
7 = tGravityAcc.mean.X   
8 = tGravityAcc.mean.Y   
9 = tGravityAcc.mean.Z   
10 = tGravityAcc.std.X   
11 = tGravityAcc.std.Y   
12 = tGravityAcc.std.Z   
13 = tBodyAccJerk.mean.X   
14 = tBodyAccJerk.mean.Y   
15 = tBodyAccJerk.mean.Z   
16 = tBodyAccJerk.std.X   
17 = tBodyAccJerk.std.Y   
18 = tBodyAccJerk.std.Z   
19 = tBodyGyro.mean.X   
20 = tBodyGyro.mean.Y   
21 = tBodyGyro.mean.Z   
22 = tBodyGyro.std.X   
23 = tBodyGyro.std.Y   
24 = tBodyGyro.std.Z   
25 = tBodyGyroJerk.mean.X   
26 = tBodyGyroJerk.mean.Y   
27 = tBodyGyroJerk.mean.Z   
28 = tBodyGyroJerk.std.X   
29 = tBodyGyroJerk.std.Y   
30 = tBodyGyroJerk.std.Z   
31 = tBodyAccMag.mean   
32 = tBodyAccMag.std   
33 = tGravityAccMag.mean   
34 = tGravityAccMag.std   
35 = tBodyAccJerkMag.mean   
36 = tBodyAccJerkMag.std   
37 = tBodyGyroMag.mean   
38 = tBodyGyroMag.std   
39 = tBodyGyroJerkMag.mean   
40 = tBodyGyroJerkMag.std   
41 = fBodyAcc.mean.X   
42 = fBodyAcc.mean.Y   
43 = fBodyAcc.mean.Z   
44 = fBodyAcc.std.X   
45 = fBodyAcc.std.Y   
46 = fBodyAcc.std.Z   
47 = fBodyAccJerk.mean.X   
48 = fBodyAccJerk.mean.Y   
49 = fBodyAccJerk.mean.Z   
50 = fBodyAccJerk.std.X   
51 = fBodyAccJerk.std.Y   
52 = fBodyAccJerk.std.Z   
53 = fBodyGyro.mean.X   
54 = fBodyGyro.mean.Y   
55 = fBodyGyro.mean.Z   
56 = fBodyGyro.std.X   
57 = fBodyGyro.std.Y   
58 = fBodyGyro.std.Z   
59 = fBodyAccMag.mean   
60 = fBodyAccMag.std   
61 = fBodyBodyAccJerkMag.mean   
62 = fBodyBodyAccJerkMag.std   
63 = fBodyBodyGyroMag.mean   
64 = fBodyBodyGyroMag.std   
65 = fBodyBodyGyroJerkMag.mean   
66 = fBodyBodyGyroJerkMag.std   
# getting_and_cleaning_data_project
Final project for Getting and Cleaning data course from John Hopkins University.


### Introduction

The solution uses two scripts to be accomplished:

 * util.R > Has the function download_data_file() to download and extract the data from the URL.
 * run_analysis.R > The main script to generate the tidy data. 
 
<br><br>
The following steps described in the task page are

 1. Merges the training and the test sets to create one data set.
 2. Extracts only the measurements on the mean and standard deviation for each measurement.
 3. Uses descriptive activity names to name the activities in the data set
 4. Appropriately labels the data set with descriptive variable names.
 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
 
 <br>
 Each step is explained as a comment in the run_analysis.R
 
 ## How to run
 
 The main script is the `run_analysis.R` and its expected to be run in the RStudio, but you que run in the command line using

```
	$ Rscript run_analysis.R
```
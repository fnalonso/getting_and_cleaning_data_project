# Introduction
This document describes every step to generate the file "final_report.csv" inside the "data/" directory.
The raw data used  was downloaded from [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

## Requirements

You should create one R script called run_analysis.R that does the following.

1.  Merges the training and the test sets to create one data set.
2.  Extracts only the measurements on the mean and standard deviation for each measurement.
3.  Uses descriptive activity names to name the activities in the data set
4.  Appropriately labels the data set with descriptive variable names.
5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Steps

## Dataset download and data frames creation.
To download the data from the url describe above was implemented a function called `download_data_file` which download, save, unzip and remove the zipped file from disk. The code is located inside the `utils.R` script.

After download the data the following data frames was created using the function `read.table`:
 - activity_labels: Contents from `activity_labels.txt` with the columns names set as "id" and "name".
 - features: Contents from `features.txt` with the columns names set to "id" and "name".
 - test_subject: Contents from `subject_test.txt` with the column named as "id".
 - text_x: Contents from `test_X.txt`.
 - text_y: Contents from `test_y.txt`.
 - train_subject: Contents from `subject_train.txt`.
 - train_x: Contents from `train_X.txt`
 - train_y: Contents from `train_y.txt`
 - 

## Merges the training and the test sets to create one data set.

First the columns was organized to put the measurement data in the end and keep the Subject and Activity in the beginning, to do so the following data frames was created:
```R
	test_df <- data.frame(data.frame(test_subject, test_y, test_x)
	train_df <- data.frame(train_subject, train_y, train_x)
```
Then both was concatenated to create the data frame with all entries with the command to append the test_df to train_df
```R
	full_df <- rbind(train_df, test_df)
```
After this step the temporary objects was removed with the command
```R
	rm(list = c("train_df", "test_df", "train_y", "train_x", "train_subject", "test_y", "test_x", "test_subject", "download_data_file", "data_path", "dataset_url"))
```
## Extracts only the measurements on the mean and standard deviation for each measurement.

First the column numbers was defined by search the features with the regexp `mean\\(\\)|std\\(\\)` against the `features` data frame using the command. The columns ids was saved in the variable `measurement_columns`. The `measurement_names` will be used in the step 4.
```R
measurement_columns<-features[grepl("mean\\(\\)|std\\(\\)", features$name), 1]
measurement_names<-features[measurement_columns, 2] 
```
After take the columns ids based on the pattern shown, now we need to add 2 to all ids. This is necessary because we added to columns on the left in the `full_df` to include the subject and  the activity. The command bellow was used:
```R
measurement_columns<-sapply(measurement_columns, function(x){x+2})
```
Finally we filter the columns from `full_df` and add the first 2 columns
```R
full_df <- full_df[, c(1, 2, measurement_columns)]
```
## Uses descriptive activity names to name the activities in the data set
To get the name of each activity  we will get the ID from `full_df` and use as KEY to recover the name with the command `mutate` as bellow
```R
full_df <- mutate(full_df, V1 = activity_labels$name[V1])
```
## Appropriately labels the data set with descriptive variable names.
Now the names inside the vector `measurement_names` need to be formatted in order the look prettier. To do this we need to do the following steps using `sub` and `gsub`
```R
# First we replace the hifen the dot
measurement_names <- gsub("-", ".", measurement_names)

# Now we remove the parenthesis
measurement_names <- sub("\\(\\)", "", measurement_names)

# replace the f and t for time and frequence
measurement_names <- sub("^t", "Time.", measurement_names)
measurement_names <- sub("^f", "Frequency.", measurement_names)
```
Applying this commands transform the `tBodyAcc-mean()-X` name into `Time.BodyAcc.mean.X`. After format the name we need to apply them as column name to the `full_df` using the `colnames`. Also we will add the columns "Subject" and "Activity" manually.

```R
colnames(full_df) <- c("Subject", "Activity", measurement_names)
```

## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

In order to create a summary, I used a pipeline  to group the data by "Subject" and "Activity" and then create a summary applying mean to each column except the grouped columns and salved the result to the `final_report` variable.
```R
final_report <- full_df %>% group_by(Subject, Activity) %>% summarise_all(mean)
```
Then we save the data frame in a csv called `final_report.csv` inside the `data/` directory.

## PS
The script run_analysis.R will download the dataset and do all the work described here and contains more details about  the solution.
# Load the required libraries
library(dplyr)

# Load my util script with the download helper function
source("util.R")

# Each step has its own logic block
# 
# Downloading the dataset and creating the table objects.
dataset_url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download_data_file(dataset_url, "data/dataset.zip", unzip_data = TRUE,
                   overwrite = TRUE, remove_local_file = TRUE)

#Load the tables
data_path<-"data/UCI HAR Dataset"

## activities label
activity_labels <- read.table(file.path(data_path, "activity_labels.txt"),
                              col.names = c("id", "name"))
features <- read.table(file.path(data_path, "features.txt"),
                       col.names = c("id", "name"))

## test data
test_subject <- read.table(file.path(data_path, "test", "subject_test.txt"),
                           col.names = c("id"))
test_x <- read.table(file.path(data_path, "test", "X_test.txt"))
test_y <- read.table(file.path(data_path, "test", "y_test.txt"))

## train data
train_subject <- read.table(file.path(data_path, "train", "subject_train.txt"),
                            col.names = c("id"))
train_x <- read.table(file.path(data_path, "train", "X_train.txt"))
train_y <- read.table(file.path(data_path, "train", "y_train.txt"))

#STEP 1 - Merges the training and the test sets to create one data set.
# The full dataset will have the structure subject, y, X...

## create a df for train and test
test_df <- data.frame(test_subject, test_y, test_x)
train_df <- data.frame(train_subject, train_y, train_x)

## Now create the full DF
full_df <- rbind(train_df, test_df)

# Now remove from memory the objects that wont be used anymore.
rm(list = c("train_df", "test_df", "train_y", "train_x", "train_subject",
            "test_y", "test_x", "test_subject", "download_data_file",
            "data_path", "dataset_url"))


# STEP 2 - Extracts only the measurements on the mean and standard deviation for each measurement.
# Now we need to discover which columns from the df has the values for the mean and
# std. This is possible using the command grepl as bellow
# The "\\" means to intepret the backlash as literal.
measurement_columns<-features[grepl("mean\\(\\)|std\\(\\)", features$name), 1]
measurement_names<-features[measurement_columns, 2] 

# Now we add 2 to every value in the measurement_columns. This is needed because 
# when we created the full data frame we added two columns on the left.
measurement_columns<-sapply(measurement_columns, function(x){x+2})

# Now we select only the columns we need. Here we pass a vector incluiding
# the first two columns for the subject and y value.
full_df <- full_df[, c(1, 2, measurement_columns)]

#STEP 3 - Uses descriptive activity names to name the activities in the data set
# Now we need to translate the y value ("activity") to the name of the activity
# To do it lets use mutate()
# Here we use the activity ID in the variable V1 from the full data frame
# and use the value to retrieve the name from the activity_lables df
full_df <- mutate(full_df, V1 = activity_labels$name[V1])

# STEP 4 - Appropriately labels the data set with descriptive variable names.
# 

# First we replace the hifen the dot
measurement_names <- gsub("-", ".", measurement_names)

# Now we remove the parenthesis
measurement_names <- sub("\\(\\)", "", measurement_names)

# replace the f and t for time and frequence
measurement_names <- sub("^t", "Time.", measurement_names)
measurement_names <- sub("^f", "Frequency.", measurement_names)

# Now we use the names to set the colnames on the full data frame. We need
# to add manually the name of the first two columns
colnames(full_df) <- c("Subject", "Activity", measurement_names)

# STEP 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# The following pipeline will create the report grouping by Subject, Activity
# and use the summarise_all function to apply the mean. The summarise_all function 
# will apply the mean expectp to the columns used in the group_by
final_report <- full_df %>% group_by(Subject, Activity) %>% summarise_all(mean)

#Saves the tidy data in the file 'final_report.csv'
write.csv2(final_report, "data/final_report.csv", row.names = FALSE)

print("The tidy data file has been saved in 'data/final_report.csv'")

# Shows the report.
View(final_report)
## load ibararies needed
library(dplyr)
library(data.table)
library(tidyr)
## 
##  download and unziped
##
## set Data directory
setwd("C:/Users/Dave/Documents/Rstudio/GettingAndCleaningDataCourseProject")

#datadir<-"data"
if(!file.exists("data")) 
{ 
  dir.create("data")
} 
elseif
{
  unlink("data/*")
}
## download File and Unzip in Dir data
#download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","data/Dataset.zip",mode="wb")  
#unzip("./data/Dataset.zip",overwrite = TRUE, exdir = "data")

## Load up test and training data and set rows and col names
## load data
testset<-read.table("data/UCI HAR Dataset/test/X_test.txt")
trainset<-read.table("data/UCI HAR Dataset/train/X_train.txt")

## load Activity
TestActivity<-read.table("data/UCI HAR Dataset/test/Y_test.txt",col.names = c("activityID"))
TrainActtivity<-read.table("data/UCI HAR Dataset/train/Y_train.txt",col.names = c("activityID"))
AllActivity<- rbind(TestActivity,TrainActtivity)
## load Subjects
testSubjects<-read.table("data/UCI HAR Dataset/test/subject_test.txt",col.names = c("subject"))
trainSubjects<-read.table("data/UCI HAR Dataset/train/subject_train.txt",col.names = c("subject"))
AllSubjects<-rbind(testSubjects,trainSubjects)

## load dcriptions
featuredf<-read.table("data/UCI HAR Dataset/features.txt",col.names = c("index","feature"))
activitydf<-read.table("data/UCI HAR Dataset/activity_labels.txt",col.names = c("activityID","activity"))

## set measure/column names
colnames(testset)<-featuredf$feature
colnames(trainset)<-featuredf$feature


## Step 1 Merges the training and the test sets to create one data set.
masterset<-rbind(testset,trainset)
##
## step 2 Extracts only the measurements on the mean and standard deviation for each measurement.
mcols<-colnames(masterset)
colstokeep<-grep("mean\\(|std\\(",mcols)

tidyset<-subset(masterset,select =mcols[colstokeep])

## Step 3 Uses descriptive activity names to name the activities in the data set

AllActivitym<-merge(AllActivity,activitydf,by = "activityID")
AllActivitya<-subset(AllActivitym,select ="activity")
tidyset<-cbind(AllActivitya,tidyset)

## combine the Subjects
tidyset<-cbind(AllSubjects,tidyset)

## Step 4 Appropriately labels the data set with descriptive variable names.
## remove ()
colnames(tidyset)<-gsub("\\(\\)","",colnames(tidyset))
## Expand names
colnames(tidyset)<-gsub("Acc","acceleration",colnames(tidyset))
colnames(tidyset)<-gsub("Gyro","gyroscope",colnames(tidyset))
colnames(tidyset)<-gsub("Mag","magnitude",colnames(tidyset))
colnames(tidyset)<-gsub("^t","time",colnames(tidyset))
colnames(tidyset)<-gsub("^f","frequency",colnames(tidyset))
colnames(tidyset)<-gsub("BodyBody","body",colnames(tidyset))
## lowercase all 
colnames(tidyset)<-tolower(colnames(tidyset))
# save  features/variables
write(colnames(tidyset),"tidyfeatures.txt")
## Step 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tinytidyset<-aggregate(tidyset[3:68], list(subject = tidyset$subject,activity = tidyset$activity), mean)
write.table(tinytidyset,file = "tidysetsummerized.txt",row.names = FALSE)



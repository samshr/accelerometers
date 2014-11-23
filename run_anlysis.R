#check directory and create one if it does not exists
if(!file.exists("./project")){dir.create("./project")}
if (!file.exists("./project/UCI HAR Dataset")){dir.create("./project/UCI HAR Dataset")}

#Getting data from the Web
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile="./project/UCI_HAR_data.zip"
download.file(fileUrl, destfile=zipfile)
#unzipping file
unzip(zipfile, exdir="project")

#Reading training & test data
library(data.table)
training.x <- read.table("./project/UCI HAR Dataset/train/X_train.txt",header=F)
training.y <- read.table("./project/UCI HAR Dataset/train/y_train.txt",header=F,col.names="V562")
training.subject <- read.table("./project/UCI HAR Dataset/train/subject_train.txt",header=F,col.names="V563")
test.x <- read.table("./project/UCI HAR Dataset/test/X_test.txt",header=F)
test.y <- read.table("./project/UCI HAR Dataset/test/y_test.txt",header=F,col.names="V562")
test.subject <- read.table("./project/UCI HAR Dataset/test/subject_test.txt",header=F,col.names="V563")

#1.Merges the training and the test sets to create one data set.
testData <- cbind(test.x,test.y)
testData <- cbind(testData,test.subject)
trainingData <- cbind(training.x,training.y)
trainingData <- cbind(trainingData,training.subject)
finalData <- rbind(testData,trainingData)

#2.Extracts only the measurements on the mean and standard deviation for each measurement.
features <- read.table("./project/UCI HAR Dataset/features.txt",header=F,colClasses="character")
col.mean <- grep("mean", features[,2])
col.std <- grep("std", features[,2])
col <- c(col.mean,col.std,562,563)
finalData = finalData[,col]

#3.Uses descriptive activity names to name the activities in the data set.
activities <- read.table("./project/UCI HAR Dataset/activity_labels.txt",header=F,colClasses="character")
finalData$V562 <- factor(finalData$V562,levels=activities$V1,labels=activities$V2)

#4.Appropriately labels the data set with descriptive variable names.
features <- features[col,]
colnames(finalData) <- features$V2
colnames(finalData)[80] <- "Activity"
colnames(finalData)[81] <- "Subject"

#5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2)
id = c("Subject", "Activity")
data = setdiff(colnames(finalData), id)

#Melting data
melt_data = melt(finalData, id = id, measure.vars = data)

# Apply dcast function to calculate mean
tidy_data = dcast(melt_data, Subject + Activity ~ variable, mean)
write.table(tidy_data, file = "./project/UCI HAR Dataset/tidy_data.txt",row.names=FALSE)

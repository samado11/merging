packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- "C:\Users\Omar SamadOo0\Desktop\DATA SCIENCE COURSE\data"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "data.zip"))
unzip(zipfile = "data.zip")

activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
m <- features[featuresWanted, featureNames]
m <- gsub('[()]', '', m)

t <- fread(file.path(path, "UCI HAR Dataset/t/X_t.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(t, cols(t), m)
tActivities <- fread(file.path(path, "UCI HAR Dataset/t/Y_t.txt")
                         , col.names = c("Activity"))
tSubjects <- fread(file.path(path, "UCI HAR Dataset/t/subject_t.txt")
                       , col.names = c("SubjectNum"))
t <- cbind(tSubjects, tActivities, t)


test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, cols(test), m)
tests <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, tests, test)

com<- rbind(t, test)

combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

combined [["SubjectNum"]] <- as.factor(combined[, SubjectNum])
com<- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
com<- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)

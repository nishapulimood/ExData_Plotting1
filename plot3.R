## Load required packages for code to run correctly
library(dplyr)

## Read the dataframe with headers, specifying that missing values are denoted by "?" 
## and the separator is ";". The UCI Machine Learning Repository website states that 
## this dataset contains 47 months of measurements from Dec 2006-Nov 2010. Since only dates
## in Feb 2007 are needed for this analysis, you can roughly calculate that only the first  
## 1/10th of the ~2 million rows are needed. Specify nrows to avoid reading the entire dataset.
EPCdata <- read.table("./household_power_consumption.txt", header=TRUE, sep=";", dec=".", 
                      na.strings="?", nrows=100000)

## Convert the Date column to Date class and the Time column to POSIX class.
EPCdata$Date <- as.Date(EPCdata$Date, format="%d/%m/%Y")
EPCdata$Time <- as.POSIXct(EPCdata$Time, format="%H:%M:%S")

## Confirm/convert all other columns to numeric class. The unlist() and as.character() additions
## are needed to convert columns of factor class to numeric.
if(class(EPCdata[,3:9])!="numeric") {
  EPCdata[,3:9] <- as.numeric(as.character(unlist(EPCdata[,3:9])))}

## Subset the data to the specific dates required
EPCsubset <- filter(EPCdata, Date=="2007-02-01" | Date=="2007-02-02")

## There is an incorrect date "2019-08-05" showing up in my Time column. To fix this,  
## find the row where the date changes from 2007-02-01 to 2007-02-02 (time restarts at 00:00:00) 
##  and then manually correct the dates (by row number) in the Time column. 
which(EPCsubset$Time==" 2019-08-05 00:00:00")
EPCsubset[1:1440,"Time"] <- gsub("2019-08-05", "2007-02-01", EPCsubset[1:1440,"Time"])
EPCsubset[1441:2880,"Time"] <- gsub("2019-08-05", "2007-02-02", EPCsubset[1441:2880,"Time"])

## Generate plot3 with 3 lines() graphs overlaid and legend, and save as PNG file
par(mfcol=c(1,1))
with(EPCsubset, plot(Time, Sub_metering_1, 
                     type="n", ylab="Energy sub metering", xlab=""))
with(EPCsubset, lines(Time, Sub_metering_1))
with(EPCsubset, lines(Time, Sub_metering_2, col="red"))
with(EPCsubset, lines(Time, Sub_metering_3, col="blue"))
with(EPCsubset, legend("topright",legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),
                       lty=1, col=c("black", "red", "blue")))
dev.copy(png, file="plot3.png", width=480, height=480)
dev.off()

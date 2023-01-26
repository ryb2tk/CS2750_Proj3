#!/bin/bash
# Name: Renee Brandt
# Purpose: Implement a menu with options 1-6


#Capture SIGINT sent by user and output an appropriate message before terminating
function userExit()
{
echo " User decided to leave with Ctrl+C. Bye!"
exit
}
trap userExit SIGINT

#Create logerr.txt so that errors appended are only from the single session run.
touch logerr.txt
logerr=$(find ~ -name "logerr.txt")

echo -e  "\nWelcome to the directory menu!\n"
echo "Take a look at the options below and make a choice by typing a number on the left."
echo -e "Note that you can only make ONE choice at a time.\n"

# Create menu
PS3="Select a choice: "
cal=("List directory files" "Count empty files in a given directory" "Switch to another directory and list files" "Count the number of files that contain a given word/pattern" "Provide a directory name and move given file names there" "Exit program")
select i in "${cal[@]}"
do
   case $i in
# 1 List directory files
   "List directory files")
      echo "Listing files in this directory..."
      fileCount=$(find . -maxdepth 1 -type f | wc -l)
      if [[ $fileCount -eq 0 ]]
      then
         echo "This is an empty directory!"
      else
         find . -maxdepth 1 -type f | sed 's/\.\///'
      fi
      ;;
# 2 Count empty files in a given directory
   "Count empty files in a given directory")
      echo -e "You want to count how many empty files are in a given directory.\nType the directory name:"
      read directoryName
      directoryLocation=$(find ~ -name $directoryName)
      while [[ ! -d $directoryLocation ]]
      do
         echo "No directory with name $directoryName was found. Please try again."
         read directoryName
         directoryLocation=$(find ~ -name $directoryName)
      done
      echo "Found the directory $directoryName! Counting empty files..."
      emptyFileCount=$(find $directoryLocation -empty -type f | wc -l)
      if [[ $emptyFileCount -eq 0 ]]
      then
        echo "There are 0 empty files in the directory $directoryName!"
      else
         echo "Directory $directoryName contains $emptyFileCount empty file(s)."
      fi
      ;;
# 3 Switch to another directory and ls -l files
  "Switch to another directory and list files")
      echo "It looks like you want to see what files exist elsewhere."
      echo "Provide the name of the other directory."
      read directoryName
      directoryLocation=$(find ~ -name $directoryName)      
      while [[ ! -d  "$directoryLocation" ]]
      do
         noDirectoryError="ERROR IN OPTION 3: No directory with the name $directoryName exists. Please try again."
         echo $noDirectoryError
         echo $noDirectoryError >> $logerr
         read directoryName
         directoryLocation=$(find ~ -name $directoryName)     
      done
      cd $directoryLocation
      ls -l
      ;;
# 4 Find files containing a given word/pattern
   "Count the number of files that contain a given word/pattern")
      echo "You'd like to know how many files in our current working directory have a given word."
      echo "What word/pattern are you looking for?"
      read wordPattern
      fileCount=$(find . -type f -exec grep -l "$wordPattern" {} \; | wc -l)
      if [[ $fileCount -eq 0 ]]
      then
         noPatternMatch="ERROR IN OPTION 4: No files in $(pwd) contain the word $wordPattern."
         echo $noPatternMatch
         echo $noPatternMatch >> $logerr
      else
         echo "There are $fileCount files in this directory that contain the word $wordPattern."
      fi 
      ;;
# 5 Provide a directory name and a series of filenames to move there
   "Provide a directory name and move given file names there")
      echo "You want to move files to a new directory."
      echo "Provide the name of the directory you want files to be moved to"
      read directoryName
      newFileLocation=$(find ~ -name $directoryName)
      while [[ ! -d "$newFileLocation" ]]
      do
         noDirectoryError="ERROR IN OPTION 5: No directory with the name $directoryName exists. Please try again."
         echo $noDirectoryError
         echo $noDirectoryError >> $logerr
         read directoryName
         newFileLocation=$(find ~ -name $directoryName)
      done
      echo "Great! I have a directory to move to."
      echo "Now give me the names of all the files you would like to move. Separate the name of each file with a space."
      read -a fileArray
      echo "Moving existing files to $directoryName"
      for value in "${fileArray[@]}"
      do
         fileLocation=$(find ~ -type f -name "$value")
         if [[ -f $fileLocation ]]
         then
            mv $fileLocation $newFileLocation 
         else
            fileError="ERROR IN OPTION 5: The file $value does not exist. Thus, it was not moved to $directoryName."
            echo $fileError
            echo $fileError >> $logerr
         fi
      echo "If the files existed, they have been moved!"
      done  
      ;;
# 6 Exit program
   "Exit program")
      echo "Quitting the program. Bye!"
      break
      ;;
   *)
   if [[ $REPLY =~ [|] ]]
      then
         pipeAttempt="ERROR: User tried to pipe multiple choices. Terminating program."
         echo $pipeAttempt
         echo $pipeAttempt >> $logerr
         exit
      else
         invalidOption="ERROR: Invalid option $REPLY. Please try again."
         echo $invalidOption
         echo $invalidOption >> $logerr
      fi
      ;;
   esac
done 


package main

import (
	"log"
	"os"
)

// Global Variables
var (
	// Path to the local rtl adsb log file directory
	localRTLADSBLogPath = "/etc/rtl_adsb"
	// Path to the local rtl adsb log file.
	localRTLADSBLogFilePath = localRTLADSBLogPath + "/rtl_adsb.log"
)

func init() {
	// Check if the local rtl adsb log file directory exists
	if directoryExists(localRTLADSBLogPath) == false {
		// If it doesn't exist, create the directory
		createDirectory(localRTLADSBLogPath, 0755)
	}
	// Check if the local rtl adsb log file exists
	if fileExists(localRTLADSBLogFilePath) == false {
		// If it doesn't exist, create the file
		createFile(localRTLADSBLogFilePath)
	}
}

func main() {
	//
}

/*
It checks if the file exists
If the file exists, it returns true
If the file does not exist, it returns false
*/
func fileExists(filename string) bool {
	info, err := os.Stat(filename)
	if err != nil {
		return false
	}
	return !info.IsDir()
}

/*
Checks if the directory exists
If it exists, return true.
If it doesn't, return false.
*/
func directoryExists(path string) bool {
	directory, err := os.Stat(path)
	if err != nil {
		return false
	}
	return directory.IsDir()
}

/*
The function takes two parameters: path and permission.
We use os.Mkdir() to create the directory.
If there is an error, we use log.Fatalln() to log the error and then exit the program.
*/
func createDirectory(path string, permission os.FileMode) {
	err := os.Mkdir(path, permission)
	if err != nil {
		log.Fatalln(err)
	}
}

/*
The function takes a filename as a parameter.
We use os.Create() to create the file.
If there is an error, we use log.Fatalln() to log the error and then exit the program.
*/
func createFile(filename string) {
	// Create the file with read-write permissions for the owner
	file, err := os.Create(filename)
	if err != nil {
		log.Fatalln(err)
	}
	defer file.Close() // Ensure the file is closed after creation
}

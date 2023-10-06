#!/bin/bash
###     Assumption: pipeline scan executing from current directory.   ###
###     Enter optional parameters 1 at a time and press enter after each one. Pressing enter on an empty string breaks the while loop.   ###
###		"-esd true" or "--emit_stack_dump true" required for Veracode Fix   ###
set -e
#Font Color Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

#Updates Pipeline-scan.jar
function getPipeline
{
	echo -e "${CYAN}Downloading Veracode Pipeline Scanner...${NC}"
	curl -O https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip
	echo -e "${CYAN}Unzipping zip file............................${NC}"
	unzip -u pipeline-scan-Latest.zip pipeline-scan.jar
	echo -e "${CYAN}Removing zip file.............................${NC}"
	rm pipeline-scan-Latest.zip
	echo -e "${GREEN}Pipeline Scan is ready!${NC}"
}

#Asks user to provide a path to the binary.
function getPath
{
	#Path should include file path, binary name and extension.
	echo -e "${CYAN}Enter binary path and name: ${NC}"
	read binPath

	#Calls validation function
	valPath $binPath
}

#Validation function to ensure file is available and if not, redirect back to get a new path.
function valPath
{
	filePath=$@
	echo -e "${CYAN}Entered path to file = ${NC}"$filePath
	if [ -f "$filePath" ];
	then
		echo -e "${GREEN}Success! File found!${NC}"
	else
		echo -e "${RED}File not found, please enter path and filename again!${NC}"
		getPath
	fi
}

#Gets optional additional parameters to pass to pipeline scanner.
function getFlags
{
	echo -e "${CYAN}Enter additional parameters (ex. --fail_on_severity=\"Very High, High\"):${NC}"
	while IFS= read -r -d $'\n' input
	do
		if [[ -z "$input" ]]; then
			break
		else
			optFlags=("${optFlags[@]}" "${input}")
		fi
	done
	echo -e "${CYAN}Parameters: ${NC}""${optFlags[@]}${NC}"
	yes_or_no "Accept?" || getFlags
}

#Calls the pipeline scanner with provided flags and paths. Requires Pipeline-scan.jar to be present in current directory.
function callPipeline
{
	echo -e "${CYAN}Beginning pipeline scan.......................${NC}"
	if [[ -z "${optFlags[@]}" ]];
	then
		java -jar ./pipeline-scan.jar --file "$filePath"
		return 0
	else
		echo java -jar ./pipeline-scan.jar --file "\"${filePath}\"" "${optFlags[@]}" |sh -s
		return 0
	fi
}

#Yes or No function to handle yes or no inputs from user.
function yes_or_no
{
	while true; do
		read -p $'\033[0;45m'"$* [y/n]: "$'\033[0m' yn
		#read -p "${CYAN}""${*} [y/n]: " yn
		case $yn in
			[Yy]*) echo "Yes"; return 0 ;;
			[Nn]*) echo "No" ; return 1 ;;
		esac
	done
}

#Check if Pipeline Scan is installed, if not, install it.
if [ ! -f ./pipeline-scan.jar ]; then
	getPipeline
fi
#Ask user if pipeline-scan.jar needs to be updated and installs latest if needed.
yes_or_no "Update Pipeline Scan to Latest?" && getPipeline

#Ask user to provide path to the binary. Must include binary name and file extension.
getPath

#Ask user if optional parameters are needed.
yes_or_no "Do you wish to enter additional parameters?" && getFlags

#Calling the pipeline scan with provided parameters.
callPipeline

echo -e "${GREEN}Completed Pipeline Scan${NC}"

	

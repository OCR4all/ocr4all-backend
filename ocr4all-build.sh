#!/bin/bash
#
# Builds ocr4all application
#
# Exit status:
#              0 Success
#              1 Aborted
#              2 Performed with some fails
#
# Date: Di 30. Apr 15:24:44 CEST 2024
# Author: Herbert Baier (herbert.baier@uni-wuerzburg.de)
#

#
# Defines contants
#
CURRENT_DIR="`pwd`"

MAVEN="mvn"

#
# Define variables
#
EXIT_STATUS=0

#
# Font
#
RESET='\033[0m'

BOLD='\033[1m'

# ANSI escape codes for the colored output
RED='\033[0;31m'
YELLOW='\033[0;33m'

#
# Writes a log entry.
#
# parameter:
#            $1 The log entry
#
function logEntry()
{
	echo "`/bin/date '+%Y-%m-%d %T'`: $1"
}

#
# Writes a error log entry and aborts the script, this means, exists with status 1.
#
# parameter:
#            $1 The log entry
#
function logError()
{
	echo -e "${RED}`/bin/date '+%Y-%m-%d %T'` (${BOLD}ERROR${RESET}${RED}): $1${RESET}"
	cd $CURRENT_DIR
	
	exit 1
}

#
# Writes a warning log entry and add it to the warning message. The exit status is set to 2.
#
# parameter:
#            $1 The log entry
#
WARN_MESSAGES=""
WARN_INDEX=0

function logWarn()
{
	echo -e "${YELLOW}`/bin/date '+%Y-%m-%d %T'` (${BOLD}WARN${RESET}${YELLOW}): $1${RESET}"
	
	if [ ! -z "${WARN_MESSAGES}" ]
	then
		WARN_MESSAGES="$WARN_MESSAGES\n"
	fi
	
	WARN_MESSAGES="$WARN_MESSAGES\t$((++WARN_INDEX)). $1"
	
	EXIT_STATUS=2
}

#
# Test if maven command is available
#
if ! command -v $MAVEN &> /dev/null
then
    logError "the Maven command '$MAVEN' could not be found!"
fi

#
# Execute script in the directory where the script is located
#
cd "$(dirname "$0")"

if [ $? -ne 0 ]
then
	logError "can not change to home directory '$HOME_DIR'!"
else
	HOME_DIR="`pwd`"
fi

#
# Echo a new line, if not first action
#
IS_FIRST_ACTION=true

function echoNewLineAction()
{
	if [ "$IS_FIRST_ACTION" = true ]
	then
		IS_FIRST_ACTION=false
	else
		echo
	fi
}

#
#
# Install the artifact.
#
# parameter:
#            $1 The artifact
#
function install_artifact()
{
	echoNewLineAction
	
    cd "$HOME_DIR/$1"
    if [ $? -ne 0 ]
    then
		logWarn "can not install the artifact '$1' (unknown directory $HOME_DIR/$1)."
    else
    	logEntry "install the artifact '$1'."
    	
		$MAVEN clean install
		if [ $? -ne 0 ]
		then
	    	logWarn "can not install the artifact '$1' (maven trouble)."
		else 
	    	logEntry "installed the artifact '$1'."
		fi
    fi
}

#
#
# Packages the application.
#
# parameter:
#            $1 The application
#
function package_application()
{
 	echoNewLineAction
	
    cd "$HOME_DIR/$1"
    if [ $? -ne 0 ]
    then
		logWarn "can not package the application '$1' (unknown directory $HOME_DIR/$1)."
    else
    	logEntry "package the application '$1'."
    	
		$MAVEN clean package
		if [ $? -ne 0 ]
		then
	    	logWarn "can not package the application '$1' (maven trouble)."
		else 
	    	logEntry "packaged the application '$1'."
		fi
    fi
}

#
# Install ocr4all artifacts.
#
function install_ocr4all()
{
	install_artifact "ocr4all-app-communication"
	install_artifact "ocr4all-app-spi"
	install_artifact "ocr4all-app-persistence"
	install_artifact "ocr4all-app-calamari-communication"
	install_artifact "ocr4all-app-calamari-spi"
	install_artifact "ocr4all-app-ocrd-communication"
	install_artifact "ocr4all-app-ocrd-spi"
}

#
# Install calamari artifacts.
#
function install_calamari()
{
	install_artifact "ocr4all-app-communication"
	install_artifact "ocr4all-app-spi"
	install_artifact "ocr4all-app-msa"
	install_artifact "ocr4all-app-calamari-communication"
}

#
# Install ocrd artifacts.
#
function install_ocrd()
{
	install_artifact "ocr4all-app-communication"
	install_artifact "ocr4all-app-spi"
	install_artifact "ocr4all-app-msa"
	install_artifact "ocr4all-app-ocrd-communication"
}

#
# Install all artifacts.
#
function install_all()
{
	install_ocr4all

	install_artifact "ocr4all-app-msa"
}

#
# Package ocr4all application.
#
function package_ocr4all()
{
    package_application "ocr4all-app"
}

#
# Package calamari applications.
#
function package_calamari()
{
     package_application "ocr4all-app-calamari-msa"
}

#
# Package ocrd applications.
#
function package_ocrd()
{
     package_application "ocr4all-app-ocrd-msa"
}

#
# Package all applications.
#
function package_all()
{
    package_ocr4all
    package_calamari
    package_ocrd
}

#
# Prints the help message.
#
function print_help()
{
	cat >&2 <<-EOF 
	Usage: $0 <command>

	where <command> is one of:
	   install          - installs all artifacts
	   package          - packages all applications
	   build            - builds the complete application, i.e. installs all artifacts and packages all applications

	   install-ocr4all  - installs the ocr4all artifacts
	   package-ocr4all  - packages the ocr4all application
	   build-ocr4all    - builds the ocr4all application, i.e. installs the ocr4all artifacts and packages the ocr4all application

	   install-calamari - installs the calamari artifacts
	   package-calamari - packages the calamari application
	   build-calamari   - builds the calamari application, i.e. installs the calamari artifacts and packages the calamari application

	   install-ocrd     - installs the ocrd artifacts
	   package-ocrd     - packages the ocrd application
	   build-ocrd       - builds the ocrd application, i.e. installs the ocrd artifacts and packages the ocrd application

	   help             - this screen
	EOF
}

#
# Initializes build. Default action is help.
#
if [ -n "$1" ]
then 
    action="$1"
else	
    action="help"
fi

#
# The main part 
#
SECONDS=0
case "$action" in
    install)
		install_all
		;;
		
    package)
		package_all
		;;
		
    build)
		install_all
		package_all
		;;
								
    install-ocr4all)
		install_ocr4all
		;;
		
    package-ocr4all)
		package_ocr4all
		;;
		
    build-ocr4all)
		install_ocr4all
		package_ocr4all
		;;
								
    install-calamari)
		install_calamari
		;;
		
    package-calamari)
		package_calamari
		;;
		
    build-calamari)
		install_calamari
		package_calamari
		;;
								
     install-ocrd)
		install_ocrd
		;;
		
    package-ocrd)
		package_ocrd
		;;
		
    build-ocrd)
		install_ocrd
		package_ocrd
		;;
								
    help)
		print_help
	
		cd $CURRENT_DIR
		exit 0
		;;
						
    *)
		echo -e "${RED}${BOLD}Unknown command '$action'!${RESET}${RED}"
	
		print_help
	
		echo -n -e "${RESET}"
		
		cd $CURRENT_DIR
		exit 1
		;;
esac
DURATION=$SECONDS

#
# Ends the application
#

if [ "$EXIT_STATUS" -eq "0" ]
then
	logEntry "action '$action' ends successfully."
else
	echo -e "${YELLOW}`/bin/date '+%Y-%m-%d %T'` (${BOLD}WARN${RESET}${YELLOW}): action '$action' ends with following warnings:\n$WARN_MESSAGES${RESET}"
fi

echo "Running time: $((DURATION / 60)) minutes and $((DURATION % 60)) seconds."

cd $CURRENT_DIR
exit $EXIT_STATUS

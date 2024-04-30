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

if ! command -v $MAVEN &> /dev/null
then
    echo "The Maven command $MAVEN could not be found"
    exit 1
fi


EXIT_STATUS=0

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
#
# Install the artifact.
#
# parameter:
#            $1 The artifact
#
function install_artifact()
{
    cd $1
    if [ $? -ne 0 ]
    then
		logEntry "FAIL - can not install the artifact $1 (unknown directory)."
		
		EXIT_STATUS=2
    else
    	logEntry "Install artifact: $1"
    	
		$MAVEN clean install
		if [ $? -ne 0 ]
		then
	    	logEntry "FAIL - can not install the artifact $1."
	    	
	    	EXIT_STATUS=2
		else 
	    	logEntry "Artifact $1: installed."
	    	echo
		fi
     
    	cd $CURRENT_DIR
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
    cd $1
    if [ $? -ne 0 ]
    then
		logEntry "FAIL - can not package the application $1 (unknown directory)."
		
		EXIT_STATUS=2
    else
    	logEntry "Package application: $1"
    	
		$MAVEN clean package
		if [ $? -ne 0 ]
		then
	    	logEntry "FAIL - can not package the application $1."
	    	
	    	EXIT_STATUS=2
		else 
	    	logEntry "Application $1: packaged."
	    	echo
		fi
     
    	cd $CURRENT_DIR
    fi
}

#
# Install the artifacts.
#
function install()
{
    install_artifact "ocr4all-app-communication"
    install_artifact "ocr4all-app-spi"
    install_artifact "ocr4all-app-persistence"
    install_artifact "ocr4all-app-msa"
    install_artifact "ocr4all-app-ocrd-communication"
    install_artifact "ocr4all-app-ocrd-spi"
}

#
# Package the applications.
#
function package()
{
    package_application "ocr4all-app"
    package_application "ocr4all-app-ocrd-msa"
}

#
# The main part 
#
case "$action" in
    install)
		install
		;;
		
     package)
		package
		;;
		
    build)
		install
		package
		;;
						
    *)
	cat >&2 <<-EOF 
	Usage: $0 <command>

	where <command> is one of:
	   install - installs the artifacts
	   package - packages the applications
	        
	   build   - builds ocr4all, i.e. installs the artifacts and packages the applications

	   help    - this screen
	EOF
	exit 0
	;;
esac

#
# End
#

if [ "$EXIT_STATUS" -eq "0" ]
then
	logEntry "Build ends successfully."
else
	logEntry "Build ends with errors."
fi


exit $EXIT_STATUS

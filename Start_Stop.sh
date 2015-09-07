#!/bin/bash
# This script is licenced under GPLv2 ; you can get your copy from http://www.gnu.org/licenses/gpl-2.0.html
# Utility tool to Startup and Shutdown EBS
# Edit <INSTALLATION_DIR> , <SID> , <HOSTNAME> before running script.
# Store menu options selected by the user
INPUT=/tmp/menu.sh.$$
 
# Storage file for displaying cal and date command output
OUTPUT=/tmp/output.sh.$$
  
# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM
 
#
# Purpose - display output using msgbox 
#  $1 -> set msgbox height
#  $2 -> set msgbox width
#  $3 -> set msgbox title
#
function display_output(){
	local h=${1-10}			# box height default 10
	local w=${2-41} 		# box width default 41
	local t=${3-Output} 	# box title 
	dialog --backtitle "Startup/Shutdown script for EBS" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}
#
# Purpose - Startup EBS
#
function startup(){
str(){
#db:
cd <INSTALLATION_DIR>/oracle/<SID>/db/tech_st/11.1.0
. <SID>_<HOSTNAME>.env
cd <INSTALLATION_DIR>/oracle/<SID>/db/tech_st/11.1.0/appsutil/scripts/<SID>_<HOSTNAME>
./addlnctl.sh start <SID>
./addbctl.sh start

#apps:
cd <INSTALLATION_DIR>/oracle/<SID>/apps/apps_st/appl
. APPS<SID>_<HOSTNAME>.env
cd <INSTALLATION_DIR>/oracle/<SID>/inst/apps/<SID>_<HOSTNAME>/admin/scripts
./adstrtal.sh apps/apps
}

str >$OUTPUT
display_output 20 65 "Startup EBS (Press UP/DOWN Arrow key to Scroll)"
}
#
# Purpose - Shutdown EBS
#
function shutdown(){
stp(){
#apps:
cd <INSTALLATION_DIR>/oracle/<SID>/apps/apps_st/appl
. APPS<SID>_<HOSTNAME>.env
cd <INSTALLATION_DIR>/oracle/<SID>/inst/apps/<SID>_<HOSTNAME>/admin/scripts
./adstpall.sh apps/apps

#db:
cd <INSTALLATION_DIR>/oracle/<SID>/db/tech_st/11.1.0
. <SID>_<HOSTNAME>.env
cd <INSTALLATION_DIR>/oracle/<SID>/db/tech_st/11.1.0/appsutil/scripts/<SID>_<HOSTNAME>
./addlnctl.sh stop <SID>
./addbctl.sh stop
}

stp >$OUTPUT
display_output 20 65 "Shutdown EBS (Press UP/DOWN Arrow key to Scroll)"
}
#
# set infinite loop
#
while true
do
 
### display main menu ###
dialog --clear  --help-button --backtitle "Startup/Shutdown script for EBS" \
--title "[ M A I N - M E N U ]" \
--menu "This program is distributed in the hope that it will be useful, \n\
but WITHOUT ANY WARRANTY; without even the implied warranty of \n\
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
GNU General Public License for more details." 15 68 4	 \
Startup "Startup of Apps as well as DB node." \
Shutdown "Shutdown of Apps as well as DB node." \
Exit "Exit to the shell" 2>"${INPUT}"
 
menuitem=$(<"${INPUT}")
 
 
# make decsion 
case $menuitem in
	Startup) startup;;
	Shutdown) shutdown;;
		Exit) echo "Bye"; break;;
esac
 
done
 
# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT

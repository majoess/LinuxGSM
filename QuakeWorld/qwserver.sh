#!/bin/bash
# Quake World (nQuake)
# Server Management Script
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
if [ -f ".dev-debug" ]; then
	exec 5>dev-debug.log
	BASH_XTRACEFD="5"
	set -x
fi

version="210516"

#### Variables ####

# Notification Alerts
# (on|off)

# Email
emailalert="off"
email="email@example.com"

# Pushbullet
# https://www.pushbullet.com/#settings
pushbulletalert="off"
pushbullettoken="accesstoken"

# Start Variables
ip="0.0.0.0"
port="27500"

fn_parms(){
parms="-port ${port} -game ktx +exec ${servercfg}"
}

#### Advanced Variables ####

# Github Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="GameServerManagers"
githubrepo="LinuxGSM"
githubbranch="master"

# Server Details
servicename="quakeworld-server"
gamename="QuakeWorld"
engine="quake"

# Directories
rootdir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
lockselfname=".${servicename}.lock"
lgsmdir="${rootdir}/lgsm"
functionsdir="${lgsmdir}/functions"
libdir="${lgsmdir}/lib"
filesdir="${rootdir}/serverfiles"
systemdir="${filesdir}/ktx"
executabledir="${filesdir}"
executable="./mvdsv"
servercfg="${servicename}.cfg"
servercfgdir="${systemdir}"
servercfgfullpath="${servercfgdir}/${servercfg}"
servercfgdefault="${servercfgdir}/lgsm-default.cfg"
backupdir="${rootdir}/backups"

# Logging
logdays="7"
gamelogdir="${filesdir}/Logs"
scriptlogdir="${rootdir}/log/script"
consolelogdir="${rootdir}/log/console"
consolelogging="on"

scriptlog="${scriptlogdir}/${servicename}-script.log"
consolelog="${consolelogdir}/${servicename}-console.log"
emaillog="${scriptlogdir}/${servicename}-email.log"

scriptlogdate="${scriptlogdir}/${servicename}-script-$(date '+%d-%m-%Y-%H-%M-%S').log"
consolelogdate="${consolelogdir}/${servicename}-console-$(date '+%d-%m-%Y-%H-%M-%S').log"

##### Script #####
# Do not edit

# Fetches core_dl for file downloads
fn_fetch_core_dl(){
github_file_url_dir="lgsm/functions"
github_file_url_name="${functionfile}"
filedir="${functionsdir}"
filename="${github_file_url_name}"
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
# If the file is missing, then download
if [ ! -f "${filedir}/${filename}" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir -p "${filedir}"
	fi
	echo -e "    fetching ${filename}...\c"
	# Check curl exists and use available path
	curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
	for curlcmd in ${curlpaths}
	do
		if [ -x "${curlcmd}" ]; then
			break
		fi
	done
	# If curl exists download file
	if [ "$(basename ${curlcmd})" == "curl" ]; then
		curlfetch=$(${curlcmd} -s --fail -o "${filedir}/${filename}" "${githuburl}" 2>&1)
		if [ $? -ne 0 ]; then
			echo -e "\e[0;31mFAIL\e[0m\n"
			echo "${curlfetch}"
			echo -e "${githuburl}\n"
			exit 1
		else
			echo -e "\e[0;32mOK\e[0m"
		fi
	else
		echo -e "\e[0;31mFAIL\e[0m\n"
		echo "Curl is not installed!"
		echo -e ""
		exit 1
	fi
	chmod +x "${filedir}/${filename}"
fi
source "${filedir}/${filename}"
}

core_dl.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_functions.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_dl.sh
core_functions.sh

getopt=$1
core_getopt.sh
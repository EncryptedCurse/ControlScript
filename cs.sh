#!/bin/bash

shopt -s nocasematch
#set -x

# -- LICENSE.

#	Copyright (c) 2014 EncryptedCurse
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU Affero General Public License as
#	published by the Free Software Foundation, either version 3 of the
#	License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#	GNU Affero General Public License for more details.
#
#	You may obtain a copy of the GNU Affero General Public License at:
#		   https://www.gnu.org/licenses/agpl.html

# -- CONFIGURATION.

# The initial amount of RAM that the JVM starts with.
XMS="768M"
# The maximum amount of RAM that the JVM can allocate to itself.
XMX="1536M"
# Something something, something. Recommended to keep as is.
PERMSIZE="128M"
# The name of the server JAR.
JAR="spigot.jar"
# The main directory of the server. Do not include a trailing slash at the very end.
SERVER_DIR="/home/server"
# The name of the tmux session to use.
TMUX_NAME="minecraft"

# -- COMMANDS.

# Starts the server. If it's already running, it will instead prompt the user to restart.
start() {
	if [[ -n $(pgrep jav[a]) ]]; then
		echo -e "\e[1;31mThe server is still running!\e[0m\n\e[91mWould you like to restart or stop it instead?\e[0m"
		read RESULT
		if [[ "$RESULT" = "stop" ]]; then
			echo -e "\e[90mStopping server...\e[0m"; sleep 5
			tmux send-keys -t "$TMUX_NAME":0 C-l 'stop' Enter
		elif [[ "$RESULT" = "restart" ]]; then
			echo -e "\e[90mStopping server...\e[0m"; sleep 5
			tmux send-keys -t "$TMUX_NAME":0 C-l 'stop' Enter
			sleep 5
			echo -e "\e[90mStarting server...\e[0m"; sleep 5
			cd /; cd "$SERVER_DIR"
			tmux new -s "$TMUX_NAME" "java -Xms"$XMS" -Xmx"$XMX" -XX:MaxPermSize="$PERMSIZE" -jar "$JAR""
		else
			echo -e "\e[93mOperation cancelled.\e[0m"
		fi
	else
		echo -e "\e[92mStarting server...\e[0m"
		cd /; cd "$SERVER_DIR"
		sleep 5
		tmux new -s "$TMUX_NAME" "java -Xms"$XMS" -Xmx"$XMX" -XX:MaxPermSize="$PERMSIZE" -jar "$JAR""
	fi
}

# Stops the server.
stop() {
	echo -e "\e[90mStopping server...\e[0m"; sleep 5
	tmux send-keys -t "$TMUX_NAME":0 C-l 'stop' Enter
	echo -e "\e[92mServer stopped.\e[0m"
}

# Forcefully kills the server process.
kill() {
	if [[ -n $(pgrep jav[a]) ]]; then
		echo -e "\e[mAre you sure you want to forcefully terminate the server?\e[0m"
		read RESULT
		if [[ "$RESULT" = "y" || "$RESULT" = "yes" ]]; then
			echo -e "\e[90mKilling process...\e[0m"; sleep 5
			echo -e "\e[mDone.\e[0m"
			killall -9 java
		else
			echo -e "\e[93mOperation cancelled.\e[0m"
		fi
	else
		echo "The server is not running."
	fi
}

# Restarts the server.
restart() {
	echo -e "\e[92mThe server is going for a restart."; sleep 1
	echo -e "\e[90mStopping server...\e[0m"; sleep 5
	tmux send-keys -t "$TMUX_NAME":0 C-l 'stop' Enter
	sleep 5
	echo -e "\e[90mStarting server...\e[0m"; sleep 5
	cd /; cd "$SERVER_DIR"
	tmux new -s "$TMUX_NAME" "java -Xms"$XMS" -Xmx"$XMX" -XX:MaxPermSize="$PERMSIZE" -jar "$JAR""
}

# Resumes/attaches the server's tmux session.
# An alias for 'tmux attach'.
resume() {
	if tmux has-session -t "$TMUX_NAME" &> /dev/null; then
		tmux attach -t "$TMUX_NAME"
	else
		echo -e "\e[91mNo server session exists.\e[0m"
	fi
}

# Checks for the current server version.
SERVER_SOFTWARE="$(java -jar $SERVER_DIR/$JAR --version 2> /dev/null | awk 'BEGIN{FS=OFS="-"}{print $2}')"
CURRENT_VERSION="$(java -jar $SERVER_DIR/$JAR --version 2> /dev/null | sed 's/[^0-9]//g')"

current_version() {
	echo -e "\e[38;5;48mThis server is currently running $SERVER_SOFTWARE #$CURRENT_VERSION.\e[0m"
}

# Checks for the latest build of Spigot, and compares it to the current one.
LATEST_VERSION="$(curl -s http://ci.md-5.net/job/Spigot/lastBuild/buildNumber)"

latest_version() {
	if [[ "$LATEST_VERSION" = "$CURRENT_VERSION" ]]; then
		echo -e "\e[38;5;48mThe latest version of Spigot is #$LATEST_VERSION. \e[90mYour server is already up to date.\e[0m"
	else
		echo -e "\e[38;5;48mThe latest version of Spigot is #$LATEST_VERSION. \e[90mYour server is outdated!\e[0m"
	fi
}

# Attempts to update Spigot if a new build is found.
update() {
	NEW_JAR="$SERVER_DIR/spigot.jar.new"
	FINAL_JAR="$SERVER_DIR/spigot.jar"
	UPDATE_URL="http://ci.md-5.net/job/Spigot/lastSuccessfulBuild/artifact/Spigot-Server/target/spigot.jar"

    if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
        echo "Server outdated"
        echo -e "\e[90mDownloading new version (#"$LATEST_VERSION")...\e[0m"
        wget "$UPDATE_URL" -O "$NEW_JAR"
        IS_VALID_JAR="$(java -jar "$NEW_JAR" --version)"
        ATTEMPTS=0
        until [[ "$IS_VALID_JAR" || "$ATTEMPTS" -gt "5" ]]; do
			rm -f "$NEW_JAR"
            echo -e "\e[91mThe downloaded JAR is corrupt! Attempti\e[0m"
            echo -e "\e[90mDownloading new JAR...\e[0m"
            wget "$UPDATE_URL" -O "$NEW_JAR"
            IS_VALID_JAR="`java -jar $NEW_JAR --version`"
            ATTEMPTS="$((ATTEMPTS + 1))"
        done
        if [[ "$IS_VALID_JAR" ]]; then
            echo "Download successful."
            echo "Deploying..."
            if [[ -a "$FINAL_JAR" ]]; then
                rm -f "$FINAL_JAR"
            fi
            mv -f "$NEW_JAR" "$FINAL_JAR"
        else
            echo -e "\e[1;31mUpdate failed! \e[91mDownloaded 5 corrupt JARs.\e[0m"
            rm -f "$NEW_JAR"
        fi
	else
		echo "Server up to date"
	fi
}

send() {
    if ! tmux has-session -t "${TMUX_NAME}" &> /dev/null; then
        echo -e "\e[91mNo server session exists.\e[0m"
        return
    fi
    echo -e "\e[92mExecuting command: \e[0m$@"
    local -i NUM=0
    while [[ "$NUM" -lt 50 ]]; do
        NUM="$((NUM + 1))"
        tmux send-keys -t "${TMUX_NAME}" "BSpace"
    done
    tmux send-keys -l -t "${TMUX_NAME}" "$*" 2> /dev/null \
    || tmux send-keys -t "${TMUX_NAME}" "$* "
    tmux send-keys -t "${TMUX_NAME}" "Enter"
}

cmd_help() {
	echo
	echo -e "\e[38;5;69m —————————————————————\e[0m \e[38;5;81mControlScript // help\e[0m \e[38;5;69m—————————————————————\e[0m"
	echo -e "\e[97m  start\e[37m            Starts the server\e[0m"
	echo -e "\e[97m  stop\e[37m             Stops the server\e[0m"
	echo -e "\e[97m  kill\e[37m             Forcefully terminates the server process\e[0m"
	echo -e "\e[97m  restart\e[37m          Restarts the server\e[0m"
	echo -e "\e[97m  update\e[37m           Updates Spigot if new version is found\e[0m"
	echo -e "\e[97m  current-version\e[37m  Displays your server's current Spigot version\e[0m"
	echo -e "\e[97m  latest-version\e[37m   Displays the latest Spigot version\e[0m"
	echo -e "\e[97m  send\e[37m             Passes a command to the server"
	echo -e "\e[97m  resume\e[37m           Resumes the server tmux session"
	echo
}

main() {
	local -r FUNCTION="$1"
	case "$FUNCTION" in
		start)
			start ;;
		stop)
			stop ;;
		resume)
			resume ;;
		restart)
			restart ;;
		kill)
			kill ;;
		current-version)
			current_version ;;
		latest-version)
			latest_version ;;
		update)
			update ;;
		send)
			send "${@:2}" ;;
		help)
			cmd_help "${@:2}" ;;
		?*)
			echo -e "\e[91mUnknown argument:\e[0m '${1}'"
			cmd_help ;;
		*)
			cmd_help ;;
	esac
}
main "$@"

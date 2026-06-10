#! /usr/bin/env bash

######################################################
######################################################
# SCRIPT: webm_to_mp4.sh
# PURPOSE: recursively find webm files in source dir and encode to mp4; move webm file to processed dir
# AUTHOR: https://github.com/kalebpc
# VERSION: 1.0.0
# DATE: 2026.05.15
######################################################
######################################################
# Copyright (c) 2026 https://github.com/kalebpc
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
######################################################
######################################################

SCRIPT_NAME="webm_to_mp4.sh"
SCRIPT_LOG="$HOME/Logs/webm_to_mp4.log"
HANDBRAKE_PRESET="1080p30 mp4"

function help () {
	cat << EOF

Usage:
    $SCRIPT_NAME -S <string> [OPTION...]

Required Arguments:
    -S	<string>	path to movie trailers directory

Options:
    -h,-help		show this help
    -n			perform dry run
    -x			debug

Example:
    $SCRIPT_NAME -S "$HOME"

EOF
}

function add_log_entry () {
	echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >&2
	if [ "$DRY_RUN" == "false" ]; then
		echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> "$SCRIPT_LOG" || { printf "[         error] Failed to add entry to '%s'.\n" "$1" >&2; ((ERRORS++)); }
	fi
}

function set_opts () {
	while getopts ":S:P:h :n :x" opt; do
		case $opt in
			S) SOURCE=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			P) PROCESSED=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			h) help; exit 0
			;;
			n) DRY_RUN=true
			;;
			x) DEBUG=true
			;;
			\?) echo "Invalid option argument -$OPTARG" >&2; help; exit 1
			;;
		esac
		case "$OPTARG" in
			-*) echo "Invalid option argument -$opt='$OPTARG'" >&2; help; exit 1
			;;
		esac
	done
}

function verify_user_input () {
	! [ -d "$SOURCE" ] && { add_log_entry "[         error] System could not find '$SOURCE'."; ((ERRORS++)); return 1; }
	if ! [ -d "$PROCESSED" ]; then
		if [ "$PROCESSED" == "" ]; then
			PROCESSED="$HOME/tmp"
		fi
		add_log_entry "[  creating dir] Creating processed folder: '$PROCESSED'."
		[ "$DRY_RUN" == "false" ] && { mkdir -p "$PROCESSED" || { add_log_entry "[         error] System could not create processed folder: '$PROCESSED'."; ((ERRORS++)); return 1; }; }
	fi
	return 0
}

function print_debug () {
	local datetime=$(date "+%Y-%m-%d %H-%M-%S")
	cat << EOF

[$datetime][scriptlog          ] $SCRIPT_LOG
[$datetime][source             ] $SOURCE
[$datetime][current encode log ] $CURRENT_ENCODE_LOG
[$datetime][encode log dir     ] $ENCODE_LOG_DIR
[$datetime][processed          ] $PROCESSED
[$datetime][dryrun             ] $DRY_RUN
[$datetime][debug              ] $DEBUG
[$datetime][errors             ] $ERRORS
[$datetime][files to move      ] $TOMOVE
[$datetime][moved files        ] $MOVED
[$datetime][dirs to be removed ] $TOREMOVE
[$datetime][removed dirs       ] $REMOVED
EOF
}

function encode () {
	local in="$1" out="${1%\.*}.mp4" result=0 tmp="${1##*\/}" insize=1 outsize=1 percent=0
	CURRENT_ENCODE_LOG="$ENCODE_LOG_DIR/${tmp%\.*} $(date "+%Y-%m-%d %H-%M-%S").log"
	
	add_log_entry "[start encoding]"
	if ! [ -f "$CURRENT_ENCODE_LOG" ]; then
		add_log_entry "[  creating log] '$CURRENT_ENCODE_LOG'"
		if [ "$DRY_RUN" == "false" ]; then
			if ! > "$CURRENT_ENCODE_LOG"; then
				add_log_entry "[         error] creating current log file: '$CURRENT_ENCODE_LOG'"
				((ERRORS++))
			fi
		fi
	fi
	add_log_entry "[        preset] '$HANDBRAKE_PRESET'"
	add_log_entry "[            in] $in"
	add_log_entry "[           out] $out"
	if [ "$DRY_RUN" == false ]; then
		flatpak run --command=HandBrakeCLI fr.handbrake.ghb --preset-import-gui -Z "$HANDBRAKE_PRESET" -i "$in" -o "$out" 2>> "$CURRENT_ENCODE_LOG"
		if [ $? -eq 0 ]; then
			insize=$(stat -c%s "$in")
			outsize=$(stat -c%s "$out")
			percent=$(echo "scale=2; $outsize / $insize" | bc)
			add_log_entry "[   output size] ${percent//\./}% of original size."
		else
			add_log_entry "[         error] Handbrake error encountered encoding '$in'"
			result=1
			((ERRORS++))
		fi
	else
		echo "flatpak run --command=HandBrakeCLI fr.handbrake.ghb --preset-import-gui -Z '$HANDBRAKE_PRESET' -i '$in' -o '$out' 2>> '$CURRENT_ENCODE_LOG'"
	fi
	[ "$DEBUG" == true ] && print_debug
	return $result
}

function move_webm_to_processed () {
	((TOMOVE++))
	add_log_entry "[   moving file] '$1' to '$PROCESSED/'"
	if [ "$DRY_RUN" == false ]; then
		if mv "$1" "$PROCESSED/"; then
			((MOVED++))
		else
			add_log_entry "[         error] moving '$1' to '$PROCESSED/'."
			((ERRORS++))
		fi
	fi
}

function remove_extra_dirs () {
	local tmp="$PROCESSED/$(date "+%Y-%m-%d %H-%M-%S")-$RANDOM"
	((TOREMOVE++))
	add_log_entry "[    create dir] '$tmp'"
	add_log_entry "[    remove dir] '$1' to '$tmp/'"
	if [ "$DRY_RUN" == false ]; then
		if ! mkdir -p "$tmp"; then
			add_log_entry "[         error] creating dir '$tmp'."
			add_log_entry "[         error] returning before trying to remove '$1'."
			((ERRORS++))
			return
		fi
		if mv -v "$1" "$tmp/"; then
			((REMOVED++))
		else
			add_log_entry "[         error] moving '$1' to '$tmp/'."
			((ERRORS++))
		fi
	fi
}

function run () {
	local file fil fild temp=1m tmp
	if [[ "$SOURCE" =~ \/Movies\/?$ ]]; then
		tmp=$(find "$SOURCE" -maxdepth 1 -mindepth 1 -type d | wc -l)
		while [ $tmp -gt 0 ];do
			file=$(find "$SOURCE"/*/* -name "*.webm" -print -quit)
			for fil in "${file%\/*}"/*; do
				if [ -f "$fil" ] && [[ "$fil" =~ \.webm ]]; then
					if encode "$fil"; then
						move_webm_to_processed "$fil"
					else
						add_log_entry "[         error] occurred when encoding '$fil'"
						((ERRORS++))
					fi
				fi
				if [ -d "$fil" ]; then
					remove_extra_dirs "$fil"
				fi
			done
			echo "sleeping for $temp"
			sleep $temp
			((tmp--))
		done
	fi
}

function cleanup () {
	print_debug
	exit 0
}

function main () {
	local DRY_RUN=false DEBUG=false ERRORS=0 SOURCE="" PROCESSED="" CURRENT_ENCODE_LOG="" ENCODE_LOG_DIR="${SCRIPT_LOG%\/*}/handbrakecli" TOMOVE=0 MOVED=0 TOREMOVE=0 REMOVED=0
	
	# Setup logs
	! [ -d "${SCRIPT_LOG%/*}" ] && { mkdir -p "${SCRIPT_LOG%/*}" || { echo "[         error] creating script log dir: '${SCRIPT_LOG%/*}'." >&2; exit 1; };  }
	! [ -f "$SCRIPT_LOG" ] && { > "$SCRIPT_LOG" || { echo "[         error] creating script log file: '$SCRIPT_LOG'." >&2; exit 1; }; }
	
	# Catch no args run
	[ $# -ne 0 ] && set_opts "$@" || { add_log_entry "[         error] '$SCRIPT_NAME' requires arguments."; help; exit 1; }
	
	! [ -d "$ENCODE_LOG_DIR" ] && { echo "[    create dir] $ENCODE_LOG_DIR"; [ "$DRY_RUN" == "false" ] && { mkdir -p "$ENCODE_LOG_DIR" || { echo "[         error] creating encode log folder: '$ENCODE_LOG_DIR'." >&2; exit 1; }; }; }

	if verify_user_input; then
		trap cleanup EXIT
		run		
	else
		echo "Print help: $SCRIPT_NAME -h"; exit 1
	fi

	echo "[        errors] '$ERRORS' errors occurred while running."
	print_debug
}
main "$@"


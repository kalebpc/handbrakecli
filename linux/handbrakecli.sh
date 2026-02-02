#! /usr/bin/env bash

######################################################
######################################################
# SCRIPT: handbrakecli
# PURPOSE: Copy directories from source to destination; then encode files from souce to destination.
# AUTHOR: https://github.com/kalebpc
# VERSION: 1.0.0
# DATE: 2026.01.25
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

SCRIPT_NAME="./handbrakecli.sh"
HANDBRAKE_PRESET="1080p30 mp4"
SCRIPT_LOG="${HOME}/Logs/handbrakecli.log"
ENCODE_LOG="${HOME}/Logs/handbrakecli"

function help () {
	cat << EOF

Usage:
    $SCRIPT_NAME -S <string> -D <string> -p <string> -s <string> -d <string> -t <string> [OPTION...]

Required Arguments:
    -S	<string>	path to source directory
    -D	<string>	path to destination directory
    -p	<string>	handbrake preset
    -s	<string>	source file extension
    -d	<string>	destination file extension
    -t	<string>	file placed within source dirs to signify ready to encode
    			  explanation:
			  	when encoding shows place -t ready file in 'Season..' folder. ex. 'Show Name (Series 2005-2006)/Season 01/Ready.txt'
			  	when encoding movies place -t ready file in movie folder. ex. 'Movie Name (2005)/Ready.txt'
Options:
    -P	<string>	path to post-processed folder; folders will be moved here after encoding
    -h,-help		show this help
    -n			perform dry run
    -b	<int>		run on loop monitoring '-S source' every n seconds
    -m			use when encoding movies;
    			  explanation:
    			  	These placements will dictate how the source path is parsed to create name for 'CURRENT_ENCODE_LOG'.
    -x			debug

Example:
    $SCRIPT_NAME -S "$HOME/Videos/MKV" -D "$HOME/Videos/MP4" -p "Fast 1080p30" -s "mkv" -d "mp4" -t "Ready.txt"

EOF
}

function add_log_entry () {
	echo "[$(date "+%H:%M:%S")] $1" >&2
	if [ "$DRY_RUN" == "false" ]; then
		{ echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> "$SCRIPT_LOG"; [ $? -ne 0 ] && printf "[         error] Failed to add entry to '%s'.\n" "$1" >&2; }
	fi
}

function set_opts () {
	while getopts ":S:D:p:s:d:t:h :n :x :b:m :P:" opt; do
		case $opt in
			S) SOURCE=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			D) DEST=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			p) HANDBRAKE_PRESET=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			s) SOURCE_EXT=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			d) DEST_EXT=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			t) TEST=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			n) DRY_RUN=true
			;;
			x) DEBUG=true
			;;
			m) MOVIE=true
			;;
			b) LOOP=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			P) PROCESSED=$(awk '{$1=$1}1' <<<"$OPTARG")
			;;
			h) help; exit 0
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
	! [ -d "$SOURCE" ] && { add_log_entry "[         error] System could not find '$SOURCE'."; return 1; }
	! [ -d "$DEST" ] && { add_log_entry "[         error] System could not find '$DEST'."; return 1; }
	[ -z "$HANDBRAKE_PRESET" ] && { add_log_entry "[         error] System could not use preset: '$HANDBRAKE_PRESET'."; return 1; }
	[ -z "$SOURCE_EXT" ] && { add_log_entry "[         error] System could not use source extension: '$SOURCE_EXT'."; return 1; }
	[ -z "$DEST_EXT" ] && { add_log_entry "[         error] System could not use destination extension: '$DEST_EXT'."; return 1; }
	[ -z "$TEST" ] && { add_log_entry "[         error] System could not use test file: '$TEST'."; return 1; }
	! [[ "$LOOP" =~ ^[0-9]+$ ]] && { add_log_entry "[         error] System could not use loop: '$LOOP'."; return 1; }
	! [ -d "$PROCESSED" ] && { add_log_entry "[  creating dir] Creating processed folder: '$PROCESSED'."; [ "$DRY_RUN" == "false" ] && mkdir -p "$PROCESSED"; [ $? -ne 0 ] && { add_log_entry "[         error] System could not create processed folder: '$PROCESSED'."; return 1; }; }
	return 0
}

function print_debug () {
	local datetime=$(date "+%Y-%m-%d %H-%M-%S")
	cat << EOF
[$datetime][scriptlog          ] $SCRIPT_LOG
[$datetime][encodelog          ] $ENCODE_LOG
[$datetime][encodelog current  ] $CURRENT_ENCODE_LOG
[$datetime][processed          ] $PROCESSED
[$datetime][source             ] $SOURCE
[$datetime][destination        ] $DEST
[$datetime][in                 ] $IN
[$datetime][out                ] $OUT
[$datetime][preset             ] $HANDBRAKE_PRESET
[$datetime][source ext         ] $SOURCE_EXT
[$datetime][destination ext    ] $DEST_EXT
[$datetime][test               ] $TEST
[$datetime][dryrun             ] $DRY_RUN
[$datetime][movie              ] $MOVIE
[$datetime][loop               ] $LOOP
[$datetime][debug              ] $DEBUG
EOF
}

function encode () {
	local tmp=$(basename "$1")
	local result=0
	CURRENT_ENCODE_LOG="$ENCODE_LOG/${tmp/.$SOURCE_EXT/} $(date "+%Y-%m-%d %H-%M-%S").log"
	IN="$1"
	OUT="${1/$SOURCE/$DEST}"
	OUT="${OUT/$SOURCE_EXT/$DEST_EXT}"
	
	[ "$DEBUG" == "true" ] && print_debug
	add_log_entry "[start encoding]"
	[ "$DRY_RUN" == "true" ] && add_log_entry "[       dry run] 'true'"
	
	# create output directories if not existing
	tmp=$(dirname "$OUT")
	if ! [ -d "$tmp" ]; then
		add_log_entry "[  creating dir] '$tmp'"
		[ "$DRY_RUN" == "false" ] && { mkdir -p "$tmp"; [ $? -ne 0 ] && { add_log_entry "[         error] creating directories for OUT: '$OUT'"; return; }; }
	fi
	if ! [ -f "$CURRENT_ENCODE_LOG" ]; then
		add_log_entry "[  creating log] '$CURRENT_ENCODE_LOG'"
		[ "$DRY_RUN" == "false" ] && { > "$CURRENT_ENCODE_LOG"; [ $? -ne 0 ] && add_log_entry "[         error] creating current log file: '$CURRENT_ENCODE_LOG'"; }
	fi
	
	add_log_entry "[        preset] '$HANDBRAKE_PRESET'"
	add_log_entry "[         input] '$IN'"
	add_log_entry "[        output] '$OUT'"
	# encode file
	if [ "$DRY_RUN" == "true" ]; then
		# simulating coding progress
		#for n in {1..100}; do
			#echo -e "Encoding: $OUT, pass 1 of 1, $n % (xxx fps ETA xxHxxMxxS)\e[1F"
			#sleep .01
		#done

		#echo "HandBrakeCLI --preset-import-gui -Z "$HANDBRAKE_PRESET" -i "$IN" -o "$OUT" 2>> $CURRENT_ENCODE_LOG"

		# flatpak installed handbrake
		echo "flatpak run --command=HandBrakeCLI fr.handbrake.ghb --preset-import-gui -Z "$HANDBRAKE_PRESET" -i "$IN" -o "$OUT" 2>> $CURRENT_ENCODE_LOG"
		
		printf "Encoding: %s, pass 1 of 1, %d %% (xxx fps ETA xxHxxMxxS)" "$OUT" "$n"
		printf "\n"
	else
		# flatpak installed handbrake
		flatpak run --command=HandBrakeCLI fr.handbrake.ghb --preset-import-gui -Z "$HANDBRAKE_PRESET" -i "$IN" -o "$OUT" 2>> "$CURRENT_ENCODE_LOG"

		#HandBrakeCLI --preset-import-gui -Z "$HANDBRAKE_PRESET" -i "$IN" -o "$OUT" 2>> $CURRENT_ENCODE_LOG
		
		[ $? -ne 0 ] && { add_log_entry "[         error] Handbrake error encountered encoding '$IN'"; result=1; }
	fi
	# check exit code
	add_log_entry "[ done encoding]"
	return $result
}

function run () {
	local tmp temp errors=0
	if [ "$MOVIE" == "true" ]; then
		# example test file placement
		# $SOURCE/Movie Name (YEAR)/$TEST
		for file in "$SOURCE"/*/"$TEST"; do
			[[ "$file" =~ \* ]] && continue
			local dir="${file/\/$TEST/}"
			#add_log_entry "[           dir] $dir"
			for fil in "$dir"/*; do
				if [ -d "$fil" ]; then
					for x in "$fil"/*; do
						#add_log_entry "[extras file] $x"
						encode "$x"
						errors=$(($errors + $?))
					done
				else
					if ! [[ "$fil" =~ $TEST$ ]]; then
						#add_log_entry "[dir    file] $fil"
						encode "$fil"
						errors=$(($errors + $?))
					fi
				fi
			done
			if [ $errors -eq 0 ]; then
				tmp=$(basename "$dir")
				add_log_entry "[        moving] '$dir' to '${PROCESSED}/${tmp}'"
				[ "$DRY_RUN" == "false" ] && { mv "$dir" "${PROCESSED}/${tmp}"; [ $? -ne 0 ] && add_log_entry "[         error] moving '$dir' to '${PROCESSED}/${tmp}'."; }
			fi
		done
	else
		# example test file placement
		# $SOURCE/Show Name (Show YEAR-YEAR)/Season XX/$TEST
		for file in "$SOURCE"/*/*/"$TEST"; do
			[[ "$file" =~ \* ]] && continue
			dir="${file/\/$TEST/}"
			#add_log_entry "[dir        ] $dir"
			for fil in "$dir"/*; do
				if [ -d "$fil" ]; then
					for x in "$fil"/*; do
						#add_log_entry "[extras file] $x"
						encode "$x"
						errors=$(($errors + $?))
					done
				else
					if ! [[ "$fil" =~ $TEST$ ]]; then
						#add_log_entry "[dir    file] $fil"
						encode "$fil"
						errors=$(($errors + $?))
					fi
				fi
			done
			if [ $errors -eq 0 ]; then
				tmp="$dir"
				[ "${tmp:0:1}" == "/" ] && tmp="${tmp:1}"
				temp=$(dirname "$tmp")
				local tempbase=$(basename "$temp")
				! [ -d "${PROCESSED}/${tempbase}" ] && { add_log_entry "[  creating dir] '${PROCESSED}/${tempbase}'"; [ "$DRY_RUN" == "false" ] && { mkdir -p "${PROCESSED}/${tempbase}"; [ $? -ne 0 ] && { add_log_entry "[         error] creating processed directory for: '$dir'."; continue; }; }; }
				tmp="${tempbase}/$(basename "$tmp")"
				add_log_entry "[        moving] '$dir' to '${PROCESSED}/${tmp}'"
				if [ "$DRY_RUN" == "false" ]; then
					mv "$dir" "${PROCESSED}/${tmp}"
					[ $? -ne 0 ] && ( add_log_entry "[         error] moving '$dir' to '${PROCESSED}/${tmp}'."; continue; )
				fi
				temp=$(dirname "$dir")
				add_log_entry "[      removing] '$temp'."
				[ "$DRY_RUN" == "false" ] && { rmdir "$temp"; [ $? -ne 0 ] && add_log_entry "[         error] removing '$temp'."; }
			fi
		done
	fi
}

function main () {

	local DRY_RUN=false; DEBUG=false; CURRENT_ENCODE_LOG=""; LOOP=0; MOVIE=false; PROCESSED="" 
	
	# Setup logs
	! [ -d "$ENCODE_LOG" ] && { mkdir -p "$ENCODE_LOG"; [ $? -ne 0 ] && { echo "[         error] creating encode logs directory: '$ENCODE_LOG'." >&2; exit 1; }; }
	! [ -f "$SCRIPT_LOG" ] && { > "$SCRIPT_LOG"; [ $? -ne 0 ] && { echo "[         error] creating script log file: '$SCRIPT_LOG'." >&2; exit 1; }; }
	
	# Catch no args run
	[ $# -ne 0 ] && set_opts "$@" || { add_log_entry "[         error] '$SCRIPT_NAME' requires arguments.\n"; help; exit 1; }
	
	if verify_user_input; then
		[ "$DEBUG" == "true" ] && print_debug
		if [ $LOOP -gt 0 ]; then
			# currently not safe to use; if folder does not get moved due to error it will try to encode it again.
			#while true; do
			#	#add_log_entry 'looping; encode things.'
			#	run
			#	add_log_entry "Sleeping '$LOOP' seconds."
			#	sleep "$LOOP"
			#done
			run
		else 
			#add_log_entry 'no loop; encode things.'
			run
		fi
	else
		echo "Print help: $SCRIPT_NAME -h"; exit 1
	fi
}
main "$@"


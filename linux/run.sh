#! /usr/bin/env bash

######################################################
######################################################
# SCRIPT: run.sh
# PURPOSE: run handbrake.sh with args
# AUTHOR: https://github.com/kalebpc
# VERSION: 1.0.0
# DATE: 2026.01.29
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

#./handbrakecli.sh -S "/media/$USER/2 TB/MKV Movies" -D "/media/$USER/2 TB/Jellyfin/Movies" -s 'mkv' -d 'mp4' -P "/media/$USER/2 TB/Temp-PostProcessed" -t 'Ready' -m
#./handbrakecli.sh -S "/media/$USER/2 TB/MKV Shows" -D "/media/$USER/2 TB/Jellyfin/Shows" -s 'mkv' -d 'mp4' -P "/media/$USER/2 TB/Temp-PostProcessed" -t 'Ready'
./handbrakecli.sh -S "/media/$USER/2 TB/MKV Trailers" -D "/media/$USER/2 TB/Jellyfin/Movie Trailers" -s 'mkv' -d 'mp4' -P "/media/$USER/2 TB/Temp-PostProcessed" -t 'Ready' -T -n

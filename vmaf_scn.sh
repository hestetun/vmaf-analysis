#!/bin/bash

## Common variables
LOGDIR=/Users/$USER/scripts/logs
TODAY="$(date '+%y%m%d_%H%M')"
LOGF=$LOGDIR/vmaf_$TODAY.log
DEFAULT_THREADS=$(nproc --all)
DEFAULT_THREADS=$((DEFAULT_THREADS * 90 / 100))

echo "vmaf quality control" >> $LOGF

# Threads
read -p "How many threads do you want to use [default: $DEFAULT_THREADS]: " userthread
userthread=${userthread:-$DEFAULT_THREADS}
echo "Will use $userthread threads" >> $LOGF

# Reference File
read -p "drag n drop your reference file: " reference 
echo "will use this as reference file $reference" >> $LOGF

# List of files to analyze
read -p "Drag and drop files/folders to analyze: " files
echo "Analyzing: $files" >> $LOGF

# Analyze each file/folder
for file in $files; do
    if [[ -d "$file" ]]; then
        # Directory: analyze all files in the directory
        echo "Analyzing all files in folder: $file" >> $LOGF
        for f in "$file"/*; do
            if [[ -f "$f" ]]; then
                echo "Analyzing file: $f" >> $LOGF
                ffmpeg -i "$f" -i "$reference" -lavfi "[0][1]libvmaf=log_path=$LOGF:log_fmt=xml:n_threads=$userthread" -f null - && grep Parsed_ >> $LOGF
            fi
        done
    elif [[ -f "$file" ]]; then
        # Regular file: analyze the file
        echo "Analyzing file: $file" >> $LOGF
        ffmpeg -i "$file" -i "$reference" -lavfi "[0][1]libvmaf=log_path=$LOGF:log_fmt=xml:n_threads=$userthread" -f null - && grep Parsed_ >> $LOGF
    fi
done

echo "" >> $LOGF
echo "Analysis is done" >> $LOGF
cat $LOGF

exit

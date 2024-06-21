#!/bin/bash

# Script developed by Brix
# Info? send me an email to info [ at ] cesararaujo [ dot ] net

# You will require the folowing packages
# yt-dlp -> download the flv or mp4 file from youtube-
# ffmpeg -> convert to mp3 the downloaded file
# ffmpeg restricted extras -> ability to save the file in mp3 format
# recode -> convert the filename to ascii otherwise you will end with &nsbp; and other chars from html entities



if [ -z $1 ]
then
	echo "Plase input a file with youtube links, one per line."
	exit 2
fi

if [ ! -z $2 ]
then
	if [[ "$2" == "debug" ]]
	then
		echo "###################################"
		echo "##      Enabled debug mode!      ##"
		echo "###################################"
		DEBUG="DEBUG"
	fi
fi


if ! [ -x "$(command -v sed)" ]; then
  echo 'Error: sed is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v wget)" ]; then
  echo 'Error: wget is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v yt-dlp)" ]; then
  echo 'Error: yt-dlp is not installed.' >&2
  echo 'Try to install: sudo pip install yt-dlp'
  exit 1
fi

if ! [ -x "$(command -v ffmpeg)" ]; then
  echo 'Error: ffmpeg is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v pip)" ]; then
  echo 'Error: python pip is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v recode)" ]; then
  echo 'Error: python recode is not installed.' >&2
  exit 1
fi

##Checking package version
## Find if yt-dlp is latest version
echo "Checking yt-dlp version."
installed_version=$(pip3 show yt-dlp | grep -i version | cut -d ' ' -f 2)
latest_version=$(pip3 install yt-dlp==randomstring --break-system-packages 2>&1 | grep -i "from versions:" | cut -d '(' -f 2 | cut -d ')' -f 1 | tr ',' '\n' | tail -1 | tr -d ' ')
echo "Installed version: $installed_version"
echo "Latest version: $latest_version"
if [ "$installed_version" = "$latest_version" ]; then
  echo "The package yt-dlp is up-to-date."
else
	echo "Updating outdated yt-dlp package"
	pip3 install yt-dlp==${latest_version} --break-system-packages
	echo "If upgrade went well please run the script again."
	exit 1
fi




for LINES in `cat $1`;do

	# Remove from the line the list $list=xpto&index=XX
	LINE=$(echo $LINES | sed -e 's/[&|?]list=[a-zA-Z0-9]*//g' | sed -e 's/&index=[a-zA-Z0-9]*//g')

	# Get the youtube page where the video is
	RESULT="`wget -qO- ${LINE}`"

	# Get the page title to use as filename
	TEMP_NAME=$(echo ${RESULT} | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/ip;T;q' | recode html..ascii)

	# Replace - YouTube with nothing, its bad yo have it in the name
	TEMP_NAME_NO_YOUTUBE=$(echo ${TEMP_NAME} | sed 's/ - YouTube//g')

	# Replace / with - otherwise it will look for folder/filename
	NAME=$(echo ${TEMP_NAME_NO_YOUTUBE} | sed 's/\//-/g' )

	# If name is empty use a date or something
	if [[ -z "$NAME" ]]
	then
		NAME=$(date | sed 's/ /_/g')
	fi

	echo "###################################"
	echo "## Downloading: ${LINE}"
	echo "## Filename is: ${NAME} "
	echo "###################################"

	X=/tmp/.yt-dlp-$(date +%y.%m.%d_%H.%M.%S)-$RANDOM

	if [[ ! -z $DEBUG ]]
	then
		echo "###################################"
		echo "## Tempfile is: ${X}"
		echo "###################################"
	fi

	yt-dlp -f bestvideo+bestaudio --output=${X}.flv --format=18 "${LINE}"

	echo "###################################"
	echo "## Video downloaded, converting. ##"
	echo "###################################"

#	avconv -i ${X} -acodec libmp3lame -ac 2 -ab 128k -vn -y "${NAME}.mp3"
        if [[ ! -z $DEBUG ]]
        then
		ffmpeg -loglevel info -i ${X}.flv -acodec libmp3lame -ac 2 -ab 128k -vn -y "${X}.mp3"
	else
		ffmpeg -i ${X}.flv -acodec libmp3lame -ac 2 -ab 128k -vn -y "${X}.mp3" > /dev/null  2>&1
	fi

	mv  "${X}.mp3" "$(pwd)/${NAME}.mp3"
	RESULT=$?

	if [[ ! -z $DEBUG ]]
	then
		echo "###################################"
		echo "Removing temporary file: ${X}"
		echo "###################################"
	fi

	rm ${X}.flv

	if [[ $RESULT -eq 0 ]]
	then
		echo "###################################"
		echo "## Video converted succesfully! ##"
		echo "###################################"
	else
		FAILED=$(echo -e "$FAILED \n ${LINE}")
		echo "###################################"
		echo "## Video not converted           ##"a
		echo "###################################"
	fi

done

if [[ -z $FAILED ]]
then
	echo "###################################"
	echo "##   All videos are converted!   ##"
	echo "###################################"
else
	echo "###################################"
	echo "## Failed to convert:            ##"
	echo "## $FAILED"
	echo "###################################"
fi

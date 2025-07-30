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
  echo 'Error: recode is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v iconv)" ]; then
  echo 'Error: iconv is not installed.' >&2
  exit 1
fi


echo "Checking yt-dlp version."
#Checking package version
# Find if yt-dlp is latest version
VERSION=$(pip list --outdated 2>&1 | grep yt-dlp | sed 's/yt-dlp (//g' | sed 's/) - Latest://g' | sed 's/\[wheel\]//g')
CURRENT=$(echo $VERSION | awk '{ print $1 }' )
LATEST=$(echo $VERSION | awk '{ print $2 }' )

if [ "${CURRENT}" != "$LATEST" ]
then
	# Update the youtube dl
	#sudo yt-dlp -U
	echo "Please input sudo password to upgrade yt-dlp."
	pip install yt-dlp --upgrade
	echo "If upgrade went well, we will run the run the script again."
	sleep 5
	${0} $@
	exit
else
	echo "yt-dlp is up to date."
fi

for LINES in `cat $1`;do

	# Remove from the line the list $list=xpto&index=XX
	LINE=$(echo $LINES | sed -e 's/[&|?]list=[a-zA-Z0-9]*//g' | sed -e 's/&index=[a-zA-Z0-9]*//g')

	# Get the youtube page where the video is
	RESULT="`wget -qO- ${LINE}`"

	# Get the page title to use as filename
	TEMP_NAME=$(echo ${RESULT} | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/ip;T;q' | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null | recode html..ascii)
	
	# Replace - YouTube with nothing, its bad yo have it in the name
	TEMP_NAME_NO_YOUTUBE=$(echo ${TEMP_NAME} | sed 's/ - YouTube//g')


	# Replace / with - otherwise it will look for folder/filename
	NAME=$(echo ${TEMP_NAME_NO_YOUTUBE} | sed 's/\//-/g')

	# If name is empty use a date or something
	if [[ -z "$NAME" ]]
	then
		NAME=$(date | sed 's/ /_/g')
	fi

	echo "###################################"
	echo "## Downloading: ${LINE}"
	echo "## Filename is: ${NAME} "
	echo "###################################"

	X=/tmp/.yt-dlp-$(date +%y.%m.%d_%H.%M.%S)-$RANDOM.flv

	echo "###################################"
	echo "## Tempfile is: ${X}"
	echo "###################################"

	echo /usr/local/bin/yt-dlp -f bestaudio --output=${X} "${LINE}"

	/usr/local/bin/yt-dlp -f bestaudio --output=${X} "${LINE}"
	echo "###################################"
	echo "## Video downloaded, converting. ##"
	echo "###################################"

#	avconv -i ${X} -acodec libmp3lame -ac 2 -ab 128k -vn -y "${NAME}.mp3"
	ffmpeg -i ${X} -acodec libmp3lame -ac 2 -ab 128k -vn -y "${NAME}.mp3"

	echo "###################################"
	echo "Removing temporary file: ${X}"
	echo "###################################"

	rm ${X}

	echo "###################################"
	echo "## Video converted succesfully! ##"
	echo "###################################"

done

echo "###################################"
echo "## All videos are converted! ##"
echo "###################################"

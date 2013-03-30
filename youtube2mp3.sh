#!/bin/bash

# Script developed by Brix 
# Info? send me an email to info [ at ] cesararaujo [ dot ] net

# You will require the folowing packages
# youtube-dl -> download the flv or mp4 file from youtube-
# ffmpeg -> convert to mp3 the downloaded file
# ffmpeg restricted extras -> ability to save the file in mp3 format
# recode -> convert the filename to ascii otherwise you will end with &nsbp; and other chars from html entities



# Update the youtube dl
sudo youtube-dl -U


for LINE in `cat $1`;do

	# Get the youtube page where the video is
	RESULT="`wget -qO- ${LINE}`"

	# Get the page title to use as filename
	TEMP_NAME=$(echo ${RESULT} | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/ip;T;q' | recode html..ascii)

	# Replace - YouTube with nothing, its bad yo have it in the name
	TEMP_NAME_NO_YOUTUBE=$(echo ${TEMP_NAME} | sed  's/ - YouTube//g')
	
	# Replace / with - otherwise it will look for folder/filename
	NAME=$(echo ${TEMP_NAME_NO_YOUTUBE} | sed  's/\//-/g') 
	
	echo "###################################"
	echo "## Downloading: ${LINE}"
	echo "## Filename is: ${NAME} "
	echo "###################################"

	X=/tmp/.youtube-dl-$(date +%y.%m.%d_%H.%M.%S)-$RANDOM.flv

	echo "###################################"
	echo "## Tempfile is: ${X}"
	echo "###################################"

	youtube-dl --output=${X} --format=18 "${LINE}"

	echo "###################################"
	echo "## Video downloaded, converting. ##"
	echo "###################################"

	avconv -i ${X} -acodec libmp3lame -ac 2 -ab 128k -vn -y "${NAME}.mp3"

	echo "###################################"
	echo "Removing temporary file: ${X}"
	echo "###################################"
	
	rm ${X}
	
	echo "###################################"
	echo "##  Video converted succesfully! ##"
	echo "###################################"

done

echo "###################################"
echo "##   All videos are converted!   ##"
echo "###################################"
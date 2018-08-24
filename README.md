youtube2mp3 converter script
============================

Youtube 2 Mp3 converter script.

This scripts allows you to convert youtube files to mp3.

To use it make it executable and pass a file with a youtube link (playlists now included) per line.

Example download.txt

    http://www.youtube.com/watch?v=XXXXXXXXXXX
    http://www.youtube.com/watch?v=YYYYYYYYYYY
    http://www.youtube.com/watch?v=ZZZZZZZZZZZ


###Using the script

    youtube2mp3.sh download.txt
        
###Using the script in debug mode
    
    youtube2mp3.sh download.txt debug

If all goes well you will end up with 3 mp3 files :)

###Dependencies:

* youtube-dl -> download the flv or mp4 file from youtube
* recode -> rename the filename in ascii format (remove the html entities)
* ffmpeg -> convert the file to mp3, you may need special ffmpeg package

###Operational systems
* I used ubuntu and it works like a charm, so I guess you can use it in all
  linux distributions.
* Please report dificulties or problems with the script.



#!/bin/bash
##
# Name:   upscale.sh
# Info:   Upscale Video from Source and Create Release.
# Author: S22F5
##
# Notes:
# $1  >  Input Video
# $2  >  Upscale Factor
# $3  >  Frame Similarity Threshold
##

#info output
if [ -z "$3" ]
  then
    echo "usage: ./upscale.sh video.mkv(Input Video) 2(Scale can be 2/4) 101(Frame Similarity Threshold (over 100 = disabled))"
    exit 1
fi

#setup folder structure
mkdir source_frames
mkdir scaled_frames
mkdir safe_delete
mkdir release

#get frame rate
framerate=$(ffprobe -select_streams v:0 -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate -v quiet -of csv="p=0" "$1")

#extract frames
ffmpeg -i "$1" -r "$framerate"  source_frames/%06d.png

#get frame count
framecount=$(ls source_frames/ | sort -rn | head -n 1)



#deal with duplicate frames (info:we are in top directory)
#find duplicate frames
cd source_frames || exit
echo "finding duplicate frames:"
findimagedupes -t "$3" -- *.png > dupes
printf "done"
#process output
while IFS= read -r line; do
	
    #delete duplicate frames except first
	duplicate_frames=$(awk '{$1=""}1' <<< "$line" | xargs basename -a | tr '\n' ' ')		
	#save the name of one of the frames
	source_frame=$(awk '{print $1}' <<< "$line" | xargs basename -a)
	#upscale one of the frames
	echo "upscaling duplicate stem frames"
	realesrgan-ncnn-vulkan -s 2 -i "$source_frame" -o ../scaled_frames/"$source_frame" > /dev/null
	#copy
	cd ../scaled_frames || exit
	echo "filling frame gaps"
	echo $duplicate_frames | xargs -n 1 cp "$source_frame" > /dev/null
	cd ../source_frames || exit
	echo "deleting duplicate frames"
	echo "$line" | xargs -n 1 mv -t ../safe_delete
	#clear variables
	duplicate_frames=
	source_frame=
	
done < dupes
cd ..


#upscale frames
cd source_frames || exit
for frames in *.png; do
	clear
    echo "$frames" " / " "$framecount"
	realesrgan-ncnn-vulkan -s "$2" -i "$frames" -o ../scaled_frames/"$frames" > /dev/null
	done
cd .. || exit


###fixing bug where sometimes instead of the scaled up images you just get a 0B empty image
#fix errors in the scaler
mkdir fix
cd scaled_frames || exit
errorinfo=$(ls -SrqL . | head -1)
errorsize=$(stat -c %s "$errorinfo")
errorfiles=$(find . -size "$errorsize"c -printf '%f\n')
cd .. || exit
cp source_frames/"$errorfiles" fix
cd fix || exit
for fixframes in *.png; do
	clear
    echo "$fixframes" " / " "$framecount"
	realesrgan-ncnn-vulkan -s "$2" -i "$fixframes" -o ../scaled_frames/"$fixframes" > /dev/null
	done
cd .. || exit
rm -rvf fix

#fix2
mkdir fix
cd scaled_frames || exit
errorinfo=$(ls -SrqL . | head -1)
errorsize=$(stat -c %s "$errorinfo")
errorfiles=$(find . -size "$errorsize"c -printf '%f\n')
cd .. || exit
cp source_frames/"$errorfiles" fix
cd fix || exit
for fixframes in *.png; do
	clear
	echo "$fixframes" " / " "$framecount"
 	realesrgan-ncnn-vulkan -s "$2" -i "$fixframes" -o ../scaled_frames/"$fixframes" > /dev/null
    done
cd .. || exit
rm -rvf fix

#fix3
mkdir fix
cd scaled_frames || exit
errorinfo=$(ls -SrqL . | head -1)
errorsize=$(stat -c %s "$errorinfo")
errorfiles=$(find . -size "$errorsize"c -printf '%f\n')
cd .. || exit
cp source_frames/"$errorfiles" fix
cd fix || exit
for fixframes in *.png; do
	clear
	echo "$fixframes" " / " "$framecount"
    realesrgan-ncnn-vulkan -s "$2" -i "$fixframes" -o ../scaled_frames/"$fixframes" > /dev/null
    done
cd .. || exit
rm -rvf fix


#reasemble video and encode with x265
ffmpeg -s 1920x1080 -r "$framerate" -i scaled_frames/%06d.png -i "$1" -c:v libx265 -map 0:v -map 1 -map -1:v -vf scale=1920:-2 release/havefun.mkv


#create frame comparisings
#200
#convert source_frames/000200.png -crop 50%x100% +delete +repage /tmp/l000200.png
#convert scaled_frames/000200.png -gravity East -crop 50%x100% +repage /tmp/r000200.png
#convert +append /tmp/l000200.png /tmp/r000200.png -resize x1080 release/frame200.png


#clean up
rm -rvf source_frames 1> /dev/null
rm -rvf scaled_frames 1> /dev/null
rm -rvf safe_delete 1> /dev/null

#goodbye
printf "have a nice day ·–· \n"

##
# Name:   upscale.sh
# Info:   Upscale Video from Source and Create Release.
# Author: S22F5
##
# $1  >  Input Video
# $2  >  Upscale Factor

##
###

#info output
if [ -z "$2" ]
  then
    echo "usage: ./upscale.sh video.mkv(Input Video) 2(scalefactor can be 2/4)"
    exit 1
fi
#setup folder structure
mkdir source_frames
mkdir scaled_frames
mkdir release

#get frame rate
framerate=$(ffprobe -select_streams v:0 -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate -v quiet -of csv="p=0" $1)
#extract frames
ffmpeg -i $1 -r $framerate  source_frames/%06d.png
#get frame count
framecount=$(ls source_frames/ | sort -rn | head -n 1)
#upscale frames
cd source_frames
for frames in *.png; do
	clear
    echo $frames " / " $framecount
	realesrgan-ncnn-vulkan -s $2 -i $frames -o ../scaled_frames/$frames > /dev/null
	done
cd ..





###fixing bug where sometimes instead of the scaled up images you just get a 0B empty image
#fix errors in the scaler
mkdir fix
cd scaled_frames
errorinfo=$(ls -SrqL . | head -1)
errorsize=$(stat -c %s $errorinfo)
errorfiles=$(find . -size "$errorsize"c -printf '%f\n')
cd ..
cp source_frames/$errorfiles fix
cd fix
for fixframes in *.png; do
	clear
    echo $fixframes " / " $framecount
	realesrgan-ncnn-vulkan -s $2 -i $fixframes -o ../scaled_frames/$fixframes > /dev/null
	done
cd ..
rm -rvf fix

#fix2
mkdir fix
cd scaled_frames
errorinfo=$(ls -SrqL . | head -1)
errorsize=$(stat -c %s $errorinfo)
errorfiles=$(find . -size "$errorsize"c -printf '%f\n')
cd ..
cp source_frames/$errorfiles fix
cd fix
for fixframes in *.png; do
	clear
	echo $fixframes " / " $framecount
 	realesrgan-ncnn-vulkan -s $2 -i $fixframes -o ../scaled_frames/$fixframes > /dev/null
    done
cd ..
rm -rvf fix

#fix3
mkdir fix
cd scaled_frames
errorinfo=$(ls -SrqL . | head -1)
errorsize=$(stat -c %s $errorinfo)
errorfiles=$(find . -size "$errorsize"c -printf '%f\n')
cd ..
cp source_frames/$errorfiles fix
cd fix
for fixframes in *.png; do
	clear
	echo $fixframes " / " $framecount
    realesrgan-ncnn-vulkan -s $2 -i $fixframes -o ../scaled_frames/$fixframes > /dev/null
    done
cd ..
rm -rvf fix
###





#reasemble video and encode with x265
ffmpeg -s 1920x1080 -r $framerate -i scaled_frames/%06d.png -i $1 -c:v libx265 -map 0:v -map 1 -map -1:v -vf scale=1920:-2 release/havefun.mkv
#create frame comparisings
#200
convert source_frames/000200.png -crop 50%x100% +delete +repage /tmp/l000200.png
convert scaled_frames/000200.png -gravity East -crop 50%x100% +repage /tmp/r000200.png
convert +append /tmp/l000200.png /tmp/r000200.png -resize x1080 release/frame200.png
#clean up
rm -rvf source_frames 1> /dev/null
rm -rvf scaled_frames 1> /dev/null
#
echo "have a nice day \v_v/" 



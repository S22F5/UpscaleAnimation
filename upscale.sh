##
# Name:   upscale.sh
# Info:   Upscale Video from Source and Create Release.
# Author: S22F5
##
# $1  >  Input Video
# $2  >  Input FPS
# $3  >  Upscale Factor
##
###

#info output
echo "usage: ./upscale.sh video.mkv(Input Video) 24000/1001(Input FPS) 2(scalefactor can be 2/4)"
#setup folder structure
mkdir source_frames
mkdir scaled_frames
mkdir release
#get frame count
framecount=$(ffmpeg -i 1.mkv -map 0:v:0 -c copy -f null -y /dev/null 2>&1 | grep -Eo 'frame= *[0-9]+ *' | grep -Eo '[0-9]+' | tail -1)
#extract frames
ffmpeg -ss 3 -i 1.mkv -r 60  %06d.png |& awk -v framecount="$framecount" '{print $2 "/" framecount "Frames"}'  RS='\r'
#upscale frames
cd source_frames
for frames in *.png
        echo $frames
	do realesrgan-ncnn-vulkan -n RealESRGANv2-animevideo-xsx2 -s $3 -i $frames -o ../scaled_frames/$frames > /dev/null
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
for fixframes in *.png
        echo $fixframes
	do realesrgan-ncnn-vulkan -n RealESRGANv2-animevideo-xsx2 -s $3 -i $fixframes -o ../scaled_frames/$frames > /dev/null
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
for fixframes in *.png
        echo $fixframes
        do realesrgan-ncnn-vulkan -n RealESRGANv2-animevideo-xsx2 -s $3 -i $fixframes -o ../scaled_frames/$frames > /dev/null
        done
cd ..
#fix3
mkdir fix
cd scaled_frames
errorinfo=$(ls -SrqL . | head -1)
errorsize=$(stat -c %s $errorinfo)
errorfiles=$(find . -size "$errorsize"c -printf '%f\n')
cd ..
cp source_frames/$errorfiles fix
cd fix
for fixframes in *.png
        echo $fixframes
        do realesrgan-ncnn-vulkan -n RealESRGANv2-animevideo-xsx2 -s $3 -i $fixframes -o ../scaled_frames/$frames > /dev/null
        done
cd ..
###





#reasemble video and encode with x265
ffmpeg -s 1920x1080 -r $2 -i scaled_frames/%06d.png -i $1 -c:v libx265 -map 0:v -map 1 -map -1:v -vf scale=1920:1080 release/havefun.mkv
#create frame comparisings
#5000
convert source_frames/005000.png -gravity west -crop 8:9 /tmp/l5000.png
convert scaled_frames/005000.png -gravity east -crop 8:9 /tmp/r5000.png
convert -size 1920x1080 +append /tmp/l5000.png /tmp/r5000.png -resize 1920x1080 -annotate +10+10 "Frame 5000" -stroke black -strokewidth 4 -draw "line 960,0,960,1080" +repage -strokewidth 100 release/frame5000.png
#10000
convert source_frames/010000.png -gravity west -crop 8:9 /tmp/l10000.png
convert scaled_frames/010000.png -gravity east -crop 8:9 /tmp/r10000.png
convert -size 1920x1080 +append /tmp/l10000.png /tmp/r10000.png -resize 1920x1080 -annotate +10+10 "Frame 10000" -stroke black -strokewidth 4 -draw "line 960,0,960,1080" +repage -strokewidth 100 release/frame10000.png
#18000
convert source_frames/018000.png -gravity west -crop 8:9 /tmp/l18000.png
convert scaled_frames/018000.png -gravity east -crop 8:9 /tmp/r18000.png
convert -size 1920x1080 +append /tmp/l18000.png /tmp/r18000.png -resize 1920x1080 -annotate +10+10 "Frame 18000" -stroke black -strokewidth 4 -draw "line 960,0,960,1080" +repage -strokewidth 100 release/frame18000.png
#clean up
rm -rvf source_frames
rm -rvf scaled_frames
#
echo "have a nice day \v_v/" 



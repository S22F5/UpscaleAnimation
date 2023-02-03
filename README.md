# UpscaleAnimation
Upscales Animation Videos using https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan

<p align="center">
  <img src="https://raw.githubusercontent.com/S22F5/UpscaleAnimation/master/assets/frame_comp.png">
</p>

## Usage:

```wget "https://github.com/S22F5/UpscaleAnimation/raw/master/upscale.sh"```

```chmod +x upscale.sh```

```./upscale.sh video.mkv  2(scalefactor can be 2/4) 101(Frame Similarity Threshold (over 100 = disabled))```

## Dependencies:

- Real-ESRGAN-ncnn-vulkan
- findimagedupes
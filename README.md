# LviOSVideoPlayer
LviOSVideoPlayer 可以播放本地、网络几乎所有格式的视频，同时包含几套 UI 样式，方便集成。分别使用 AVPlayerVPVC 实现了播放本地货网络的 mp4 格式视频，使用 VitamioVPVC 播放本地或网络的任何格式视频。

### 效果图
![图1](/Snapshoot/1.jpg)
![图2](/Snapshoot/2.jpg)
![图3](/Snapshoot/3.jpg)

### 功能
1. 左右滑动调节进度
2. 上下滑动调节亮度
3. 多种尺寸屏幕切换
4. 播放控件播放中自动隐藏
5. 两套皮肤供选择
6. 两种控件布局样式
7. 4 种清晰度菜单供切换

# 用法
### 播放本地或网络视频
```` objective-c
VitamioVPVC *playerVC = [[VitamioVPVC alloc]initWithThemeStyle:VideoPlayerGreenButtonTheme controlBarMode:VideoPlayerControlBarWithoutPreviousAndNextOperate];
playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
[someViewController presentViewController:playerVC animated:YES completion:^{
        [playerVC preparePlayURL:<your video url> immediatelyPlay:YES];
    }];
````

### 播放本地或网络的 mp4 格式的视频
```` objective-c
AVPlayerVPVC *playerVC = [[AVPlayerVPVC alloc]initWithThemeStyle:VideoPlayerGreenButtonTheme controlBarMode:VideoPlayerControlBarWithoutPreviousAndNextOperate];
playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
[someViewController presentViewController:playerVC animated:YES completion:^{
        [playerVC preparePlayURL:<your video url> immediatelyPlay:YES];
    }];
````

# 安装
拖动 Classes 下的 LviOSVideoPlayer 文件夹到你的项目中，记住需要拷贝到你的项目中，否则会找不到相关的静态库文件。

### 配置Target链接参数

选择 Build Settings | Linking | Other Linker Flags, 将该选项的 Debug/Release 键都配置为 -ObjC .

### 添加 Vitamio SDK 的依赖

```` objective-c
- AVFoundation.framwork     音视频播放基本工具
- AudioToolbox.framwork     音频控制API
- CoreGraphics.framwork     轻量级2D渲染API
- CoreMedia.framwork        音视频低级API
- CoreVideo.framwork        视频低级API
- Foundation.framwork       基本工具
- MediaPlayer.framwork      系统播放器接口
- OpenGLES.framwork         3D图形渲染API
- QuartzCore.framwork       视频渲染输出需要
- UIKit.framwork            界面API
- libbz2.dylib              压缩工具
- libz.dylib                压缩工具
- libstdc++.dylib           C++标准库
- libiconv.dylib            字符编码转换工具
````

配置 target, 在 Xcode Build Phases | Link Binary With Libraries 中添加以上所列 框架和库.

# 添加其他依赖
请在您的项目中 Podfile 中添加 LviOSVideoPlayer 的 UI 依赖库，请添加以下两个依赖：
```` objective-c
pod 'LvModelWindow', '~> 0.1.1'
pod 'LvNormalSlider', :git => 'https://github.com/pgbo/LvNormalSlider.git'
````
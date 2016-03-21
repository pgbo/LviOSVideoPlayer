//
//  VideoPlayerConstants.h
//  GalaToy
//
//  Created by guangbo on 15/5/18.
//
//

#ifndef GalaToy_VideoPlayerConstants_h
#define GalaToy_VideoPlayerConstants_h


typedef NS_ENUM(NSUInteger, VideoPlayerThemeStyle) {
    VideoPlayerGreenButtonTheme = 0,       // action button 颜色为绿色的主题
    VideoPlayerYellowButtonTheme,          // action button 颜色为黄色的主题
};

/**
 *  播放器操作栏模式
 */
typedef NS_ENUM(NSUInteger, VideoPlayerControlBarMode) {
    /**
     *  默认模式，包含播放暂停、上一个、下一个
     */
    VideoPlayerControlBarModeDefault = 0,
    /**
     *  不包含上一个、下一个
     */
    VideoPlayerControlBarWithoutPreviousAndNextOperate,
};

/**
 *  视频清晰度类型
 */
typedef NS_ENUM(NSUInteger, VideoPlayerVideoDefinition){
    VideoDefinitionFluent = 0,     // 流畅
    VideoDefinitionStandard,       // 标清
    VideoDefinitionHigh,           // 高清
    VideoDefinitionSuper,          // 超清
};

/**
 根据视频的分辨率判断视频清晰度
 */
static inline VideoPlayerVideoDefinition judgeVideoDefinitionForVideoResolution(CGSize resolution) {
    if (resolution.height <= 360) {
        return VideoDefinitionFluent;
    }
    if (resolution.height <= 576) {
        return VideoDefinitionStandard;
    }
    if (resolution.height <= 720) {
        return VideoDefinitionHigh;
    }
    return VideoDefinitionSuper;
};

#endif

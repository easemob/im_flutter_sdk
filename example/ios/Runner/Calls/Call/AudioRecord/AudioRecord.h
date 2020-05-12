//
//  AudioRecord.h
//  EMiOSDemo
//
//  Created by lixiaoming on 2019/12/9.
//  Copyright © 2019 lixiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioRecord : NSObject
// 采样率
@property (nonatomic) int samples;
// 通道数
@property (nonatomic) int channels;
// 状态，0为未启动，1为启动
@property (nonatomic) int state;
// 读取麦克风缓冲
@property (nonatomic, assign) AudioBufferList audio_buffer_list;
@property (nonatomic, strong) NSMutableData* data;
// 定义回调
typedef void(^InputAudioData)(NSData*);
@property (nonatomic,copy) InputAudioData inputAudioData;

// 开启录音
- (bool)startAudioDataRecord;
//停止录音
- (void) stopAudioDataRecord;
@end

NS_ASSUME_NONNULL_END

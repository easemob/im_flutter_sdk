//
//  AudioRecord.m
//  EMiOSDemo
//
//  Created by lixiaoming on 2019/12/9.
//  Copyright © 2019 lixiaoming. All rights reserved.
//

#import "AudioRecord.h"

static AudioUnit vpio_unit_ = nil;
static const AudioUnitElement kInputBus = 1;
static int16_t* recordeddata = nil;
static int lastNumberFrames = 0;
@implementation AudioRecord
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initAudioRecord];
    }
    
    return self;
}
- (void) initAudioRecord {
    _samples = 48000;
    _channels = 1;
    _data = [NSMutableData data];
    _state = 0;
    _inputAudioData = nil;
}
- (void) SetChannels:(int)channels {
    if(channels != 1) {
        NSLog(@"Custom audio record channels must be 1..");
        return;
    }
    _channels = channels;
}
- (AudioBufferList)audio_buffer_list{
    return _audio_buffer_list;
}

static OSStatus OnDeliverData(    void *                            inRefCon,
                      AudioUnitRenderActionFlags *    ioActionFlags,
                      const AudioTimeStamp *            inTimeStamp,
                      UInt32                            inBusNumber,
                      UInt32                            inNumberFrames,
                      AudioBufferList * __nullable    ioData)
{
    if(!vpio_unit_)
        return -1;
    AudioRecord* self = (__bridge AudioRecord*)inRefCon;
    self->_audio_buffer_list.mNumberBuffers = 1;
    AudioBuffer* audio_buffer = &self->_audio_buffer_list.mBuffers[0];
    audio_buffer->mNumberChannels = self.channels;
    audio_buffer->mDataByteSize = inNumberFrames*2*self.channels;
    if(lastNumberFrames != inNumberFrames) {
        if(recordeddata){
            free(recordeddata);
            recordeddata = nil;
        }
        if(!recordeddata) {
            recordeddata = (int16_t*)malloc(inNumberFrames*2*self.channels);
        }
        lastNumberFrames = inNumberFrames;
    }
    
    audio_buffer->mData = recordeddata;
    OSStatus result = AudioUnitRender(vpio_unit_, ioActionFlags, inTimeStamp,
                                      inBusNumber, inNumberFrames, &self->_audio_buffer_list);
    if (result != noErr) {
      NSLog(@"Failed to render audio unit. Error=%ld", (long)result);
        return -1;
    }
    if([self->_data length] != inNumberFrames*2*self.channels)
        [self->_data setLength:inNumberFrames*2*self.channels];
    [self->_data replaceBytesInRange:NSMakeRange(0, inNumberFrames*2*self.channels) withBytes:audio_buffer->mData length:inNumberFrames*2*self.channels];
    if(self->_inputAudioData)
        self->_inputAudioData(self->_data);
    //[[[EMClient sharedClient] callManager] inputCustomAudioData:self->_data];
    
    return 0;
}
- (bool)startAudioDataRecord
{
    // Create an audio component description to identify the Voice Processing
    // I/O audio unit.
    AudioComponentDescription vpio_unit_description;
    vpio_unit_description.componentType = kAudioUnitType_Output;
    vpio_unit_description.componentSubType = kAudioUnitSubType_RemoteIO;
    vpio_unit_description.componentManufacturer = kAudioUnitManufacturer_Apple;
    vpio_unit_description.componentFlags = 0;
    vpio_unit_description.componentFlagsMask = 0;

    // Obtain an audio unit instance given the description.
    AudioComponent found_vpio_unit_ref =
        AudioComponentFindNext(nil, &vpio_unit_description);

    // Create a Voice Processing IO audio unit.
    OSStatus result = noErr;
    result = AudioComponentInstanceNew(found_vpio_unit_ref, &vpio_unit_);
    if (result != noErr) {
      NSLog(@"AudioComponentInstanceNew failed. Error=%ld.", (long)result);
      return false;
    }
    
    // Enable input on the input scope of the input element.
    UInt32 enable_input = 1;
    result = AudioUnitSetProperty(vpio_unit_, kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input, kInputBus, &enable_input,
                                  sizeof(enable_input));
    if (result != noErr) {
      NSLog(@"Failed to enable input on input scope of input element. "
                   "Error=%ld.",
                  (long)result);
      return false;
    }
    
    // Specify the callback to be called by the I/O thread to us when input audio
    // is available. The recorded samples can then be obtained by calling the
    // AudioUnitRender() method.
    AURenderCallbackStruct input_callback;
    input_callback.inputProc = OnDeliverData;
    input_callback.inputProcRefCon = (__bridge void * _Nullable)(self);
    result = AudioUnitSetProperty(vpio_unit_,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global, kInputBus,
                                  &input_callback, sizeof(input_callback));
    if (result != noErr) {
      NSLog(@"Failed to specify the input callback on the input bus. "
                   "Error=%ld.",
                  (long)result);
      return false;
    }
    
    AudioStreamBasicDescription format;
    format.mSampleRate = self.samples;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags =
        kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    format.mBytesPerPacket = 2 * self.channels;
    format.mFramesPerPacket = 1;  // uncompressed.
    format.mBytesPerFrame = 2 * self.channels;
    format.mChannelsPerFrame = self.channels;
    format.mBitsPerChannel = 8 * 2;
    // Set the format on the input scope of the output element/bus.
    result =
        AudioUnitSetProperty(vpio_unit_, kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Output, kInputBus, &format, sizeof(format));
    if (result != noErr) {
      NSLog(@"Failed to set format on input scope of output bus. "
                   "Error=%ld.",
                  (long)result);
      return false;
    }
    //初始化
     result = AudioUnitInitialize(vpio_unit_);
    if(result != noErr){
        NSLog(@"Faied to AudioUnitInitialize");
        return false;
    }
    //启动
    result = AudioOutputUnitStart(vpio_unit_);
    if(result != noErr){
        NSLog(@"Faied to AudioOutputUnitStart");
        return false;
    }
    _state = 1;
    NSLog(@"start custom audio record!!!");
    return true;
}

- (void) stopAudioDataRecord {
    if(!vpio_unit_)
        return;
    OSStatus result = AudioOutputUnitStop(vpio_unit_);
    if (result != noErr) {
      NSLog(@"Failed to stop audio unit. Error=%ld", (long)result);
    } else {
      NSLog(@"Stop audio unit.");
    }
    result = AudioUnitUninitialize(vpio_unit_);
    if (result != noErr) {
      NSLog(@"Failed to uninitialize audio unit. Error=%ld", (long)result);
    } else {
      NSLog(@"Uninitialized audio unit.");
    }
    vpio_unit_ = nil;
    if(recordeddata) {
        free(recordeddata);
        recordeddata = nil;
        lastNumberFrames = 0;
    }
    _state = 0;
    NSLog(@"stop custom audio record!!!");
}
@end

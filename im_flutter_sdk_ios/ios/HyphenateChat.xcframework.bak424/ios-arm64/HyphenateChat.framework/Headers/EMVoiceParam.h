/**
 *  \~chinese
 *  @header EMVoiceParam.h
 *  @abstract 用于识别本地语音文件的音频参数。
 *  @author Hyphenate
 *  @version 4.20
 *
 *  \~english
 *  @header EMVoiceParam.h
 *  @abstract Voice parameters for local voice file recognition.
 *  @author Hyphenate
 *  @version 4.20
 */

#import <Foundation/Foundation.h>
#import <CoreAudioTypes/CoreAudioTypes.h>

/**
 *  \~chinese
 *  支持的语音文件格式。
 *
 *  \~english
 *  Supported formats of voice files.
 */
typedef NS_ENUM(UInt32, EMVoiceFormat) {
    EMVoiceFormatPCM = kAudioFormatLinearPCM,  /** \~chinese PCM。 \~english PCM. */
    EMVoiceFormatAMR = kAudioFormatAMR,        /** \~chinese AMR。 \~english AMR. */
    EMVoiceFormatMP3 = kAudioFormatMPEGLayer3, /** \~chinese MP3。 \~english MP3. */
};

/**
 *  \~chinese
 *  用于识别本地语音文件的音频参数。
 *
 *  \~english
 *   Voice parameters for local voice file recognition.
 */
@interface EMVoiceParam : NSObject

/**
 *  \~chinese
 *  语音文件的格式。
 *
 *  \~english
 *  The format of the voice file.
 */
@property (nonatomic, assign) EMVoiceFormat format;

/**
 *  \~chinese
 *  语音文件的采样率（单位：Hz）。
 *
 *  可直接传入系统录音参数 AVSampleRateKey 对应的取值，例如 16000。
 *
 *  \~english
 *  The sampling rate of the voice file (in Hz).
 * 
 *  You can directly use the value configured for AVSampleRateKey, for example, 16000.
 */
@property (nonatomic, assign) NSInteger sampleRate;

/**
 *  \~chinese
 *  语音文件的采样位深（单位: bit），例如 16。
 *
 *  \~english
 *  The bit depth of the voice file (in bits), for example, 16.
 */
@property (nonatomic, assign) NSInteger bitsPerSample;

/**
 *  \~chinese
 *  语音文件的声道数，例如，1 表示单声道。
 *
 *  \~english
 *  The number of channels of the voice file. For example, 1 indicates a mono voice file.
 */
@property (nonatomic, assign) NSInteger channels;

@end
